%%
% SEFDM Rx:
%   Демодулятор - MF // Ahmed, p. 115+; Grammenos, p. 125+
%   Детекторы - ML, ZF, TSVD, IC, MF(slicing)
%
% Внимание!
%   1) Алгоритм для ML-детектора зависит от используемого алгоритма демодулятора
%   2) Матрица в алгоритмах детекторов зависит от выбранного алгоритма демодулятора (Grammenos, p. 125+)

clear;
path(path, './functions/');

%%
% Исходные данные
alfa         = 4 / 5; % 0.8
N_subcarrier = 16;
EbNo         = 0 : 2 : 10; % дБ
N_iter       = 1e3; % кол-во итераций для получения маленьких BER
W            = 4096; % кол-во символов обрабатываемых за одну итерацию
DFT_size     = N_subcarrier / alfa;

detection_algorithm = @IC; % @ML or @ZF or @TSVD or @IC or @MF
save_result = true; % true or false

%%
% Моделирование ...

assert( DFT_size - floor(DFT_size) == 0 && ...
        (alfa > 0 && alfa < 1), 'Bad alfa' );
form_const_for_detection_algorithm(N_subcarrier, N_subcarrier, alfa);

% Генерируем информацию
tx_bit = randi([0 1], N_subcarrier * W, 1);
tx_bit = reshape(tx_bit, N_subcarrier, W);

% BPSK
tx_bpsk_sym = complex( zeros(N_subcarrier, W) );
tx_bpsk_sym(tx_bit == 1) = -1 + 1i * 0;
tx_bpsk_sym(tx_bit == 0) = +1 + 1i * 0;

% SEFDM Tx
tx_sefdm_sym = [ tx_bpsk_sym; zeros(DFT_size - N_subcarrier, W) ]; % Добавили нули (передискретизация)
tx_sefdm_sym = ifft(tx_sefdm_sym, DFT_size); % ОДПФ
tx_sefdm_sym = tx_sefdm_sym(1 : N_subcarrier, :); % Усекаем (игнорируем лишние)

% Канал с АБГШ, SEFDM Rx, Демодуляция, Детектирование
N_err_bit = zeros(1, length(EbNo));
Eb = sum( sum( abs(tx_sefdm_sym) .^ 2 ) ) / (N_subcarrier * W);
for i = 1 : length(EbNo)

		fprintf('Modeling for Eb/No = %2d dB ...\n', EbNo(i));
        
        No = Eb / ( 10^(EbNo(i) / 10) );
        
        for j = 1 : N_iter

                % АБГШ (комплексный)
				noise = sqrt(No / 2) * ...
					( randn(N_subcarrier * W, 1) + 1i * randn(N_subcarrier * W, 1) );
				noise = reshape(noise, N_subcarrier, W);
                rx_sefdm_sym = tx_sefdm_sym + noise;

                % SEFDM Rx
				% MF демодулятор (получение статистик R) // Ahmed, p.115+ // Grammenos, p. 125+
				R = [ rx_sefdm_sym; zeros(DFT_size - N_subcarrier, W) ]; % Добавили нули
                R = fft(R, DFT_size);
				R = R(1 : N_subcarrier, :); % Усекаем (игнорируем лишние)

				% Детектирование
				rx_bit = detection_algorithm(R);

				% Накапливаем ошибки
				N_err_bit(i) = N_err_bit(i) + ...
						biterr(tx_bit, rx_bit);

        end
end


%%
% Обработка результата
BER_exp   = N_err_bit / (N_subcarrier * W * N_iter);
BER_ofdm = berawgn(EbNo, 'psk', 2, 'nondiff');

figure;
graph = semilogy(EbNo, BER_exp, EbNo, BER_ofdm);
graph(1).Marker = '*';
graph(2).Marker = '^';
xlabel('Eb/No (dB)');
ylabel('BER');
legend('sefdm', 'ofdm');
grid on;


%%
% Сохранение результата
if save_result
	folder = 'results/';
	filename = ['MF_', func2str(detection_algorithm), '_', num2str(N_subcarrier), '_', num2str(alfa), '.mat'];
	result.demodulation_algorithm = 'MF';
	result.detection_algorithm    = func2str(detection_algorithm);
	result.N_subcarrier           = N_subcarrier;
	result.alfa                   = alfa;
	result.EbNo                   = EbNo;
	result.BER                    = BER_exp;
	save([folder, filename], '-struct', 'result');
end

