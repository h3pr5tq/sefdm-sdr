%%
% Real Signal Detection
%
% Фиговая работа алгоритма связана с присутсвием постоянной составляющей в сигнале!!!
% DC-offset! Фиксится, например, ФВЧ. Однако, если присутсвует сильная помеха,
% то работаспособность алгоритма также резко падает 
% Надо мб другой алгоритм
%

%%
%

path(path, '../04_ofdm_time_freq_synch_model/functions/');
path(path, './functions/');

%%
%
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_randi_20ofdm_11.dat';

truncate_mode = 'truncate'; % 'truncate' or 'no_truncate'
firstComplexSampleNo = 100e3;
endComplexSampleNo   = 105e3;

% Алгоритм обнаружения
L_detection = 144; % размер окна суммирования
D_detection = 16; % длина одного STS
sig_detection_threshold = 0.93; % надо подбирать

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

