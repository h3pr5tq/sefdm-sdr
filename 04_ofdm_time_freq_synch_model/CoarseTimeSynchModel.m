%%
% Coarse Time Synchronization

%%
% Параметры
path(path, './functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

N_subcarrier = 64;
N_ofdm_sym   = 2;
N_bit        = N_ofdm_sym * N_subcarrier;
Fd           = 10 * 10^6;

window_mode = 'no_window_overlap'; % 'window_overlap' or 'no_window_overlap' // параметр ПРЕАМБУЛЫ
graph_mode  = 'display'; % 'dispaly' or 'no_display'

N_iter      = 1e3; % кол-во итераций для накопления статистики
EbNo        = 0 : 5 : 10; % дБ
time_offset = 200;
deltaF      = 0 : 50 * 10^3 : 100 * 10^3; % Гц, частотная отстройка

% Алгоритм CTS
L_cts = 144; % размер окна суммирования
D_s = 16; % длина одного STS
startAlgorithmSample = time_offset - time_offset + 1; % отсчёт с которого стартует алгоритм CTS
segmentLen = 0; % кол-во отсчётов для которых выполняется алгоритм CTS; // 0 - значит для всех отсчётов сгенерированного сигнала

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
if strcmp(window_mode, 'window_overlap')

	STS = GenerateSTS('Tx');
	LTS = GenerateLTS('Tx');
	preamble = [ STS(1 : end  - 1), ... % STS
	             STS(end) + LTS(1), LTS(2 : end - 1), ... % LTS // с учётом перекрытия
	             LTS(end) ]; % кусок перекрытия для следующего OFDM-символа
	txSig = [ preamble(1 : end - 1), ... % преамбула
	          preamble(end) + 0.5 * tx_ofdm_sym(1), tx_ofdm_sym(2 : end)]; % полезная нагрузка с учётом перекрытия

else % strcmp(window_mode, 'no_window_overlap')

	STS = GenerateSTS('Rx');
	LTS = GenerateLTS('Rx');
	preamble    = [STS, LTS];
	txSig = [preamble, tx_ofdm_sym]; % полезная нагрузка с учётом перекрытия

end


% AWGN + time_offset + freq_offset
estCTO_3d = zeros(N_iter, length(deltaF), length(EbNo));
for k = 1 : N_iter

	for j = 1 : length(deltaF)

		for i = 1 : length(EbNo)

			No = Eb / ( 10^(EbNo(i) / 10) );
		% 	No = 0; % minus AWGN

			rxSig = [         sqrt(No / 2) * randn(1, time_offset)   + 1i * sqrt(No / 2) * randn(1, time_offset), ...
					  txSig + sqrt(No / 2) * randn(1, length(txSig)) + 1i * sqrt(No / 2) * randn(1, length(txSig)), ...
							  sqrt(No / 2) * randn(1, time_offset) +   1i * sqrt(No / 2) * randn(1, time_offset) ];
			rxSig = rxSig .* exp(1i * 2 * pi * deltaF(j) * (1 : length(rxSig)) / Fd);

			% Coarse Timing Synch
			[metric, estCTO] = CoarseTimeSynch(rxSig, L_cts, D_s, startAlgorithmSample, segmentLen );

			if strcmp(graph_mode, 'display')
				O_sample = 1 : length(metric);
				figure;
				hold on;
				plot(O_sample, metric);
				stem(time_offset+1, 1.5); % первый отсчёт преамбулы
				stem(estCTO, 1.2); % оценка первого отсчёта преамбулы
				hold off;
				grid on;
				xlabel('samples');
				ylabel('m = abs(AutoCorr)');
				title({ ['EbNo = ', num2str(EbNo(i)), ' dB'], ...
				        ['deltaF = ', num2str(deltaF(j)), ' Hz'] });
				legend('m', 'FirstSampleOfPreamble', 'Estimation==ResultOfCTS');
				
				input('Press Enter to resume\n\n');
			end

			estCTO_3d(k, j, i) = estCTO;

		end

	end

end


%%
% Инфа по распределению оценок CTS (нулю соответствует, что синхронизация получилась идеальной)
estCTO_3d = estCTO_3d - time_offset - 1;
for j = 1 : length(deltaF)

	figure;

	for i = 1 : length(EbNo) 
		
		subplot(length(EbNo), 1, i);
		ar_1d = reshape(estCTO_3d(:, j, i), 1, []); 
		hist(ar_1d, min(ar_1d) : max(ar_1d));
		xlabel('smpls');
		title({ ['EbNo = ', num2str(EbNo(i)), ' dB'], ...
				['deltaF = ', num2str(deltaF(j)), ' Hz'] });
		grid on;

	end
end

