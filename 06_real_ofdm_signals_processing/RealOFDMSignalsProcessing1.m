%%
%


%% П А Р А М Е Т Р Ы
% close all;
path(path, './functions/');
% path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');
path(path, '../05_real_ofdm_one_signal_processing/functions/');

filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_randi_20ofdm_11.dat';

N_subcarrier = 64;
Fd           = 10 * 10^6;
N_ofdm_sym = 20; % кол-во OFDM-символов в пакете (не считая преамбулу)

% кол-во IQ-отсчётов, которое читается из файла за одну итерацию ~~~
% лучше размер буфера при детектировании (одном вызове функции)
bufSize = 1000;


%% Алгоритм Signal Detection
L_detection = 144; % размер окна суммирования
D_detection = 16; % длина одного STS
sig_detection_threshold = 0.93; % надо подбирать
% Коэффициенты FIR ФВЧ для удаления DC-offset
% ФВЧ: Equiripple, Fs = 10e6 Hz, Fstop = 100 Hz, Fpass = 4e6 Hz, Astop = 80 dB, Apass = 1 dB
b = [-0.069011962933607576275996109416155377403, ...
	 -0.24968762861092019811337650025961920619,  ...
	  0.637401352293061496112613895093090832233, ...
	 -0.24968762861092019811337650025961920619,  ...
	 -0.069011962933607576275996109416155377403];

%% Алгоритм Coarse Time Synch
L_cts = 144; % размер окна суммирования
D_cts = 16; % длина одного STS

% Смещение от отсчёта на котором произошло превышение порога во время Signal Detection
% Должно быть отрицательным, т.к. превышение порого могло произойти после начала преамбулы (что скорее всего НЕ так, но вдруг)
startCTSSampleOffset = -50;



%% О Б Р А Б О Т К А

% Принятый сигнал
fd = fopen(filename, 'r');
if fd == -1
    error('File is not opened');  
end

% статус может изменится каждую итерацию
signalDetectionStatus = 'PacketIsNotDetected'; % 'PacketIsNotDetected' or 'PacketIsDetected'

% 'FirstIteration' - самая первая итерация цикла
% 'PacketWasDetected' - на предыдующей итерации был обнаружен пакет
% 'PacketWasNotDetected' - на предыдующей итерации НЕ был обнаружен пакет
readFileStatus = 'FirstIteration';

cntr = 1; % del for debug

% кол-во отсчётов, которые будут обработаны из rxSig за одну итерацию
processComplexSamplesNum = bufSize - length(b) + 1 - L_detection - D_detection + 1;

while ~feof(fd)

	if strcmp(signalDetectionStatus, 'PacketIsNotDetected') % Поиск Пакета

		%% Получаем буфер с отсчётами обнаружения в нём сигнала (пакета)
		if strcmp(readFileStatus, 'FirstIteration') % Если самая первая итерация

			% Подготавливаем промежуточный буфер (rxSig) для дальнейшей его обработки в OptSignalDetection(...)
			[readSamples, readSamplesNum] = fread(fd, [1, 2 * bufSize], 'float32=>double');
			if mod(readSamplesNum, 2) ~= 0
				error('Number of I does not equal number of Q');
			end
			if readSamplesNum ~= 2 * bufSize % была последняя итерация считывания, дальше всё
				error('Finish file... Need Make handler');
			end

			rxSig = readSamples(1 : 2 : end) + 1i * readSamples(2 : 2 : end); % размер rxSig всегда остаётся равным bufSize
			rxSigFirstComplexSampleNo = 1;

		elseif strcmp(readFileStatus, 'PacketWasDetected') % Если пакет был обнаружен на предыдущей итерации

			[readSamples, readSamplesNum] = fread(fd, [1, 2 * bufSize], 'float32=>double');
			if mod(readSamplesNum, 2) ~= 0
				error('Number of I does not equal number of Q');
			end
			if readSamplesNum ~= 2 * bufSize % была последняя итерация считывания, дальше всё
				error('Finish file... Need Make handler');
			end

			rxSig = readSamples(1 : 2 : end) + 1i * readSamples(2 : 2 : end); % размер rxSig всегда остаётся равным bufSize
			rxSigFirstComplexSampleNo = rxSigFirstComplexSampleNo + bufSize;

		elseif strcmp(readFileStatus, 'PacketWasNotDetected') % Если пакет не был обнаружен на предыдущей итерации

			[readSamples, readSamplesNum] = ...
				fread(fd, [1, 2 * processComplexSamplesNum], 'float32=>double');
			if mod(readSamplesNum, 2) ~= 0
				error('Number of I does not equal number of Q');
			end
			if readSamplesNum ~= 2 * processComplexSamplesNum % была последняя итерация считывания, дальше всё
				error('Finish file... Need Make handler');
			end

			rxSig = [ unprocessedPartOfRxSig, ...
					  readSamples(1 : 2 : end) + 1i * readSamples(2 : 2 : end) ]; % размер rxSig всегда остаётся равным bufSize
			rxSigFirstComplexSampleNo = rxSigFirstComplexSampleNo + processComplexSamplesNum;

		end

		% получили rxSig с 1000 отсчётами, которые до этого не обрабатывались

		%% Алгоритм обнаружения сигнала

		%% Пропускаем через ФВЧ для удаления DC-offset
		% !!!!!!!!!!!!! СДЕЛАТЬ ЧТОБЫ ФИЛЬТРАЦИЯ БЫЛА ТОЖЕ ПОСТЕПЕННАЯ, А НЕ ВЕСЬ МАССИВ СРАЗУ !!!!!!!!!!!!!
		filteredRxSig = conv(rxSig, b, 'valid');

		%% Начальные значения последующей рекурсии
		i = 1; % по буферу filteredRxSig
		if strcmp(readFileStatus, 'FirstIteration') || ...
		   strcmp(readFileStatus, 'PacketWasDetected')

			autoCorrVal = filteredRxSig(i : i + L_detection - 1) * ...
					      filteredRxSig(i + 0 + D_detection : i + L_detection + D_detection - 1)';

			localEnergyVal = filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1) * ...
			                 filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1)'; % ?? ПОЧЕМУ ИМЕННО СДВИНУТАЯ КОПИЯ

		elseif strcmp(readFileStatus, 'PacketWasNotDetected')

			autoCorrVal = autoCorrVal + ...
			              filteredRxSig(i - 1 + L_detection) * filteredRxSig(i - 1 + L_detection + D_detection)' - ...
						  prevFilteredRxSigVal * filteredRxSig(i - 1 + D_detection)';

			localEnergyVal = localEnergyVal + ...
							 filteredRxSig(i - 1 + L_detection + D_detection) * filteredRxSig(i - 1 + L_detection + D_detection)' - ...
							 filteredRxSig(i - 1 + D_detection) * filteredRxSig(i - 1 + D_detection)';

		end

		detectionMetricVal = abs(autoCorrVal).^2 / localEnergyVal.^2; % ?? ЗАЧЕМ В КВАДРАТ

% 		detectionMetric(cntr) = detectionMetricVal; cntr = cntr + 1;% del, for debug

		if (detectionMetricVal > sig_detection_threshold)
			signalDetectionStatus = 'PacketIsDetected';
			signalDetectionSampleIndex = i;
			% ???? ??? ??? ??? ??? ?
			% /???//////continue?
			continue;
		end


		%% Алгоритм обнаружения в виде рекурсии
		for i = 2 : processComplexSamplesNum

			autoCorrVal = autoCorrVal + ...
						  filteredRxSig(i - 1 + L_detection) * filteredRxSig(i - 1 + L_detection + D_detection)' - ...
						  filteredRxSig(i - 1) * filteredRxSig(i - 1 + D_detection)';

			localEnergyVal = localEnergyVal + ...
							 filteredRxSig(i - 1 + L_detection + D_detection) * filteredRxSig(i - 1 + L_detection + D_detection)' - ...
							 filteredRxSig(i - 1 + D_detection) * filteredRxSig(i - 1 + D_detection)';

			detectionMetricVal = abs( autoCorrVal ).^2 / localEnergyVal.^2;

% 			detectionMetric(cntr) = detectionMetricVal; cntr = cntr + 1; % del for debuf

			% Обнаружение:
			% номер отсчёта на котором алгоритм обнаружения сигнала сделал вывод о наличии сигнала
			if (detectionMetricVal > sig_detection_threshold)
				signalDetectionStatus = 'PacketIsDetected';
				signalDetectionSampleIndex = i;
				break;
			end

		end

		% ДЛЯ СЛЕДУЮЩЕЙ ИТЕРАЦИИ
		if strcmp(signalDetectionStatus, 'PacketIsNotDetected') % Если пакет не был обнуружен в данном буфере (на данной итерации)

			prevFilteredRxSigVal = filteredRxSig(processComplexSamplesNum);
			readFileStatus = 'PacketWasNotDetected';

			% считанный кусок, который не был обработан в данной итерации
			% но будет обработан в следующей итерации (справедлив для следующей итерации!)
			unprocessedPartOfRxSig = rxSig(processComplexSamplesNum + 1 : bufSize);
		
			% если на след итерации обнаружим пакет, но отсчёт на котором обнаружили будет не до преамбулы, а внутри её
			% (справедлив для следующей итерации!)
			additionalPartOfRxSig4CTS = ....
				rxSig( processComplexSamplesNum - abs(startCTSSampleOffset) + 1 : processComplexSamplesNum );

		elseif strcmp(signalDetectionStatus, 'PacketIsDetected')
			continue;
		end

		

	elseif strcmp(signalDetectionStatus, 'PacketIsDetected') % Обработка Пакета

		signalDetectionStatus = 'PacketIsNotDetected';
		readFileStatus = 'PacketWasDetected';
% 		needReadComplexSamplesNum = bufSize;

		unprocessedPartOfRxSig = rxSig(i + 1 : bufSize);


		qwer = 200 + (N_ofdm_sym * 80 + 320) - (bufSize - i + 1);

% 		processComplexSamplesNum = qwer; %% ?????????????????????????

		% Считываем отсчётов примерно составляющих один пакет (потом подобрать это значение)
		[readSamples, readSamplesNum] = fread(fd, [1, 2 * qwer], 'float32=>double');



		% Для следующей итерации подготавливаем
		rxSigFirstComplexSampleNo = rxSigFirstComplexSampleNo + qwer - bufSize;
		% Coarse Time Synch
		% Первое число - отсчёт,на котором SD,
		% второе число - сколько отсчётов откатить назад, на случай если превышение порога произошло не до начала преамбулы, а внутри неё
% 		startCTSSample = signalDetectionSampleIndex + startCTSSampleOffset; % 1 - с самого начала файла
% 		[ctsMetric, estCTO] = CoarseTimeSynch(rxSig, L_cts, D_cts, startCTSSample, segmentCTSLen );
% 		if strcmp(cts_graph_mode, 'display')
% 			Graph_CoarseTimeSynch(ctsMetric, estCTO, startCTSSample, firstComplexSampleNo);
% 		end
% 		clear ctsMetric;

	end

	

end


fclose(fd);

