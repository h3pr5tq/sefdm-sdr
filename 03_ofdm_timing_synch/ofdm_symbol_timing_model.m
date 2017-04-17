%%
% Моделирование временной синхронизации, а именно symbol timing
% при приёме для случая канала с АБГШ (частотная отстройка,
% многолучёвость и др. - не учитываются, т.е. отсутствуют)
%
% Структура передаваемого пакета (burst) близка к 802.11a
%
% Алгоритм синхронизации: взаимная корреляция принимаемого сигнала
% с Long Training Symbols
% Метрика: максимум квадрата модуля взаимной корреляции

%%
% Исходные данные

% Добавление путей к написанным функциям
path(path, '../common/');
path(path, '../ofdm_phy_802_11a/');
path(path, '../graph/');
path(path, './using_functions/');

len_pckt   = 10;
N_inf_sbcr = 48;
N_bit      = len_pckt * N_inf_sbcr;
GI_len     = 16;
EbNo       = [-5, 0, 5, 10]; % дБ

Num_exprmnt = 1e3;
time_offset = 200;

% Для определения начала OFDM-символа пакета
% (взаимная корреляция)
t = Generate_LongSymbols; % с ним коррелируем

%%
% Моделирование ...

% Генерируем информацию
tx_bit = randi([0 1], 1, N_bit);

% OFDM Tx (передатчик)
[tx_ofdm_stream, ...
        prmbl, Eb] = OFDM_tx( tx_bit );

% Индекс первого отсчёта первого Long Training Symbol'а преамбулы
% передаваемого пакета (зная данный индекс и структуру пакета,
% можно определить начало OFDM-символа)
start_LngTrSym = time_offset + 160 + 32 + 1;

% К А Н А Л + П Р И Ё М Н И К

% 2d массив с оценками symbol timing
% Каждая строка - оценки symbol timing
% для одного определённого Eb/No
start_LngTrSym_est = zeros(length(EbNo), Num_exprmnt);

% 2d массив со значениями взаимной корреляции (квадрат модуля)
% при разных Eb/No
% Каждая строка - результат нахождения взаимной корреляции
% для данного Eb/No
% Один массив соответствует одному экперименту
p_ = zeros( length(EbNo), length(tx_ofdm_stream) + 2 * time_offset ...
                          - length(t) + 1 );

% 2d массив со усреднёнными значениями
% взаимной корреляции (квадрата модуля)
% при разных Eb/No
p_avg = 0;

for j = 1 : Num_exprmnt
        
        % Генерация шума с единичной дисперсией
        noise1 = randn_cmplx(1, time_offset);
        noise2 = randn_cmplx(1, length(tx_ofdm_stream));
        noise3 = randn_cmplx(1, time_offset);

        for i = 1 : length(EbNo) % по Eb/No

                No = Eb / ( 10^(EbNo(i) / 10) );

                % Канал с АБГШ + Временной сдвиг
                rx_ofdm_stream = [ sqrt(No / 2) * noise1, ...
                                   sqrt(No / 2) * noise2 + tx_ofdm_stream, ...
                                   sqrt(No / 2) * noise3 ];

                % Приёмник
                
                %  ... Signal Detection (определение присутствия сигнала) ...
                
                % Для определения начала OFDM-символа
                [~, p, peak_index] = cross_corr(rx_ofdm_stream, t);

                %  ...

                p_(i, :) = p;
                start_LngTrSym_est(i, j) = peak_index;      
                
        end
        
        % Для получения усреднённого результата
        p_avg = p_avg + p_;
end

p_avg = p_avg ./ Num_exprmnt;

%%
% О Б Р А Б О Т К А   Р Е З У Л Ь Т А Т О В
fprintf('Результаты оценки symbol timing\n\n');
fprintf('Параметры моделирования:\n');
fprintf('  кол-во экспериментов для каждого Eb/No: %d\n', Num_exprmnt);
fprintf('  time offset: %d samples\n', time_offset);
fprintf('  ideal symbol timing: %d sample\n\n', start_LngTrSym);

for i = 1 : length(EbNo)
        
        fprintf('EbNo = %d dB:\n', EbNo(i));
        printf_err( start_LngTrSym_est(i, :), ...
                    start_LngTrSym );
        fprintf('\n');
       
end

graph_symbol_timing(p_avg, EbNo, true, true); % графики усреднённых кросскорр
graph_symbol_timing(p_, EbNo, false, false); % пример кросскорр (результат последнего эксперимента)
graph_symbol_timing_hist(start_LngTrSym_est, EbNo, start_LngTrSym); % Гистограмма оценок symbol timing
