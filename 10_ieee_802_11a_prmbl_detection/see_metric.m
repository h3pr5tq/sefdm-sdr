fullFilename = ...
	[ '/home/ivan/Documents/Signals/1_rx_sefdm_11.05.18/truncate_to_several_packets/', ...
	  'tr_15_rx_sefdm__pckt_10000_1000__hdr_6_6__pld_20_6__sym_32_26_20_3_2_bpsk__.dat' ];


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


%% Signal Detection

% Сколько подряд отсчётов должно быть превышение порога,
% чтобы сделать вывод об обнаружении преамбулы
cntr_max_val = 60;

% Счётчик; учавствует во время пропуска
% участка, после обнаружения сигнала, чтобы не детектировать одну
% преамбулу несколько раз
skip_prmbl_cntr = 0;

PRMBL_LEN = 320;

% Счётчик - сколько раз подряд превышен порог
detect_thr_exceed_cntr = 0;

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

if detectMetric > sig_detection_threshold

	% Получим отсчёт, на котором первый раз произошло превышение порога
	% и соответсвующую данному отсчёту метрику
	if detect_thr_exceed_cntr == 0
		first_detect_thr_exceed_SampleNo = i;
		first_detect_thr_exceed_DetectMetric = detectMetric;
	end

	detect_thr_exceed_cntr = detect_thr_exceed_cntr + 1;

	if detect_thr_exceed_cntr > cntr_max_val

		% Обнаружили преамбулу
		detectSigNum = detectSigNum + 1; % Кол-во обнаруженных пакетов
		SigDetect_s.SampleNo    (detectSigNum) = first_detect_thr_exceed_SampleNo;
		SigDetect_s.detectMetric(detectSigNum) = first_detect_thr_exceed_DetectMetric;

		% Обнулили счётчик подряд идущих превышений порога
		detect_thr_exceed_cntr = 0;

		% Для пропуска следующих PRMBL_LEN отсчётов,
		% после того как сделали вывод об обнаружении пакета
		skip_prmbl_cntr = PRMBL_LEN;

	end

end
skip_prmbl_cntr = skip_prmbl_cntr - 1;
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

	if detectMetric > sig_detection_threshold && skip_prmbl_cntr <= 0

		% Получим отсчёт, на котором первый раз произошло превышение порога
		% и соответсвующую данному отсчёту метрику
		if detect_thr_exceed_cntr == 0
			first_detect_thr_exceed_SampleNo = i;
			first_detect_thr_exceed_DetectMetric = detectMetric;
		end

		detect_thr_exceed_cntr = detect_thr_exceed_cntr + 1;

		if detect_thr_exceed_cntr > cntr_max_val

			% Обнаружили преамбулу
			detectSigNum = detectSigNum + 1; % Кол-во обнаруженных пакетов
			SigDetect_s.SampleNo    (detectSigNum) = first_detect_thr_exceed_SampleNo;
			SigDetect_s.detectMetric(detectSigNum) = first_detect_thr_exceed_DetectMetric;

			% Обнулили счётчик подряд идущих превышений порога
			detect_thr_exceed_cntr = 0;

			% Для пропуска следующих PRMBL_LEN отсчётов,
			% после того как сделали вывод об обнаружении пакета
			skip_prmbl_cntr = PRMBL_LEN;

		end

	else
		% Обнулили счётчик подряд идущих превышений порога
		detect_thr_exceed_cntr = 0;
	end

	skip_prmbl_cntr = skip_prmbl_cntr - 1;
	i = i + 1;

end

Graph_SignalDetection( detectMetricArray, SigDetect_s.SampleNo, 1 );
% clear detectMetricArray filteredRxSig;

