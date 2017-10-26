%%
% Real Fine Time Synch
%

%%
%
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');
path(path, '../04_ofdm_time_freq_synch_model/functions/');

%%
%
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_prmbl_5000_3.dat';

estCTO = 820589; % Оценка CTS (выполняется до FFS)
estCFO = -0.065990; % Оценка CFS (выполняется до FFS)
estFFO = 0.076750; % Оценка FFS
estFO = estCFO + estFFO; % суммарный FO

% Алгоритм FTS
startFTSSampleOffset = 160 + 32 - 20; % (10STS + LGI - x), где x оцениваем по моделированию CTS
segmentFTSLen = 40; % оцениваем по моделированию CTS; данный параметр связан с x
[ ~, etalonSig] = GenerateLTS('Rx'); etalonSig = etalonSig(1 : 32);

N_subcarrier = 64;

%%
% Обработка

% Принятый сигнал
fd = fopen(filename, 'r');
if fd == -1
    error('File is not opened');  
end
rxSig = fread(fd, [1, inf], 'float32=>double');
rxSig = rxSig(1 : 2 : end) + 1i * rxSig(2 : 2 : end);
fclose(fd);


% Fine Time Synch
rxSig = rxSig .* exp( 1i * 2 * pi * estFO * (1 : length(rxSig)) / N_subcarrier ); % компенсируем FO
startFTSSample = estCTO + startFTSSampleOffset;
[ftsMetric, estFTO] = FineTimeSynch(rxSig, etalonSig, startFTSSample, segmentFTSLen );

% График
Graph_FineTimeSynch(ftsMetric, estFTO, startFTSSample, firstComplexSampleNo);

fprintf('Результат ((номер отчётов относительно filename)):\n');
fprintf('Грубая временная синхронизация - %d (первый отчёт преамбулы)\n', estCTO);
fprintf('Точная временная синхронизация - %d (193ий отчёт преамбулы)\n', estFTO);
