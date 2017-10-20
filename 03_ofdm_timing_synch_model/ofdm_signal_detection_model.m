%%
% Моделирование обнаружения сигнала (пакета)
% для случая канала с АБГШ (signal detection)
% (частотный сдвиг, многолучёвость и др. отсутствуют)
%
% OFMD_tx --> Channel --> OFDM_rx (only Signal Detecion)

%%
% И С Х О Д Н Ы Е   Д А Н Н Ы Е

% Добавление путей к написанным функциям
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');
path(path, './functions/');

len_pckt   = 10;
N_inf_sbcr = 48;
N_bit      = len_pckt * N_inf_sbcr;
GI_len     = 16;
EbNo       = 0 : 5 : 10; % дБ

Num_exprmnt = 1e3;
time_offset = 200;

% Для обнаружения сигнала
% (автокорреляция)
L = [32, 80, 144]; % размер окна суммирования
D = 16; % сдвиг копии с которой коррелируем

%%
% М О Д Е Л И Р О В А Н И Е ...

% Генерируем информацию
tx_bit = randi([0 1], 1, N_bit);

% OFDM Tx (передатчик)
[tx_ofdm_stream, ...
        prmbl, Eb] = OFDM_tx( tx_bit );

% К А Н А Л + П Р И Ё М Н И К

% Буферы под результат
% Значения актокорреляции (модуля) и нормированной автокорреляции
% при разных Eb/No и L
% ("c__" и "m__" соответствуют одиночному эксперименту,
% а "c__avg" и "m__avg" - усредённому результату)
c__ = zeros(length(EbNo), ...
            length(L), ...
            length(tx_ofdm_stream) + 2 * time_offset - min(L) - D + 1);
         
m__ = zeros(length(EbNo), ...
            length(L), ...
            length(tx_ofdm_stream) + 2 * time_offset - min(L) - D + 1);

c__avg = 0;
m__avg = 0;
    
for j = 1 : Num_exprmnt
        
        % Генерация шума с единичной дисперсией
        noise1 = randn_cmplx(1, time_offset);
        noise2 = randn_cmplx(1, length(tx_ofdm_stream));
        noise3 = randn_cmplx(1, time_offset);

        for i = 1 : length(EbNo) % по Eb/No

                No = Eb / ( 10^(EbNo(i) / 10) );

                for l = 1 : length(L) % по L - размер окна суммирования

                        % Канал с АБГШ + Временной сдвиг
                        rx_ofdm_stream = [ sqrt(No / 2) * noise1, ...
                                           sqrt(No / 2) * noise2 + tx_ofdm_stream, ...
                                           sqrt(No / 2) * noise3 ];

                        % Приёмник           

                        % Для определение наличия сигнала
                        [c, m] = autocorr_L_D(rx_ofdm_stream, L(l), D);

                        % Сравнение с порогом ...
                        %  ...

                        c__( i, l, 1 : length(c) ) = c;
                        m__( i, l, 1 : length(m) ) = m;      
                end
        end
        
        % Для получения усреднённого результата
        c__avg = c__avg + c__;
        m__avg = m__avg + m__;
end

c__avg = c__avg ./ Num_exprmnt;
m__avg = m__avg ./ Num_exprmnt;

%%
% В И З У А Л И З А Ц И Я   Р Е З У Л Ь Т А Т А
graph_signal_detection( c__,    m__,    EbNo, L, false );
graph_signal_detection( c__avg, m__avg, EbNo, L, true  );
