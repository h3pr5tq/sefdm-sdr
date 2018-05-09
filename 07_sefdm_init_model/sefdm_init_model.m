%%
% SEFDM Rx:
%   Демодулятор - MF // Ahmed, p. 115+; Grammenos, p. 125+
%   Детекторы - ML, ZF, TSVD, IC, MF(only slicing), ID
%
% Внимание!
%   1) Алгоритм для ML-детектора зависит от используемого алгоритма демодулятора
%   2) Матрица в алгоритмах детекторов зависит от выбранного алгоритма демодулятора (Grammenos, p. 125+)

%
% ДЛЯ QPSK НЕ ТЕ КРИВЫЕ ПОЛУЧАЕМ
%

clear;
path(path, './functions/');
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

%%
% Исходные данные
alfa         = 4 / 5; % 0.8
N_subcarrier = 16;
EbNo         = 0 : 2 : 12; % дБ
N_iter       = 1e3; % кол-во итераций для получения маленьких BER
W            = 2048; % кол-во символов обрабатываемых за одну итерацию
DFT_size     = N_subcarrier / alfa;

modulation = 1; % 1 - BPSK or 2 - QPSK
detection_algorithm = @ID; % @ML or @ZF or @TSVD or @IC or @MF or @ID
save_result = false; % true or false


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
N_err_bit = zeros(1, length(EbNo));
Eb = sum( sum( abs(tx_sefdm_sym) .^ 2 ) ) / (modulation * N_subcarrier * W);
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
				rx_modulation_sym = detection_algorithm(R);

				% De-mapping (hard desicion)
				rx_bit = ConstellationDemap(rx_modulation_sym, modulation);

				% Накапливаем ошибки
				N_err_bit(i) = N_err_bit(i) + ...
						biterr(tx_bit, rx_bit);

        end
end


%%
% Обработка результата
BER_exp = N_err_bit / (modulation * N_subcarrier * W * N_iter);
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


%%
% Сохранение результата
if save_result

	result.demodulation_algorithm = 'MF';
	result.detection_algorithm    = func2str(detection_algorithm);
	result.modulation_name        = modulation_name;
	result.N_subcarrier           = N_subcarrier;
	result.alfa                   = alfa;
	result.EbNo                   = EbNo;
	result.BER                    = BER_exp;
	
	% Дополнительный "результат" в зависимости от используемого алгоритма детектирования
	switch result.detection_algorithm
	case 'ID'
		global nu;
		result.nu = nu;
		filename_suffix = ['_', num2str(result.nu)];
	case 'TSVD'
		global trunc_index;
		result.trunc_index = trunc_index;
		filename_suffix = ['_', num2str(result.trunc_index)];
	otherwise
		filename_suffix = [];
	end

	folder = 'results/';
	filename = [ 'MF_', result.detection_algorithm, '_', ...
		num2str(result.N_subcarrier), '_', ...
		num2str(result.alfa), '_', ...
		result.modulation_name, filename_suffix, '.mat'];
	save([folder, filename], '-struct', 'result');

end

