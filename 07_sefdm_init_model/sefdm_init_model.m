%%
% SEFDM Rx:
%   Демодулятор - MF // Ahmed, p. 115+; Grammenos, p. 125+
%   Детекторы - ML, ZF, TSVD, IC
%
% Внимание!
%   1) Алгоритм для ML-детектора зависит от используемого алгоритма демодулятора
%   2) Матрица в алгоритмах детекторов зависит от выбранного алгоритма демодулятора (Grammenos, p. 125+)

clear;

%%
% Исходные данные
alfa         = 4 / 5; % 0.8
N_subcarrier = 4;
DFT_size     = N_subcarrier / alfa;
N_bit        = N_subcarrier;
EbNo         = 0 : 2 : 10; % дБ

N_iter       = 1e4; % кол-во итераций для получения маленьких BER

% using_detectors = {'ML', 'ZF', 'TSVD', 'IC'}; % 'ML', 'ZF', 'TSVD', 'IC'
detection_algorithm = {@ZF};



%%
% Моделирование ...

assert( DFT_size - floor(DFT_size) == 0, 'Bad alfa' );
form_const_for_detection_algorithm(N_subcarrier, N_subcarrier, alfa);

% Генерируем информацию
tx_bit = randi([0 1], N_bit, 1);

% BPSK
tx_bpsk_sym = complex( zeros(N_bit, 1) );
tx_bpsk_sym(tx_bit == 1) = -1 + 1i * 0;
tx_bpsk_sym(tx_bit == 0) = +1 + 1i * 0;

% SEFDM Tx
tx_sefdm_sym = [ tx_bpsk_sym; zeros(DFT_size - N_subcarrier, 1) ]; % Добавили нули (передискретизация)
tx_sefdm_sym = ifft(tx_sefdm_sym, DFT_size); % ОДПФ
tx_sefdm_sym = tx_sefdm_sym(1 : N_subcarrier); % Усекаем (игнорируем лишние)

% Канал с АБГШ, SEFDM Rx, Демодуляция, Детектирование
N_err_bit = zeros(1, length(EbNo));
rx_bit    = zeros(N_bit, 1);

Eb = sum( abs(tx_sefdm_sym) .^ 2 ) / N_bit;


for i = 1 : length(EbNo)
        
        No = Eb / ( 10^(EbNo(i) / 10) );
        
        for j = 1 : N_iter

                % АБГШ (комплексный)
                rx_sefdm_sym = tx_sefdm_sym + ...
                        sqrt(No / 2) * randn(length(tx_sefdm_sym), 1) + ...
                        1i * sqrt(No / 2) * randn(length(tx_sefdm_sym), 1);

                % SEFDM Rx
				% MF демодулятор (получение статистик R) // Ahmed, p.115+ // Grammenos, p. 125+
				R = [ rx_sefdm_sym; zeros(DFT_size - N_subcarrier, 1) ]; % Добавили нули
                R = fft(R, DFT_size);
				R = R(1 : N_subcarrier); % Усекаем (игнорируем лишние)

				% Детектирование
				rx_bit = ZF(R);
% 				rx_bit = TSVD(R);
% 				rx_bit = IC(R);
% 				rx_bit = ML(R);

				% Накапливаем ошибки
				N_err_bit(i) = N_err_bit(i) + ...
						biterr(tx_bit, rx_bit);

%                 % ML детектор (Внимание! Алгоритм зависит от используемого демодулятора)
% 				rx_bpsk_sym = [];
% 				for l = 1 : size(R, 2) % по SEFDM-символам пакета/посылки
% 
% 					min = Inf;
% 					for k = 1 : size(CS, 2) % по эталонам
% 
% 						est = sum( abs(inverse_herm_F * (R(:, l) - CS(:, k))).^2 );
% % 						est = sum( abs(1 * (R(:, l) - CS(:, k))).^2 );
% 
% 
% 						if (est < min)
% 							min = est;
% 							S_est = S(:, k);
% 						end
% 
% 					end
% 
% 					rx_bpsk_sym = [rx_bpsk_sym; S_est];
% 
% 				end

% 				% ZF детектор (Внимание! Алгоритм зависит от используемого демодулятора)
% 				rx_bpsk_sym = [];
% 				for l = 1 : size(R, 2) % по SEFDM-символам пакета/посылки
% 
% 					S_est = inverse_C * R(:, l);
% 					rx_bpsk_sym = [rx_bpsk_sym; S_est];
% 
% 				end

% 				% TSVD детектор (Внимание! Алгоритм зависит от используемого демодулятора)
% 				rx_bpsk_sym = [];
% 				for l = 1 : size(R, 2) % по SEFDM-символам пакета/посылки
% 
% 					S_est = trunc_C * R(:, l);
% 					rx_bpsk_sym = [rx_bpsk_sym; S_est];
% 
% 				end

% 				% BPSK de-mapping
% 				rx_bit( real(rx_bpsk_sym) >  0 ) = 0;
%                 rx_bit( real(rx_bpsk_sym) <= 0 ) = 1;

% 				% IC детектор (Внимание! Алгоритм зависит от используемого демодулятора)
% 				rx_bit = [];
% 				S_est = zeros(N_subcarrier, 1);
% 				for l = 1 : size(R, 2) % по SEFDM-символам пакета/посылки
% 
% 					R_ = R(:, l);
% 
% 					% Первая итерация
% 					m = N_subcarrier;
% 					S_est(m) = R_(m) / C_(m, m);
% 					S_est(m) = real(S_est(m)) <= 0; % slicing == bpsk de-mapping
% 					
% 					% Остальные итерации
% 					for m = N_subcarrier - 1 : -1 : 1
% 						
% 						summation = ...
% 							sum( C_(m, m + 1 : N_subcarrier) .* S_est(m + 1 : N_subcarrier).' );
% 						S_est(m) = 1 / C_(m, m) * (R_(m) - summation);
% 						S_est(m) = real(S_est(m)) <= 0;
% 
% 					end
% 					rx_bit = [rx_bit; S_est];
% 
% 				end


        end
end

%%
% Обработка результатов
BER_exp   = N_err_bit / (N_bit * N_iter);
BER_ofdm = berawgn(EbNo, 'psk', 2, 'nondiff');

figure;
graph = semilogy(EbNo, BER_exp, EbNo, BER_ofdm);
graph(1).Marker = '*';
graph(2).Marker = '^';
xlabel('Eb/No (dB)');
ylabel('BER');
legend('sefdm', 'ofdm');
grid on;