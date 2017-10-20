%%
%
% Доделать алгоритм полный
%
% Разбить на скрипты отдельно каждый этап обработки, чтобы если что можно было промоделировать
% Сделатьб записи сигналов для излучения из ХАК РФ и приёма, чтобы на них затестить алгоритмы синхронизации!!!

%
% ДОБАВИТЬ НАКОПЛЕНИЕ СТАТИСТИКИ%: КАКОЙ НАДО ПОДУМАТь
% ПРОВЕРИТЬ ЕЩЁ (главное параметры отрезков проверить!)

%%
% Параметры
close all;
path(path, './functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

N_subcarrier = 64;
N_ofdm_sym   = 2;
N_bit        = N_ofdm_sym * N_subcarrier;
Fd           = 10 * 10^6; % Гц

N_iter      = 1e3; % кол-во итераций для накопления статистики
EbNo        = 0 : 5 : 10; % дБ
time_offset = 200;
deltaF      = [0 * 10^3, 50 * 10^3, 100 * 10^3]; % Гц, частотная отстройка


% Signal Detection (для подбора параметров использовать SignalDetectionModel.m)
% - автокорреляция сигнала со сдвинутой на 16 отсчётов копией ДО превышения порога
% Цель: обнаружить сигнал
L_detection = 64; % размер окна суммирования
D_detection = 16; % длина одного STS

% Зависит от параметров выше и Eb/No
% Подбираем по результатам моделирования SignalDetectionModel.m
sig_detection_threshold = 0.15;

% С отсчёта на котором произошло превышение порога, запускаем алгоритм CTS

% Coarse Time Synchronization
% - автокорреляция сигнала со сдвинутой на 16 отсчётов копией НА заданном отрезке и ПОИСК максимума на данном отрезке
% Цель: примерно привизаться к первому отсчёту
L_cts = 144; % размер окна суммирования
D_cts = 16; % длина одного STS

% Кол-во отсчётов для которых выполняется алгоритм CTS
% Цифру 60 получили по результатм моделирования SignalDetectionModel.m
segmentCTSLen = 160 + 60;

% Coarse Frequence Synchronization
L_cfs = 16;
D_cfs = 16;

% Смещение от оценки CTS для выполнения CFS
% Отрезок на котором выполняется CFS должны попадать ТОЛЬКО STS
startCFSSampleOffset = 15;

% Fine Frequence Synchronization
L_ffs = 64;
D_ffs = 64;
startFFSSampleOffset = startCFSSampleOffset;

% Fine Time Synchronization
% - корреляция с первыми 32 отсчётами LTS
startFTSSampleOffset = 160 + 32 - 20; % (10STS + LGI - x), где x оцениваем по моделированию CTS
segmentFTSLen = 40; % оцениваем по моделированию CTS; данный параметр связан с x
[ ~, etalonSig] = GenerateLTS('Rx'); etalonSig = etalonSig(1 : 32);


%%
% Модель
tx_bit = randi([0 1], 1, N_bit);

% BPSK
tx_bpsk_sym = complex( zeros(1, N_bit) );
tx_bpsk_sym(tx_bit == 1) = -1 + 1i * 0;
tx_bpsk_sym(tx_bit == 0) = +1 + 1i * 0;

% OFDM
tx_ofdm_sym = reshape(tx_bpsk_sym, N_subcarrier, N_ofdm_sym);
tx_ofdm_sym = ifft(tx_ofdm_sym, N_subcarrier);
tx_ofdm_sym = reshape(tx_ofdm_sym, 1, N_bit);

Eb = sum( abs(tx_ofdm_sym) .^ 2 ) / N_bit;

% Add preamble
STS = GenerateSTS('Rx');
LTS = GenerateLTS('Rx');
preamble = [STS, LTS];
txSig = [preamble, tx_ofdm_sym];

% AWGN + time_offset + freq_offset
for k = 1 : N_iter

	for j = 1 : length(deltaF)

		for i = 1 : length(EbNo)

			% Channel
			No = Eb / ( 10^(EbNo(i) / 10) );
% 			No = 0; % minus AWGN
			rxSig = [         sqrt(No / 2) * randn(1, time_offset)   + 1i * sqrt(No / 2) * randn(1, time_offset), ...
					  txSig + sqrt(No / 2) * randn(1, length(txSig)) + 1i * sqrt(No / 2) * randn(1, length(txSig)), ...
							  sqrt(No / 2) * randn(1, time_offset) +   1i * sqrt(No / 2) * randn(1, time_offset) ];
			rxSig = rxSig .* exp(1i * 2 * pi * deltaF(j) * (1 : length(rxSig)) / Fd);

			% Signal Detection
			[m, signalDetectionSample] = SignalDetection(rxSig, L_detection, D_detection, sig_detection_threshold);

			% Coarse Time Synch
			startCTSSample = signalDetectionSample;
			[ctsMetric, estCTO] = CoarseTimeSynch(rxSig, L_cts, D_cts, startCTSSample, segmentCTSLen );

			% Coarse Freq Synch
			startCFSSample = estCTO + startCFSSampleOffset;
			estCFO = FreqSynch(rxSig, L_cfs, D_cfs, startCFSSample, 'no');
			rxSig = rxSig .* exp( 1i * 2 * pi * estCFO * (1 : length(rxSig)) / N_subcarrier ); % компенсируем

			% Fine Freq Synch
			startFFSSample = estCTO + startFFSSampleOffset;
			estFFO = FreqSynch(rxSig, L_ffs, D_ffs, startFFSSample, 'no');
			rxSig = rxSig .* exp( 1i * 2 * pi * estFFO * (1 : length(rxSig)) / N_subcarrier ); % компенсируем

			% Fine Time Synch
			startFTSSample = estCTO + startFTSSampleOffset;
			[ftsMetric, estFTO] = FineTimeSynch(rxSig, etalonSig, startFTSSample, segmentFTSLen );


% 			if strcmp(graph_mode, 'display')
			figure;
			O_sample = 1 : length(m);
			hold on;
			plot(O_sample, m);
			stem(time_offset+1, 1.5); % первый отсчёт преамбулы
			stem(signalDetectionSample, 1.2); % отсчёт, на котором обнаружили сигнал
			hold off;
			grid on;
			xlabel('samples');
			ylabel('m = abs(AutoCorr).^2 ./ Energy.^2');
			title({ 'Signal Detection', ...
			        ['EbNo = ', num2str(EbNo(i)), ' dB'], ...
					['deltaF = ', num2str(deltaF(j)), ' Hz'] });
			legend('m', 'FirstSampleOfPreamble', 'SampleOfThresholdExcess');


			figure;
			hold on;
			O_sample = 1 + startCTSSample - 1 : length(ctsMetric) + startCTSSample - 1;
			plot(O_sample, ctsMetric);
			stem(time_offset + 1, 1.5); % первый отсчёт преамбулы
			stem(estCTO, 1.2); % оценка первого отсчёта преамбулы
			hold off;
			grid on;
			xlabel('samples');
			ylabel('m = abs(AutoCorr)');
			title({ 'Coarse Time Synch', ...
			        ['EbNo = ', num2str(EbNo(i)), ' dB'], ...
					['deltaF = ', num2str(deltaF(j)), ' Hz'] });
			legend('m', 'FirstSampleOfPreamble', 'Estimation==ResultOfCTS');


			figure;
			hold on;
			O_sample = 1 + startFTSSample - 1 : length(ftsMetric) + startFTSSample - 1;
			plot(O_sample, ftsMetric);
			stem(time_offset + 160 + 32 + 1, 0.5);
			stem(estFTO, 0.6); % оценка первого отсчёта преамбулы
			hold off;
			grid on;
			xlabel('samples');
			ylabel('m = abs(CrossCorr)');
			title({ 'Fine Time Synch', ...
			        ['EbNo = ', num2str(EbNo(i)), ' dB'], ...
					['deltaF = ', num2str(deltaF(j)), ' Hz'] });
			legend('m', 'FirstSampleOfPreamble', 'Estimation==ResultOfFTS');

			fprintf( '\n----------------------------------\n' );
			fprintf( 'EbNo = %d dB, FreqOffset = %d Hz, e = %f\n\n', EbNo(i), deltaF(j), deltaF(j) / (Fd/N_subcarrier) );
			fprintf( 'e     == %f\n', deltaF(j) / (Fd/N_subcarrier) );
			fprintf( 'e_cfo == %f\n', estCFO );
			fprintf( 'e_ffo == %f\n', estFFO );
			fprintf( 'e + e_cfo + e_ffo == %f (осталость некомпенсировано)', deltaF(j) / (Fd/N_subcarrier) + estCFO + estFFO );
			fprintf( '\n----------------------------------\n' );

			input('Press Enter to resume\n\n');
% 			end

		end

	end

end

