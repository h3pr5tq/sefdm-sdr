%%
% Обработка реальной записи одного ofdm-sefdm-пакета
% О структуре пакета см. 08_sefdm_generate_packets/packets/readme.txt


%% П А Р А М Е Т Р Ы
clear;
close all;

% path(path, './functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');
path(path, '../04_ofdm_time_freq_synch_model/functions/');
path(path, '../05_real_ofdm_one_signal_processing/functions/');
path(path, '../08_sefdm_generate_packets/functions/');
path(path, '../07_sefdm_init_model/functions/');

fullFilename = ...
	[ '/home/ivan/Documents/Signals/1_rx_sefdm_11.05.18/truncate_to_one_packet/', ...
	  'tr_rx_sefdm__pckt_10000_1000__hdr_6_6__pld_20_6__sym_32_26_20_3_2_bpsk__.dat' ];

N_802_11a_prmbpl_subcarrier = 64;
Fd                          = 4 * 10^6;

hdr_n_sym  = 6; % Кол-во ofdm-символов в заголовке (для channel estimation)
hdr_len_cp = 6; % Длина CP у ofdm-символов

pld_n_sym  = 20; % Кол-во sefdm-символов в полезной нагрузке
pld_len_cp = 6; % Длина CP у sefdm-символов

sym_ifft_size    = 32; % IFFT size (также соответсвует длине ofdm-символов в заголовке)
sym_len          = 26; % длина sefdm-символа
sym_n_inf        = 20; % кол-во поднесущих с информацией
sym_len_left_gi  = 3; % длина левого GI по частоте
sym_len_right_gi = 2; % длина правого GI по частоте
sym_modulation   = 'bpsk'; % 'bpsk' or 'qpsk'

alfa = sym_len / sym_ifft_size;
if strcmp(sym_modulation, 'bpsk')
	modulation = 1;
elseif strcmp(sym_modulation, 'qpsk')
	modulation = 2;
else
	error('Bad @sym_modulation');
end

sefdm_init(sym_ifft_size, alfa, sym_len_right_gi, sym_len_left_gi, modulation);

% Вывод графиков: 'display' or 'no_display'
detection_graph_mode = 'no_display';
cts_graph_mode       = 'no_display';
fts_graph_mode       = 'no_display';


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
sampleJumpAfterSigDetect = 0;

SigDetect_s = struct('SampleNo', [], 'detectMetric', []);
detectSigNum = 0; % кол-во обнаруженных сигналов (определяет текущий размер массивов в структуре)

%% Алгоритм Coarse Time Synch
L_cts = 144; % размер окна суммирования
D_cts = 16; % длина одного STS

% Смещение от отсчёта на котором произошло превышение порога во время Signal Detection
% Должно быть отрицательным, т.к. превышение порого могло произойти после начала преамбулы (что скорее всего НЕ так, но вдруг)
startCTSSampleOffset = 0;

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


%% Signal Detection

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
end

if strcmp(detection_graph_mode, 'display')
	Graph_SignalDetection( detectMetricArray, SigDetect_s.SampleNo, 1 );
end
clear detectMetricArray filteredRxSig;


k = 1; % Кол-во обнаруженных сигналов


%% Coarse Time Synch
% Первое число - отсчёт,на котором произошло превышение порога,
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

if strcmp(cts_graph_mode, 'display')
	Graph_CoarseTimeSynch(ctsMetricArray, estCTO, startCTSSample, 1);
end
clear ctsMetricArray;


%% Fine Freq Synch
startFFSSample = estCTO + startFFSSampleOffset; % сдвиг от CTS, чтобы точно были только отсчёты STS

autoCorr = rxSig(startFFSSample         : startFFSSample + L_ffs - 1) * ...
		   rxSig(startFFSSample + D_ffs : startFFSSample + L_ffs + D_ffs - 1)';

angl = angle(autoCorr);
estFFO = N_802_11a_prmbpl_subcarrier / (2 * pi * D_ffs) * angl;


%% Fine Time Synch
startFTSSample = estCTO + startFTSSampleOffset;

ftsMetricArray = zeros(1, segmentFTSLen); % for debug

% Компенсируем FFO (так быстрее получается)
% Обратить ВНИМАНИЕ на "-" в экспоненте; он нужен т.к. потом etalonSig сопрягаем
etalonSig = etalonSig .* ...
	exp( -1i * 2 * pi * estFFO * (1 : length(etalonSig)) / N_802_11a_prmbpl_subcarrier ); 

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

if strcmp(fts_graph_mode, 'display')
	Graph_FineTimeSynch(ftsMetricArray, estFTO, startFTSSample, 1);
end
clear ftsMetricArray;


%% Компенсация частотной отстройки по ранее полученной оценке
hdr_len = (sym_ifft_size + hdr_len_cp) * hdr_n_sym; % длина заголовка
no_len  = sym_ifft_size + hdr_len_cp; % ofdm-символ с порядковым номером пакета
pld_len = (sym_len + pld_len_cp) * pld_n_sym; % длина полезной нагрузки

% Выделяем пакет (только Заголовок + OFDM-символ + Полезная нагрузка, без 802.11a преабмулы)
rxPacket = rxSig(estFTO + 128 : estFTO + 128 + hdr_len + no_len + pld_len - 1);

% Компенсируем Freq Offset
rxPacket = rxPacket .* exp( 1i * 2 * pi * estFFO * (1 : length(rxPacket)) / N_802_11a_prmbpl_subcarrier );


%% Оценка канала и остаточной частотной отстройки по OFDM-символам, следующим за преамбулой (заголовку)
% Выделяем Заголовок
rxHdr = rxPacket(1 : hdr_len);
rxHdr = reshape(rxHdr, sym_ifft_size + hdr_len_cp, hdr_n_sym); % Упаковали в 2d массив для удобной дальнейшей обработки
rxHdr = sefdm_del_cp(rxHdr, hdr_len_cp); % Убрали CP
rxHdr = sefdm_FFT(rxHdr, 'ofdm');
channel_freq_response = sefdm_estimate_channel(rxHdr);

% scatterplot( reshape(sefdm_allocate_subcarriers(rxHdr , 'rx'), 1, []) );
% grid on;
% title('Header: OFDM-syms before Equalaizer');
rxHdr = sefdm_equalizer(rxHdr, channel_freq_response);
% scatterplot( reshape(sefdm_allocate_subcarriers(rxHdr , 'rx'), 1, []) );
% grid on;
% title('Header: OFDM-syms after Equalaizer');

[fi0, dfi, symNo] = sefdm_estimate_residual_freq_offset(rxHdr);


%% Выделяем OFDM-символ с порядковым номером пакета
rxNo = rxPacket(1 + hdr_len : 1 + hdr_len + no_len - 1);
rxNo = rxNo.'; % сделали столбец
rxNo = sefdm_del_cp(rxNo, hdr_len_cp); % Убрали CP
rxNo = sefdm_FFT(rxNo, 'ofdm');
rxNo = sefdm_equalizer(rxNo, channel_freq_response); % Компенсация влияния канала
% scatterplot(rxNo); grid on; title('OFDM-sym with packet No after Equalazier');

[rxNo, symNo] = sefdm_compensate_residual_freq_offset(rxNo, fi0, dfi, symNo);
% scatterplot( reshape(sefdm_allocate_subcarriers(rxNo , 'rx'), 1, []) );
% grid on;
% title('OFDM-sym with packet No after Equalazier and Residual Freq Offset Compensation');


%% Демодулируем SEFDM Полезную нагрузку
rxPld = rxPacket(1 + hdr_len + no_len : 1 + hdr_len + no_len + pld_len - 1);
rxPld = reshape(rxPld, sym_len + pld_len_cp, pld_n_sym); % Упаковали в 2d массив для удобной дальнейшей обработки
rxPld = sefdm_del_cp(rxPld, pld_len_cp); % Убрали CP

R = sefdm_FFT(rxPld, 'sefdm');
scatterplot( reshape(sefdm_allocate_subcarriers(R , 'rx'), 1, []) );
grid on;
title('Payload: SEFDM-syms before Equalaizer/RFOC/Detection');

R = sefdm_equalizer(R, channel_freq_response);
scatterplot( reshape(sefdm_allocate_subcarriers(R , 'rx'), 1, []) );
grid on;
title('Payload: SEFDM-syms after Equalaizer, before RFOC/Detection');

[R, symNo] = sefdm_compensate_residual_freq_offset(R, fi0, dfi, symNo);
scatterplot( reshape(sefdm_allocate_subcarriers(R , 'rx'), 1, []) );
grid on;
title('Payload: SEFDM-syms after Equalaizer/RFOC, before Detection');

rx_modulation_sym = ID(R);
scatterplot( reshape(sefdm_allocate_subcarriers(rx_modulation_sym , 'rx'), 1, []) );
grid on;
title('Payload: SEFDM-syms after Equalaizer/RFOC/Detection');


