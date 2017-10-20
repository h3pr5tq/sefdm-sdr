%%
% Моделирование системы передачи с OFDM-BPSK через канал с АБГШ
%
% Данный скрипт - аналог ofdm_init_model.m, разница только в том,
% что в данном скрипте передатчик/приёмник приближены к 802.11a
%
% Цель: тестирование написанных функций, частично реализующих PHY 802.11a

%%
% Исходные данные
len_pckt   = 10;
N_inf_sbcr = 48;
N_bit      = len_pckt * N_inf_sbcr;
EbNo       = 0 : 10; % дБ
N_iter     = 1e4; % кол-во итераций для получения маленьких BER

%%
% Моделирование ...

% Добавление путей к написанным функциям
path(path, './ofdm_phy_802_11a/');

% Генерируем информацию
tx_bit = randi([0 1], 1, N_bit);

% OFDM Tx (передатчик)
[tx_ofdm_stream, ...
        prmbl, Eb] = OFDM_tx( tx_bit );

% Канал с АБГШ, OFDM Rx, Демодуляция
N_err_bit = zeros(1, length(EbNo));
rx_bit    = zeros(1, N_bit);
for i = 1 : length(EbNo)
        
        No = Eb / ( 10^(EbNo(i) / 10) );
        
        for j = 1 : N_iter

                % АБГШ (комплексный)
                rx_ofdm_stream = tx_ofdm_stream + ...
                        sqrt(No / 2) * randn(1, length(tx_ofdm_stream)) + ...
                        1i * sqrt(No / 2) * randn(1, length(tx_ofdm_stream));

                % OFDM Rx
                rx_ofdm_stream = rx_ofdm_stream( length(prmbl) + 1 : end ); % откинули преамбулу
                rx_ofdm_stream = Del_GI(rx_ofdm_stream);
                rx_bpsk_sym    = Constellate_From_OFDMSymbols(rx_ofdm_stream);

                % Демодуляция
                rx_bit( real(rx_bpsk_sym) >  0 ) = 0;
                rx_bit( real(rx_bpsk_sym) <= 0 ) = 1;

                % Накапливаем ошибки
                N_err_bit(i) = N_err_bit(i) + ...
                        biterr(tx_bit, rx_bit);
        end
end

%%
% Обработка результатов
BER_exp   = N_err_bit / (N_bit * N_iter);
BER_theor = berawgn(EbNo, 'psk', 2, 'nondiff');

graph = semilogy(EbNo, BER_exp, EbNo, BER_theor);
graph(1).Marker = '*';
graph(2).Marker = '^';
xlabel('Eb/No (dB)');
ylabel('BER');
legend('model', 'theor');
grid on;
