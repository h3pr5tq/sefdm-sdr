%%
% Все этапы синхронизации тут:
%   - обнаружение
%   - гурбая и точная временная
%   - грубая и точная частотная
%   - компенсация фазого смещения
%   Какие-то этапы мб поитогу не понадобятся, какие-то объединены
%
% Если предположить, что нестабильность LO 20 ppm, то для 500 МГц несущей хватит Fine Freq Synch, без Coarse
% Проблема, в том что в hackrf осуществляет перенос в baseband через IF, + некоторых модулей-чипов есть
% встроенные OScilatorы, и чот по pdf пока не удалось понять какой на самом деле суммарный ppm
% 20 ppm - цифра от офф разработчика-контрибьютера hackrf
%
% Удобен для обработки записи, которая содержит один сигнал
% Для обработки одного сигнала/пакета


%% П А Р А М Е Т Р Ы
% close all;
path(path, './functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');
path(path, '../04_ofdm_time_freq_synch_model/functions/');

filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_randi_20ofdm_13.dat';

N_subcarrier = 64;
Fd           = 10 * 10^6;

% Обрезка файла
truncate_mode = 'no_truncate'; % 'truncate' or 'no_truncate'
firstComplexSampleNo = 8 * 10^5;
endComplexSampleNo   = 8.5 * 10^5;

% Рижим обработки после синхронизации (демодуляция)
processing_mode = 'payload'; % 'payload' - демодуляция только полезной нагрузки; 'preamble' - демодуляция только преамбулы
N_ofdm_sym = 20; % кол-во OFDM-символов в пакете (не считая преамбулу)

% Вывод результатов обработки в консоль
console_mode = 'display'; % 'display' or 'no_display' 

% Вывод графиков: 'display' or 'no_display'
detection_graph_mode = 'display';
cts_graph_mode = 'display';
fts_graph_mode = 'display';
ps_graph_mode = 'display';

% Делать ли Coarse Freq Synch или нет (выполняется только Fine Freq Synch)
cfs_mode = 'no_make'; %'make' or 'no_make'

%% Алгоритм Signal Detection
L_detection = 144; % размер окна суммирования
D_detection = 16; % длина одного STS
sig_detection_threshold = 0.95; % надо подбирать

%% Алгоритм Coarse Time Synch
L_cts = 144; % размер окна суммирования
D_cts = 16; % длина одного STS

% Смещение от отсчёта на котором произошло превышение порога во время Signal Detection
% Должно быть отрицательным, т.к. превышение порого могло произойти после начала преамбулы (что скорее всего НЕ так, но вдруг)
startCTSSampleOffset = -50;

% Кол-во отсчётов для которых выполняется алгоритм CTS; 0 - значит для всех
% 160 - длина всех STS, abs(startCTSSampleOffset) - компенсирует смещение,
% 50 - если превышение порого произошло до начало преамбулы (что по результатм моделирования скорее всего так)
segmentCTSLen  = (160 + abs(startCTSSampleOffset)) + 50;  % 0 - для всех отчётов файла

%% Алгоритм Coarse Freq Synch
L_cfs = 16;
D_cfs = 16;
roundToInteger = 'no'; % 'yes' or 'no' округлять до целого в сторону нуля или нет ?? МБ ВАЩЕ НАФИГ ???
% Смещение от оценки CTS для выполнения CFS
% Отрезок на котором выполняется CFS должны попадать ТОЛЬКО STS (на случай если estCTO оказалась до преамбулы)
startCFSSampleOffset = 15;

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

% Принятый сигнал
fd = fopen(filename, 'r');
if fd == -1
    error('File is not opened');  
end
rxSig = fread(fd, [1, inf], 'float32=>double');
rxSig = rxSig(1 : 2 : end) + 1i * rxSig(2 : 2 : end);
fclose(fd);

if strcmp(truncate_mode, 'truncate') % обрезаем
	rxSig = rxSig(firstComplexSampleNo : endComplexSampleNo);
else % не обрезаем
	firstComplexSampleNo = 1;
	endComplexSampleNo   = length(rxSig);
end


%% Signal Detection
[detectionMetric, signalDetectionSample] = SignalDetection(rxSig, L_detection, D_detection, sig_detection_threshold);

if strcmp(detection_graph_mode, 'display')
	Graph_SignalDetection(detectionMetric, signalDetectionSample, firstComplexSampleNo);
end
clear detection_metric;


%% Coarse Time Synch
% Первое число - отсчёт,на котором SD,
% второе число - сколько отсчётов откатить назад, на случай если превышение порога произошло не до начала преамбулы, а внутри неё
startCTSSample = signalDetectionSample + startCTSSampleOffset; % 1 - с самого начала файла

[ctsMetric, estCTO] = CoarseTimeSynch(rxSig, L_cts, D_cts, startCTSSample, segmentCTSLen );

if strcmp(cts_graph_mode, 'display')
	Graph_CoarseTimeSynch(ctsMetric, estCTO, startCTSSample, firstComplexSampleNo);
end
clear ctsMetric;


%% Coarse Freq Synch
if strcmp(cfs_mode, 'make')
	startCFSSample = estCTO + startCFSSampleOffset;

	estCFO = FreqSynch(rxSig, L_cfs, D_cfs, startCFSSample, roundToInteger);
	rxSig = rxSig .* exp( 1i * 2 * pi * estCFO * (1 : length(rxSig)) / N_subcarrier ); % компенсируем на CFO
else
	estCFO = 0;
end


%% Fine Freq Synch
startFFSSample = estCTO + startFFSSampleOffset;

estFFO = FreqSynch( rxSig, L_ffs, D_ffs, startFFSSample, roundToInteger);
rxSig = rxSig .* exp( 1i * 2 * pi * estFFO * (1 : length(rxSig)) / N_subcarrier ); % компенсируем FFO


%% Fine Time Synch
startFTSSample = estCTO + startFTSSampleOffset;

[ftsMetric, estFTO] = FineTimeSynch(rxSig, etalonSig, startFTSSample, segmentFTSLen );

if strcmp(fts_graph_mode, 'display')
	Graph_FineTimeSynch(ftsMetric, estFTO, startFTSSample, firstComplexSampleNo);
end
clear ftsMetric;


%% Phase Offset Compensation using Pilots (== простенький эквалайзер)
% Сдвиг фазы сигнала связан с набегом частоты до компенсации + фазовый сдвиг между Tx и Rx колебаниями осцилляторов +
% + неидельное положение окна FFT + ещё мб что-то
if strcmp(processing_mode, 'preamble')
	
	TwoLTS = rxSig(estFTO : estFTO + 128 - 1);
	estPO  = PhaseSynchByLTS( TwoLTS );

	bpskBeforeCompensation = [ Constellate_From_LTS(TwoLTS(1 : 64)), ...
							   Constellate_From_LTS(TwoLTS(65 : 128)) ];

	bpskAfterCompensation  = bpskBeforeCompensation * exp(-1i * estPO);

else
	
	payloadOfOnePacket = rxSig(estFTO + 128 : estFTO + 128 + N_ofdm_sym * 80 - 1); % выделили payload из сигнала
	payloadOfOnePacket = Del_GI( payloadOfOnePacket ); % удаление GI (предполагает идеальную FTS)
	[bpskBeforeCompensation, pilots] = Constellate_From_OFDMSymbols( payloadOfOnePacket ); % 802.11a FFT

	bpskAfterCompensation = zeros(1, length(bpskBeforeCompensation));
	for i = 0 : N_ofdm_sym - 1

		estPO = PhaseSynchByPilots( pilots(1 + i * 4 : 4 + i * 4) );

		bpskAfterCompensation(1 + i * 48 : 48 + i * 48) = ...
			bpskBeforeCompensation(1 + i * 48 : 48 + i * 48) * exp(-1i * estPO);

	end

end

if strcmp(ps_graph_mode, 'display')
	if strcmp(processing_mode, 'preamble')
		scatterplot(bpskBeforeCompensation); grid on; title('Before Phase Offset Compensation');
		scatterplot(bpskAfterCompensation);  grid on; title('After Phase Offset Compensation');
	else
		Graph_PhaseSynch(bpskBeforeCompensation,  bpskAfterCompensation, N_ofdm_sym);
	end
end


%% Р Е З У Л Ь Т А Т
if strcmp(console_mode, 'display')

	fprintf('\n - - - - - - - - П А Р А М Е Т Р Ы   О Б Р А Б О Т К И - - - - - - - -\n');
	fprintf('  Файл:        %s\n', filename);
	fprintf('  Отсчёты:     с %d по %d (включительно)\n', firstComplexSampleNo, endComplexSampleNo);
	fprintf('  Fd:          %d Гц\n', Fd);
	fprintf('  Nfft:        %d  // кол-во поднесущих\n\n', N_subcarrier);

	fprintf('  Алгоритм Signal Detection\n');
	fprintf('    L:         %-4d  // окно суммирования\n', L_detection);
	fprintf('    D:         %-4d  // смещение сигнала при автокорреляции\n', D_detection);
	fprintf('    Threshold: %-4.2f\n\n', sig_detection_threshold);

	fprintf('  Алгоритм Coarse Time Synch\n');
	fprintf('    L:         %-4d  // окно суммирования\n', L_cts);
	fprintf('    D:         %-4d  // смещение сигнала при автокорреляции\n', D_cts);
	fprintf('    Offset:    %-4d  // смещение от отсчёта на котором произошло превышение порога во время Signal Detection\n', ...
			startCTSSampleOffset);
	fprintf('    SegLength: %-4d  // кол-во отсчётов для которых выполняется алгоритм CTS\n\n', segmentCTSLen);


	fprintf('  Алгоритм Coarse Freq Synch\n');
	fprintf('    L:         %-4d  // окно усреднения\n', L_cfs);
	fprintf('    D:         %-4d  // период между одинаковыми отсчётами\n', D_cfs);
	fprintf('    Offset:    %-4d  // смещение от отсчёта-оценки, полученного при CTS\n', ...
			startCFSSampleOffset);
	fprintf('    MaxEst:    e: %-4.2f  или  deltaF: %8.1f Гц  // максимально возможная оценка частотной остройки при данных параметрах\n\n', ...
			N_subcarrier / (2 * D_cfs), Fd / (2 * D_cfs));

	fprintf('  Алгоритм Fine Freq Synch\n');
	fprintf('    L:         %-4d  // окно усреднения\n', L_ffs);
	fprintf('    D:         %-4d  // период между одинаковыми отсчётами\n', D_ffs);
	fprintf('    Offset:    %-4d  // смещение от отсчёта-оценки, полученного при CTS\n', ...
			startFFSSampleOffset);
	fprintf('    MaxEst:    e: %-4.2f  или  deltaF: %8.1f Гц  // максимально возможная оценка частотной остройки при данных параметрах\n\n', ...
			N_subcarrier / (2 * D_ffs), Fd / (2 * D_ffs));

	fprintf('  Алгоритм Fine Time Synch\n');
	fprintf('    Offset:    %-4d  // смещение от отсчёта-оценки, полученного при CTS\n', ...
			startFTSSampleOffset);
	fprintf('    SegLength: %-4d  // кол-во отсчётов для которых выполняется алгоритм FTS\n', segmentFTSLen);
	fprintf('    SigLength: %-4d  // длина эталонного сигнала (с которым коррелируем)\n\n', length(etalonSig))


	fprintf('\n - - - - - - - - Р E З У Л Ь Т А Т   О Б Р А Б О Т К И - - - - - - - -\n');
	fprintf('(представленные ниже номера отсчётов соответствуют целому (необрезанному) файлу)\n');
	fprintf('  1) Signal Detection:  %d  // превышение порога произошло на этом отсчёте\n', ...
			signalDetectionSample + firstComplexSampleNo - 1);
	fprintf('  2) Coarse Time Synch: %d  // оценка номера первого отсчёта преамбулы\n', ...
			estCTO + firstComplexSampleNo - 1);
	fprintf('  3) Fine Time Synch:   %d  // оценка 193-его отсчёта преамбулы (первый отсчёт первого LTS)\n', ...
			estFTO + firstComplexSampleNo - 1);
	if strcmp(cfs_mode, 'make')
		fprintf('  4) Coarse Freq Synch: e == %6.3f  или  delfaF == %9.1f Гц\n', ...
				estCFO, estCFO * Fd / N_subcarrier');
	else
		fprintf('  4) Coarse Freq Synch: не выполнялась\n');
	end
	fprintf('  5) Fine Freq Synch:   e == %6.3f  или  delfaF == %9.1f Гц\n', ...
			estFFO, estFFO * Fd / N_subcarrier);
	fprintf('     Суммарный FO:      e == %6.3f  или  delfaF == %9.1f Гц\n', ...
			estCFO + estFFO, (estCFO + estFFO) * Fd / N_subcarrier);

end

