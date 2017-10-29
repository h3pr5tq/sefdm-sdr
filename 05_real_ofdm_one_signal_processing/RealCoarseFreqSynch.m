%%
% Real Coarse Freq Synch
%
% Для компенсации надо домножить на exp( 1i * 2 * pi * estCFO * (1 : length(rxSig)) / N_subcarrier ),
% где estCFO - результат алгоритма
% С кого отсчёта начинать компенсировать - практически без разница (главное чтобы он был значимый, т.е. тот который будем
% по итогу демодулировать/учитывать при синхронизации и т.п.), в любом случае получим фазовый набег (суммарный 
% результат воздейсвтия частотной отстройки до отсчёта с которого начинается компенсация и не только!)!!!

%%
%
path(path, '../04_ofdm_time_freq_synch_model/functions/');

%%
%
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_prmbl_5000_3.dat';

estCTO = 820589; % Оценка CTS (выполняется до CFS)

% Алгоритм CFS
L_cfs = 16;
D_cfs = 16;
roundToInteger = 'no'; % 'yes' or 'no' округлять до целого в сторону нуля или нет ?? МБ ВАЩЕ НАФИГ ???
% Смещение от оценки CTS для выполнения CFS
% Отрезок на котором выполняется CFS должны попадать ТОЛЬКО STS
% (на случай если estCTO оказалась до преамбулы)
startCFSSampleOffset = 15;

N_subcarrier = 64;
Fd           = 10 * 10^6;

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


% Coarse Freq Synch
startCFSSample = estCTO + startCFSSampleOffset;
estCFO = FreqSynch( rxSig, L_cfs, D_cfs, startCFSSample, roundToInteger);


% Результат
fprintf('\nИспользуются:\n');
fprintf('  N_fft          = %d\n', N_subcarrier);
fprintf('  F_d            = %d Гц\n', Fd);
fprintf('  L_cfs          = %d (размер окна суммирования - определяет точность)\n', L_cfs);
fprintf('  D_сfs          = %d (величина сдвига - определяет диапазон)\n\n', D_cfs);
fprintf('  deltaF_subcarr = %d Гц (расстояние между поднесущими)\n\n', Fd / N_subcarrier);
fprintf('Алгоритм CFS округляет оценку (e) до целого в сторону нуля?: %s\n\n', roundToInteger);
fprintf('Максимально возможная оценка частотной остройки при данных параметрах следующая:\n');
fprintf('e      = %.3f (относительная частотная отстройка)\n', N_subcarrier / (2 * D_cfs));
fprintf('deltaF = %.3f Гц (частотная отстройка)\n', Fd / (2 * D_cfs));

fprintf('Перевод из "e" в Гц: e*Fd/N_fft == e*%.2f\n\n', Fd / N_subcarrier);

fprintf('Результат estCFO: e == %f ил delfaF == %f Гц\n', estCFO, estCFO * Fd / N_subcarrier);
