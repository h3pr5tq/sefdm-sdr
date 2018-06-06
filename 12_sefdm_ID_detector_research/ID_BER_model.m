%%
% SEFDM Rx:
%   Демодулятор - MF // Ahmed, p. 115+; Grammenos, p. 125+
%   Детекторы - ID

%
% ДЛЯ QPSK НЕ ТЕ КРИВЫЕ ПОЛУЧАЕМ
%

clear;
path(path, '../07_sefdm_init_model/functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

%%
% Исходные данные
alfa_         = 8 / 9; %[1/2, 2/3, 4/5, 8/9]; % 0.8
N_subcarrier_ = 16;%[16, 32, 48, 64];
nu_           = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
EbNo          = 8; % дБ
N_iter        = 1e3; % кол-во итераций для получения маленьких BER
W             = 1024; % кол-во символов обрабатываемых за одну итерацию

modulation = 1; % 1 - BPSK or 2 - QPSK
save_result = true; % true or false

if modulation == 1
	modulation_name = 'BPSK';
elseif modulation == 2
	modulation_name = 'QPSK';
end

for n = 1 : length(N_subcarrier_)

	N_subcarrier = N_subcarrier_(n);

	fprintf('Modeling for N = %d\n', N_subcarrier);

	for a = 1 : length(alfa_)

		alfa     = alfa_(a);
		DFT_size = N_subcarrier / alfa;
		%%
		% Моделирование ...
		assert( DFT_size - floor(DFT_size) == 0 && ...
				(alfa > 0 && alfa < 1), 'Bad alfa' );
		form_const_for_detection_algorithm(N_subcarrier, N_subcarrier, alfa, modulation);

		% Генерируем информацию
		tx_bit = randi([0 1], modulation * N_subcarrier * W, 1);
		tx_bit = reshape(tx_bit, modulation * N_subcarrier, W);

		% Modulation Mapping
		tx_modulation_sym = ConstellationMap(tx_bit, modulation);

		% SEFDM Tx
		tx_sefdm_sym = [ tx_modulation_sym; zeros(DFT_size - N_subcarrier, W) ]; % Добавили нули (передискретизация)
		tx_sefdm_sym = ifft(tx_sefdm_sym, DFT_size); % ОДПФ
		tx_sefdm_sym = tx_sefdm_sym(1 : N_subcarrier, :); % Усекаем (игнорируем лишние)

		% Канал с АБГШ, SEFDM Rx, Демодуляция, Детектирование
		N_err_bit = zeros(1, length(nu_));
		Eb = sum( sum( abs(tx_sefdm_sym) .^ 2 ) ) / (modulation * N_subcarrier * W);
		No = Eb / ( 10^(EbNo / 10) );

		for i = 1 : length(nu_)

			global nu;
			nu = nu_(i);

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
					rx_modulation_sym = ID(R);

					% De-mapping (hard desicion)
					rx_bit = ConstellationDemap(rx_modulation_sym, modulation);

					% Накапливаем ошибки
					N_err_bit(i) = N_err_bit(i) + ...
							biterr(tx_bit, rx_bit);

			end


		end
		BER_exp = N_err_bit / (modulation * N_subcarrier * W * N_iter);

		%%
		% Сохранение результата
		if save_result

			result.modulation_name        = modulation_name;
			result.N_subcarrier           = N_subcarrier;
			result.alfa                   = alfa;
			result.EbNo                   = EbNo;
			result.BER                    = BER_exp;
			result.nu                     = nu_;

			folder = 'results/';
			filename = [num2str(EbNo), '_', ...
				num2str(result.N_subcarrier), '_', ...
				num2str(result.alfa), '_', ...
				result.modulation_name, '.mat'];
			save([folder, filename], '-struct', 'result');

		end

	end

end
