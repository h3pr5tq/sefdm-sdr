%%
% Модель формирования/приёма sefdm-символов
% При формировании добавляются нулевые поднесущие выполняющие роль DC и GI,
% а также свдиг спектра, чтобы он правильно располагался
%
% Демодулятор: MF; детектор: ID
%
% ДЛЯ QPSK НЕ ТЕ КРИВЫЕ ПОЛУЧАЕМ
% Почему-то BER немножко хуже получается?(

clear;
path(path, './functions/');
path(path, '../07_sefdm_init_model/functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

%%
% Исходные данные
alfa         = 13 / 16;
IFFT_size    = 32;
right_GI_len = 2;
left_GI_len  = 3;
EbNo         = 0 : 2 : 10; % дБ
N_iter       = 1e3; % кол-во итераций для получения маленьких BER
W            = 1024; % кол-во символов обрабатываемых за одну итерацию

modulation = 1; % 1 - BPSK or 2 - QPSK
detection_algorithm = @ID; % @ML or @ZF or @TSVD or @IC or @MF or @ID

N = IFFT_size * alfa; % Кол-во всех поднесущих за исключением "Add zero"
N_inf = N - right_GI_len - left_GI_len - 1; % Кол-во поднесущих под информацию (modulation_symbol)


%%
% Моделирование ...
form_const_for_detection_algorithm(N, N, alfa, modulation);

% Генерируем информацию
tx_bit = randi([0 1], modulation * N_inf * W, 1);
tx_bit = reshape(tx_bit, modulation * N_inf, W);

% Modulation Mapping
tx_modulation_sym = ConstellationMap(tx_bit, modulation);

% SEFDM Tx
tx_sefdm_sym = sefdm_modulator(tx_modulation_sym, ...
	alfa, IFFT_size, right_GI_len, left_GI_len);

% График энергетического спектра
tx_sefdm_stream = reshape(tx_sefdm_sym, 1, []);
[p_sefdm, f] = pwelch(tx_sefdm_stream, 500,300,500, 10e6, 'centered');
figure;
plot(f, 10*log10(p_sefdm));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;
clear tx_sefdm_stream p_sefdm f

% Канал с АБГШ, SEFDM Rx, Демодуляция, Детектирование
N_err_bit = zeros(1, length(EbNo));
Eb = sum( sum( abs(tx_sefdm_sym) .^ 2 ) ) / (modulation * N_inf * W);
for i = 1 : length(EbNo)

		fprintf('Modeling for Eb/No = %2d dB ...\n', EbNo(i));
        
        No = Eb / ( 10^(EbNo(i) / 10) );
        
        for j = 1 : N_iter

                % АБГШ (комплексный)
				noise = sqrt(No / 2) * ...
					( randn(N * W, 1) + 1i * randn(N * W, 1) );
				noise = reshape(noise, N, W);
                rx_sefdm_sym = tx_sefdm_sym + noise;

                % SEFDM Rx
				% MF демодулятор (получение статистик R) // Ahmed, p.115+ // Grammenos, p. 125+
				R = sefdm_MF_demodulator(rx_sefdm_sym, alfa, IFFT_size);

				% Детектирование
				rx_modulation_sym = detection_algorithm(R);

				% Извлечение информационных поднесущих с учётом защитных интервалов по частоте
				rx_modulation_sym = sefdm_post_demodulator(rx_modulation_sym);

				% De-mapping (hard desicion)
				rx_bit = ConstellationDemap(rx_modulation_sym, modulation);

				% Накапливаем ошибки
				N_err_bit(i) = N_err_bit(i) + ...
						biterr(tx_bit, rx_bit);

        end
end


%%
% Обработка результата
BER_exp = N_err_bit / (modulation * N_inf * W * N_iter);
if modulation == 1
	modulation_name = 'BPSK';
	BER_ofdm = berawgn(EbNo, 'psk', 2, 'nondiff');
elseif modulation == 2
	modulation_name = 'QPSK';
	BER_ofdm = berawgn(EbNo, 'qam', 4, 'nondiff');
end

figure;
graph = semilogy(EbNo, BER_exp, EbNo, BER_ofdm);
graph(1).Marker = '*';
graph(2).Marker = '^';
xlabel('Eb/No (dB)');
ylabel('BER');
legend('sefdm', 'ofdm');
grid on;

