%%
%
% В Signal Detect алгоритм есть побочка, алгоритм
% обнаружения даёт сдоровенный пик на конце пакета (мб как-то связано с резким падением
% уровня сигнала в нуль). Надо проскакивать эти пики Jump'ом.
% Нужно будет подобрать универсальный Jump
%
% СДелать ФВЧ ближе к реалу, а также последний этап обработки
%
% По кодy заметки
% + плюс сохранение в файл промежуточных результатов по пакетам!
% Самое долгое Signal Detection, остальное быстро
%
% cnstlltAfterOnlyChannelCompensation[N_ofdm_sym * 48] - точки созвездия ТОЛЬКО после компенсации влияния канала
% ОЦЕНИТЬ как долго можно не компенсировать остаточную частотную отстройку (ХОЧУ вообще отказать от пилотов в SEFDM)
% БЕЗ ПИЛОТОВ НИКАК! ОСТАТОЧНАЯ ЧАСТОТНАЯ ОТСТРОЙКА - СЕРЬЁЗНАЯ ОЧЕНЬ(((
%


%% П А Р А М Е Т Р Ы
% close all;
path(path, './functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');
path(path, '../05_real_ofdm_one_signal_processing/functions/');


filename = 'rx_randi_20ofdm_20000pckt_15.dat';
folder   = '../Signals/RxBaseband_ComplexFloat32_bin/';
% folder   = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/';

fullFilename        = [folder, filename];
fullFilename_txBits = '../Signals/TxBit_txt/randi_20ofdm.txt';

% % % % % Не забыть указать % % % % %
N_ofdm_sym   = 20; % кол-во OFDM-символов в пакете (не считая преамбулу)
N_subcarrier = 64;
Fd           = 10 * 10^6;

% Папки под результаты обработки
resultFolder = ['./ProcessingResults/', filename(1 : end-4), '/'];
resultConstellationFolder = [resultFolder, 'constellations/'];
resultCTSFolder           = [resultFolder, 'cts/'];
resultFTSFolder           = [resultFolder, 'fts/'];

% Выполнять Signal Detection или взять готовые результаты обработки из файла
% 'make' - выполняем Signal Detection or 'from_file' - используем готовые результаты Signal Detection из файла
% 'save' - выполняем Signal Detection и сохраняем результат в .mat файл
detection_mode = 'save';
fullFilename_SigDetect_s  = [resultFolder, 'SigDetect_s.mat'];

% Вывод графиков: 'display' or 'no_display' or 'save'
detection_graph_mode     = 'display';
cts_graph_mode           = 'no_display';
fts_graph_mode           = 'no_display';
constellation_graph_mode = 'no_display';

% если mode == 'save'
if strcmp(detection_mode, 'save') || ...
   strcmp(cts_graph_mode, 'save') || ...
   strcmp(fts_graph_mode, 'save') || ...
   strcmp(constellation_graph_mode, 'save')

	if exist(resultFolder, 'dir') == 0   mkdir(resultFolder);   end

	if exist(resultConstellationFolder, 'dir') == 0   mkdir(resultConstellationFolder);   end
	if exist(resultCTSFolder,           'dir') == 0   mkdir(resultCTSFolder);             end
	if exist(resultFTSFolder,           'dir') == 0   mkdir(resultFTSFolder);             end

end

% Информация о найденных пакетах
packetInf = struct('packetNo',         [], ...
                   'detectSampleNo',   [], ...
                   'detectMetric',     [], ...
                   'ctsSampleNo',      [], ...
                   'ctsMetric',        [], ...
				   'estFreqOffset',    [], ...
                   'estFreqOffset_Hz', [], ...
                   'ftsSampleNo',      [], ...
                   'ftsMetric',        []);

%% Алгоритм Signal Detection
L_detection = 144; % размер окна суммирования
D_detection = 16; % длина одного STS
sig_detection_threshold = 0.6; % надо подбирать

% Коэффициенты FIR ФВЧ для удаления DC-offset
% ФВЧ: Equiripple, Fs = 10e6 Hz, Fstop = 100 Hz, Fpass = 4e6 Hz, Astop = 80 dB, Apass = 1 dB
b = [-0.069011962933607576275996109416155377403, ...
	 -0.24968762861092019811337650025961920619,  ...
	  0.637401352293061496112613895093090832233, ...
	 -0.24968762861092019811337650025961920619,  ...
	 -0.069011962933607576275996109416155377403];

% Кол-во отсчётов, которые пропускаем (не учитываем) после того как сигнал обнаружен
% (на данной кол-во отсчётов алгоритм обнаружения "засыпает")
% sampleJumpAfterSigDetect = (N_ofdm_sym * 80 + 320) + 100; % 100 - чтобы перескочить побочный непонятные пики
sampleJumpAfterSigDetect = 320;

SigDetect_s = struct('SampleNo', [], 'detectMetric', []);
detectSigNum = 0; % кол-во обнаруженных сигналов (определяет текущий размер массивов в структуре)

%% Алгоритм Coarse Time Synch
L_cts = 144; % размер окна суммирования
D_cts = 16; % длина одного STS

% Смещение от отсчёта на котором произошло превышение порога во время Signal Detection
% Должно быть отрицательным, т.к. превышение порого могло произойти после начала преамбулы (что скорее всего НЕ так, но вдруг)
startCTSSampleOffset = -50;

% Кол-во отсчётов для которых выполняется алгоритм CTS
% 160 - длина всех STS, abs(startCTSSampleOffset) - компенсирует смещение,
% possibleSamplesNumBeforePrmbl- если превышение порого произошло до начало преамбулы (что по результатм моделирования скорее всего так)
possibleSmplNumBeforePrmbl = 50;
segmentCTSLen  = (160 + abs(startCTSSampleOffset)) + possibleSmplNumBeforePrmbl;

%% Алгоритм Fine Freq Synch
L_ffs = 64;
D_ffs = 64;
% Смещение от оценки CTS для выполнения FFS
% Отрезок на котором выполняется FFS должны попадать ТОЛЬКО STS (на случай если estCTO оказалась до преамбулы)
startFFSSampleOffset = 15;

%% Алгоритм Fine Time Synch
% [(10STS + LGI) - x], где x  оцениваем по моделированию CTS
% Должен 100% попасть первый отсчёт первого LTS
startFTSSampleOffset = (160 + 32) - 20;

% Оцениваем по моделированию CTS; данный параметр связан с x
% Если брать слишком большой, можем затронуть второй LTS --> получим второй пик, который не нужен
segmentFTSLen = 40;

% Коррелируем с первыми 32 отсчётами LTS (до 64 можно брать)
[ ~, etalonSig] = GenerateLTS('Rx'); etalonSig = etalonSig(1 : 32);


%% О Б Р А Б О Т К А

%% Чтение файла целиком
fd = fopen(fullFilename, 'r');
if fd == -1
    error('File is not opened');  
end
[readRawIQ, readRawIQNum] = fread(fd, [1, Inf], 'float32=>double');
if mod(readRawIQNum, 2) ~= 0
	error('Number of I does not equal number of Q');
end
rxSig = readRawIQ(1 : 2 : end) + 1i * readRawIQ(2 : 2 : end);
fclose(fd);


%% Signal Detection
if strcmp(detection_mode, 'make') || strcmp(detection_mode, 'save')

	cntr = 0; % for debug

	fprintf('Detecting Signals ...\n');

	% Фильтрация (компенсация DC-offset)
	filteredRxSig = conv(rxSig, b, 'valid'); % length(filteredRxSig) == length(RxSig) - length(b) + 1

	% Первая итерация
	detectMetricArray = zeros(1, length(filteredRxSig)); % for debug
	i = 1;
	autoCorr = filteredRxSig(i : i + L_detection - 1) * ...
			   filteredRxSig(i + 0 + D_detection : i + L_detection + D_detection - 1)';

	localEnergy = filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1) * ...
				  filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1)';

	detectMetric = abs(autoCorr).^2 / localEnergy.^2;
	detectMetricArray(i) = detectMetric;

	if (detectMetric > sig_detection_threshold)

		% Обнаружили пакет
		detectSigNum = detectSigNum + 1;
		SigDetect_s.SampleNo    (detectSigNum) = i;
		SigDetect_s.detectMetric(detectSigNum) = detectMetric;

		% Перепрыгиваем пакет (на sampleJumpAfterSigDetect алгоритм обнаружения "засыпает")
		i = i + sampleJumpAfterSigDetect;

		% Новые начальные значения для последующей рекурсии
		autoCorr = filteredRxSig(i : i + L_detection - 1) * ...
				   filteredRxSig(i + 0 + D_detection : i + L_detection + D_detection - 1)';

		localEnergy = filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1) * ...
					  filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1)';

	end
	i = i + 1;


	% Последующие итерации (рекурсивный алгоритм)
	while i <= length(filteredRxSig) - L_detection - D_detection + 1 % == length(RxSig) - length(b) + 1 - L_detection - D_detection + 1
		autoCorr = autoCorr + ...
				   filteredRxSig(i - 1 + L_detection) * filteredRxSig(i - 1 + L_detection + D_detection)' - ...
				   filteredRxSig(i - 1) * filteredRxSig(i - 1 + D_detection)';

		localEnergy = localEnergy + ...
					  filteredRxSig(i - 1 + L_detection + D_detection) * filteredRxSig(i - 1 + L_detection + D_detection)' - ...
					  filteredRxSig(i - 1 + D_detection) * filteredRxSig(i - 1 + D_detection)';

		detectMetric = abs( autoCorr ).^2 / localEnergy.^2;
		detectMetricArray(i) = detectMetric;

		if (detectMetric > sig_detection_threshold)

			% Обнаружили пакет
			detectSigNum = detectSigNum + 1;
			SigDetect_s.SampleNo    (detectSigNum) = i;
			SigDetect_s.detectMetric(detectSigNum) = detectMetric;

			% Перепрыгиваем пакет (на sampleJumpAfterSigDetect алгоритм обнаружения "засыпает")
			i = i + sampleJumpAfterSigDetect;

			% Если после прыжка вылезли за допустимый предел while,
			% то не надо находить новые начальные значения autoCorr и localEnergy,
			% а надо выйти из цикла
			if i > length(filteredRxSig) - L_detection - D_detection + 1
				break;
			end

			% Новые начальные значения для последующей рекурсии
			autoCorr = filteredRxSig(i : i + L_detection - 1) * ...
					   filteredRxSig(i + 0 + D_detection : i + L_detection + D_detection - 1)';

			localEnergy = filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1) * ...
						  filteredRxSig(i + 0 + D_detection : i + D_detection + L_detection - 1)';
		end

		i = i + 1;

		cntr = cntr + 1; % for debug
 		if cntr > 100000
			cntr = 0;
			fprintf('Processed %-9d of %-9d samples\n', i - 1, length(filteredRxSig));
		end

	end

	% Проверяем, является ли последний обнаруженный пакет (сигнал) необрезанным, т.е. содержит полностью payload
	% Если пакет обрезанный, не учитываем его
	if SigDetect_s.SampleNo(end) + possibleSmplNumBeforePrmbl + (320 + N_ofdm_sym * 80) > length(rxSig)

		detectSigNum = detectSigNum - 1;
		SigDetect_s.SampleNo     = SigDetect_s.SampleNo    (1 : end - 1);
		SigDetect_s.detectMetric = SigDetect_s.detectMetric(1 : end - 1);
		fprintf('Last found packet is not complete (full)! We diskard this package\n');
	end

	if strcmp(detection_graph_mode, 'display')
		Graph_SignalDetection( detectMetricArray, SigDetect_s.SampleNo, 1 );
	end
	clear detectMetricArray filteredRxSig;

	fprintf('Detected %d full packets (signals) in file\n', detectSigNum);

	% Сохранение результатов Signal Detection в файл
	if strcmp(detection_mode, 'save')
		fprintf('Saving Signal Detection results ...\n');
		if exist(fullFilename_SigDetect_s, 'file') ~= 0 % Если файл уже существует
			fprintf('"%s" is exist!\n', fullFilename_SigDetect_s);
			answer = input('Overwrite result? Y/N: ', 's');
			if strcmp(answer, 'Y') || strcmp(answer, 'y') || strcmp(answer, 'yes')
				save(fullFilename_SigDetect_s, 'SigDetect_s');
				fprintf('Signal Detection result was overwrote\n');
			else
				fprintf('Signal Detection result is NOT save\n');
			end
		else
			save(fullFilename_SigDetect_s, 'SigDetect_s');
			fprintf('Signal Detection result was saved\n');
		end		
	end

elseif strcmp(detection_mode, 'from_file')

	fprintf('Will use results Detecting Signals from file\n');
	load(fullFilename_SigDetect_s, 'SigDetect_s');
	detectSigNum = length(SigDetect_s.SampleNo); % кол-во обноруженных пакетов (сигналов)

end


%% Обработка обнаруженных пакетов

% Буфер под принятые демодулированные биты
rxBits = uint8(zeros(detectSigNum, N_ofdm_sym * 48));

for k = 1 : detectSigNum

	fprintf('Processing packet No %d ...\n', k);

	%% Coarse Time Synch
	% Первое число - отсчёт,на котором SD,
	% второе число - сколько отсчётов откатить назад, на случай если превышение порога произошло не до начала преамбулы, а внутри неё
	startCTSSample = SigDetect_s.SampleNo(k) + startCTSSampleOffset;

	% Используем рекурсивный алгоритм

	ctsMetricArray = zeros(1, segmentCTSLen); % for debug

	% Первая итерация 
	i = startCTSSample;
	autoCorr = rxSig(i : i + L_cts - 1) * ...
               rxSig(i + 0 + D_cts : i + L_cts + D_cts - 1)';
	% Метрика (максимум модуля автокорреляции НА заданном отрезке)
	ctsMetric = abs(autoCorr);
	estCTO = i; % номер отсчёта

	ctsMetricArray(i - startCTSSample + 1) = abs(autoCorr); % for debug

	% Последующие итерации (рекурсивный алгоритм)
	for i = startCTSSample + 1 : startCTSSample + segmentCTSLen - 1

		autoCorr = autoCorr + ...
				   rxSig(i - 1 + L_cts) * rxSig(i - 1 + L_cts + D_cts)' - ...
				   rxSig(i - 1) * rxSig(i - 1 + D_cts)';

		% Метрика (максимум модуля автокорреляции НА заданном отрезке)
		if abs(autoCorr) > ctsMetric
			ctsMetric = abs(autoCorr);
			estCTO = i;
		end

		ctsMetricArray(i - startCTSSample + 1) = abs(autoCorr); % for debug
	
	end

	if ~strcmp(cts_graph_mode, 'no_display')
		GraphSave_CoarseTimeSynch( ctsMetricArray, estCTO, startCTSSample, k, ...
		                           cts_graph_mode, resultCTSFolder );
	end
	clear ctsMetricArray;


	%% Fine Freq Synch
	startFFSSample = estCTO + startFFSSampleOffset; % сдвиг от CTS, чтобы точно были только отсчёты STS

	autoCorr = rxSig(startFFSSample         : startFFSSample + L_ffs - 1) * ...
	           rxSig(startFFSSample + D_ffs : startFFSSample + L_ffs + D_ffs - 1)';

	angl = angle(autoCorr);
	estFFO = N_subcarrier / (2 * pi * D_ffs) * angl;


	%% Fine Time Synch
	startFTSSample = estCTO + startFTSSampleOffset;

	ftsMetricArray = zeros(1, segmentFTSLen); % for debug

	% Компенсируем FFO (так быстрее получается)
	% Обратить ВНИМАНИЕ на "-" в экспоненте; он нужен т.к. потом etalonSig сопрягаем
	etalonSig = etalonSig .* ...
		exp( -1i * 2 * pi * estFFO * (1 : length(etalonSig)) / N_subcarrier ); 
	
	ftsMetric = 0; estFTO = 0;
	for i = startFTSSample : startFTSSample + segmentFTSLen - 1

		crossCorr = rxSig(i + 0 : i + length(etalonSig) - 1) * etalonSig';

		% Метрика (максимум модуля взаимной корреляции НА заданном отрезке)
		if abs(crossCorr) > ftsMetric
			ftsMetric = abs(crossCorr);
			estFTO = i;
		end

		ftsMetricArray(i - startFTSSample + 1) = abs(crossCorr); % for debug

	end

	if ~strcmp(fts_graph_mode, 'no_display')
		GraphSave_FineTimeSynch( ftsMetricArray, estFTO, startFTSSample, k, ...
		                         fts_graph_mode, resultFTSFolder);
	end
	clear ftsMetricArray;


	%% Equalizer (Channel Compensation) + Freq Offset Compensation + Residual Freq Offset Compensation
	% Эквалайзер выполняет оценку канала (также устраняет/учитывает фазовый сдвиг между Tx и Rx колебаниями осцилляторов и
	% постоянный фазовый сдвиг из-за накапливаемой частотной отстройки) +
	% + компенсация фазового смещения возникающего из-за неидеальной FreqSynch (residual freq offset)

	rxPacket = rxSig(estFTO : estFTO + 128 + N_ofdm_sym * 80 - 1); % выделяем ~~ пакет (только 2 LTS + Payload, без STS и LongGI)

	% Компенсируем Freq Offset
	rxPacket = rxPacket .* exp( 1i * 2 * pi * estFFO * (1 : length(rxPacket)) / N_subcarrier ); 

	% Оценка канала
	channelFreqResponse  = ChannelEstimationByLTS( rxPacket(1 : 128) ); % оценка канала

	% FFT 802.11a
	% !!!! !!!! !!!! ПРИБЛИЗИТЬ К РЕАЛУ :: сделать обработку по одному ofdm-символу
	rxPayload = rxPacket(128 + 1 : 128 + N_ofdm_sym * 80); % выделили payload
	rxPayload = Del_GI( rxPayload ); % удаление GI (предполагает идеальную FTS)
	[cnstlltBeforeCompensation, ~, noNullSubcarrier] = Constellate_From_OFDMSymbols( rxPayload ); % 802.11a FFT

	% cnstlltBeforeCompensation          [N_ofdm_sym * 48] - точки созвездия до компенсации влияния канала и остаточной частотной отстройки
	% cnstlltAfterFullCompensation       [N_ofdm_sym * 48] - точки созвездия после компенсации влияния канала и остаточной частотной отстройки
	% cnstlltAfterOnlyChannelCompensation[N_ofdm_sym * 48] - точки созвездия ТОЛЬКО после компенсации влияния канала
	cnstlltnAfterFullCompensation        = zeros(1, length(cnstlltBeforeCompensation));
	cnstlltnAfterOnlyChannelCompensation = zeros(1, length(cnstlltBeforeCompensation));

	for i = 0 : N_ofdm_sym - 1

		% Выделили кусок соответсвующий одному OFDM-символу
		noNullSubcarrierSegment = noNullSubcarrier(1 + i * 52 : 52 + i * 52);

		% Компенсируем влияние канала
		noNullSubcarrierSegment = noNullSubcarrierSegment ./ channelFreqResponse;

		[ cnstlltnAfterOnlyChannelCompensation(1 + i * 48 : 48 + i * 48), pilotSubcarrier ] = ...
			AllocateInfAndPilotSubcarrier( noNullSubcarrierSegment );

		% Оценка фазового смещения, вызванного Residual Freq Offset
		estPO = PhaseSynchByPilots( pilotSubcarrier );
		cnstlltnAfterFullCompensation(1 + i * 48 : 48 + i * 48) = ...
			cnstlltnAfterOnlyChannelCompensation(1 + i * 48 : 48 + i * 48) * exp(-1i * estPO); % компенсируем
	end

	if ~strcmp(constellation_graph_mode, 'no_display')
		GraphSave_Constellation( cnstlltBeforeCompensation, ...
			                     cnstlltnAfterOnlyChannelCompensation, cnstlltnAfterFullCompensation, N_ofdm_sym, k, ...
		                         constellation_graph_mode, resultConstellationFolder);
	end


	%% Demodulation
	rxBits(k, real(cnstlltnAfterFullCompensation) >  0) = 0;
	rxBits(k, real(cnstlltnAfterFullCompensation) <= 0) = 1;


	%% Суммарная информация по пакету
	packetInf(k).packetNo         = k;
	packetInf(k).detectSampleNo   = SigDetect_s.SampleNo(k);
	packetInf(k).detectMetric     = SigDetect_s.detectMetric(k);
	packetInf(k).ctsSampleNo      = estCTO;
	packetInf(k).ctsMetric        = ctsMetric;
	packetInf(k).estFreqOffset    = estFFO;
	packetInf(k).estFreqOffset_Hz = estFFO * Fd / N_subcarrier;
	packetInf(k).ftsSampleNo      = estFTO;
	packetInf(k).ftsMetric        = ftsMetric;
	packetInf(k).rxBits           = rxBits(k, :);


	%% К следующей итерации (к обработке следующего пакета)
	if strcmp(cts_graph_mode, 'display') || ...
	   strcmp(fts_graph_mode, 'display') || ...
	   strcmp(constellation_graph_mode, 'display')

		input('\nPress Enter to resume\n\n');
	end

end


%% Результат: кол-во верно принятых бит
fd = fopen(fullFilename_txBits, 'r');
if fd == -1
    error('File is not opened');  
end
txBits = fscanf(fd, '%d\n', Inf);
txBits = txBits.'; % column to row
fclose(fd);

[number, ratio] = biterr(rxBits, txBits);