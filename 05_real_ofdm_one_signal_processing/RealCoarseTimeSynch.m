%%
% Real Coarse Time Synch
%

%%
%
path(path, '../04_ofdm_time_freq_synch_model/functions/');

%%
%
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_prmbl_5000_3.dat';


% Алгоритм CTS
L_cts = 144; % размер окна суммирования
D_cts = 16; % длина одного STS

% Первое число - отсчёт,на котором SD,
% второе число - сколько отсчётов откатить назад, на случай если превышение порога произошло не до начала преамбулы, а внутри её
startCTSSample = 820587 - 50; % 1 - с самого начала файла

% кол-во отсчётов для которых выполняется алгоритм CTS; 0 - значит для всех
% 160 - длина STS, первые 50 компенсируют 50 сверху, вторые 50 - если превышение порого произошло до начало преамбулы
% (что по результатм моделирования намного вероятнее)
segmentCTSLen  = 160 + 50 + 50;  % 0 - для всех отчётов файла


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


% Coarse Time Synch
[ctsMetric, estCTO] = CoarseTimeSynch(rxSig, L_cts, D_cts, startCTSSample, segmentCTSLen );

% График
Graph_CoarseTimeSynch(ctsMetric, estCTO, startCTSSample, firstComplexSampleNo);

fprintf('Грубая временная синхронизация. Результат:\n');
fprintf('певый отсчёт преамбулы - %d (номер отчёта относительно filename)\n', estCTO);
