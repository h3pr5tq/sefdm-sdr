%%
% Моделирование системы передачи с OFDM-BPSK через канал с АБГШ
% Цель: получить график BER(Eb/No) для OFDM-BPSK
% График полученный в результате моделирования OFDM-BPSK должен совпадать
% с теоретическим графиком BER(Eb/No) для BPSK

%%
% Исходные данные
N_subcarrier = 64;
N_ofdm_sym   = 10;
N_bit        = N_ofdm_sym * N_subcarrier;
EbNo         = 0 : 10; % дБ
N_iter       = 1e4; % кол-во итераций для получения маленьких BER

%%
% Моделирование ...

% Генерируем информацию
tx_bit = randi([0 1], N_bit, 1);

% BPSK
tx_bpsk_sym = complex( zeros(N_bit, 1) );
tx_bpsk_sym(tx_bit == 1) = -1 + 1i * 0;
tx_bpsk_sym(tx_bit == 0) = +1 + 1i * 0;

% OFDM Tx
tx_bpsk_sym    = reshape(tx_bpsk_sym, N_subcarrier, N_ofdm_sym);
tx_ofdm_stream = ifft(tx_bpsk_sym, N_subcarrier);
tx_ofdm_stream = reshape(tx_ofdm_stream, N_bit, 1);

% Канал с АБГШ, OFDM Rx, Демодуляция
N_err_bit = zeros(1, length(EbNo));
rx_bit    = zeros(N_bit, 1);

Eb = sum( abs(tx_ofdm_stream) .^ 2 ) / N_bit;

for i = 1 : length(EbNo)
        
        No = Eb / ( 10^(EbNo(i) / 10) );
        
        for j = 1 : N_iter

                % АБГШ (комплексный)
                rx_ofdm_stream = tx_ofdm_stream + ...
                        sqrt(No / 2) * randn(length(tx_ofdm_stream), 1) + ...
                        1i * sqrt(No / 2) * randn(length(tx_ofdm_stream), 1);

                % OFDM Rx
                rx_ofdm_stream = reshape(rx_ofdm_stream, N_subcarrier, N_ofdm_sym);
                rx_bpsk_sym    = fft(rx_ofdm_stream, N_subcarrier);
                rx_bpsk_sym    = reshape(rx_bpsk_sym, N_bit, 1);

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