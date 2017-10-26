%%
% Real Signal Detection
%
% По графику можно обратить внимание, скорее всего, на работа AGC модуля:
% автокорреляция шума довольно большая (из-за AGC, а не из-за маленькой Eb/No, надо аккуратнее с подбором порога.
% НЕЕ фигня. Просто нормируем на малую величину, поэтому такое получаем. AGC не причём
%

%%
%

path(path, '../04_ofdm_time_freq_synch_model/functions/');

%%
%
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_prmbl_5000_3.dat';

truncate_mode = 'truncate'; % 'truncate' or 'no_truncate'
firstComplexSampleNo = 8 * 10^5;
endComplexSampleNo   = 8.5 * 10^5;

% Алгоритм обнаружения
L_detection = 144; % размер окна суммирования
D_detection = 16; % длина одного STS
sig_detection_threshold = 0.95; % надо подбирать

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

% Обрезаем
if strcmp(truncate_mode, 'truncate')
	rxSig = rxSig(firstComplexSampleNo : endComplexSampleNo);
else
	firstComplexSampleNo = 1;
	endComplexSampleNo   = length(rxSig);
end

% Signal Detection
[m, signalDetectionSample] = SignalDetection(rxSig, L_detection, D_detection, sig_detection_threshold);

% По оси X номера отсчётов отсносительно заданного входного файла (filename)
Graph_SignalDetection(m, signalDetectionSample, firstComplexSampleNo);
fprintf('Превышение порога произошло на отчёте: %d (номер отчёта относительно filename)\n', signalDetectionSample + firstComplexSampleNo - 1);

