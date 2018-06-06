%%
% Передавались пакеты с одинаковой полезной нагрузкой
% filename_rx_bits - содержит 0 и 1 типа uint8/int8
% содержит полезную нагрузку пакета + первые @sym_n_inf_subcarr содердат порядковый номер пакета
% Возможны ошибки в порядковом номере пакета

%%
% Параметры пакета
clear;
path(path, './functions/');

pld_n_sym         = 20; % Кол-во sefdm-символов в полезной нагрузке
sym_n_inf_subcarr = 20; % кол-во поднесущих с информацией
modulation        = 1; % 1 - 'bpsk'

filename_tx_bits = '../08_sefdm_generate_packets/bits/information_bits.mat'; % variable "bit"
filename_rx_bits = [ '/home/ivan/Documents/Signals/5_rx_sefdm_26.05.18/', ...
	'rx_sefdm__pckt_20000_1000__hdr_6_6__pld_20_6__sym_28_26_20_3_2_bpsk__z_100000__n_0__.dat' ];

no_pld_len = (1 + pld_n_sym) * sym_n_inf_subcarr;

%%
% Эталонные биты
load(filename_tx_bits);
n_bit_in_pld = modulation * sym_n_inf_subcarr * pld_n_sym;
tx_pld_bit = bit(1 : n_bit_in_pld);

%%
% Принятые биты
fd = fopen(filename_rx_bits, 'rb');
if (fd == -1)
	error('File is not opened');  
end
[raw_rx_bit, raw_rx_bit_len] = fread(fd, Inf, 'uint8');
fclose(fd);
if mod(raw_rx_bit_len, no_pld_len) ~= 0
	fprintf('Кол-во бит в файле не кратно длине "no+payload"\n');
	return;
else
	n_rx_pckt = raw_rx_bit_len / no_pld_len;
	n_rx_bit  = n_rx_pckt * n_bit_in_pld;
	fprintf('Кол-во принятых пакетов: %d\n', n_rx_pckt);
	fprintf('Кол-во принятых информационных бит: %d\n', n_rx_bit);
end

%%
% Анализ принятых бит
for i = 1 : n_rx_pckt

	rx_no_bit  = raw_rx_bit( (1 : sym_n_inf_subcarr) + ...
		(i - 1) * no_pld_len );
	rx_pld_bit = raw_rx_bit( (sym_n_inf_subcarr + 1 : sym_n_inf_subcarr + pld_n_sym * sym_n_inf_subcarr) + ...
		(i - 1) * no_pld_len );

	res{1, 1}(i, 1) = bi2de(rx_no_bit.', 'left-msb'); % Номер i-ого пакета
	res{2, 1}{i, 1} = rx_pld_bit;                     % Столбец принятых бит i-ого пакета
	res{3, 1}(i, 1) = biterr(tx_pld_bit, rx_pld_bit); % Кол-во ошибок в i-ом пакете
	res{4, 1}{i, 1} = find(tx_pld_bit ~= rx_pld_bit); % Столбец индексов ошибочных бит i-ого пакета

end

% analyze_packet_no(res);
analyze_err_bit(res);

n_err_bit = sum(res{3, 1});
BER = n_err_bit / n_rx_bit;
fprintf('Кол-во ошибочных бит: %d\n', n_err_bit);
fprintf('BER: %f\n', BER);
fprintf('BER: %e\n', BER);

