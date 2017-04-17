function [ c, p, peak_index ] = cross_corr( r, t )
%
% Выполняет корреляцию входного сигнала @r с известным шаблоном @t;
%
% Для чего?: временная синхронизация (определение начала OFDM-символа)
%
% См., например,
% "OFDM Wireless LANs: A Theoretical and Practical Guide",
% Juha Heiskala, John Terry, стр. 61
%
% in:
%   @r - входной сигнал, массив-строка
%   @t - сигнал-шаблон, массив-строка
%
% out:
%   @c - комплексные значения взаимной корреляции,
%     массив-строка длина которого будет length(r)-length(t)+1
%   @p - модуль в квадрате от @c,
%     массив-строка длина которого будет length(r)-length(t)+1
%   @peak_index - индекс максимального значения @p;
%     в иделале должен соответствовать индексу первого отсчёта
%     Long Trainig Symbol
%       

%
% C   О П Т И М И З А Ц И Е Й   П О Д   M A T L A B
%
        L = length(t);
        c = zeros( 1, length(r) - L + 1 );
        
        % По отсчётам входной последовательности
        for n = 1 : length(r) - L + 1
                
                c(n) = r(n + 0 : n + L - 1) * t'; 
                
        end
        
        % Определяем начало (первый отсчёт) Long Training Symbols
        % в пакете:
        % | ShortTraimSym | GI_32 | LongTrainSym | GI_16 | OFDM-inf | ...
        p = abs(c) .^ 2;
        peak_index = find( p == max(p) );

%%
% Б Е З   О П Т И М И З А Ц И И   П О Д   M A T L A B
%
%         L = length(t);
%         c = zeros( 1, length(r) - L + 1 );
%         
%         % По отсчётам входной последовательности
%         for n = 1 : length(r) - L + 1
%                 
%                 % Окно суммирования
%                 % (соответствует длине шаблона)
%                 for k = 0 : L - 1
%                         c(n) = c(n) + ...
%                                 r(n + k) * conj( t(k + 1) );  
%                 end     
%                 
%         end
%         
%         % Определяем начало (первый отсчёт) Long Training Symbols
%         % в пакете:
%         % | ShortTraimSym | GI_32 | LongTrainSym | GI_16 | OFDM-inf | ...
%         p = abs(c) .^ 2;
%         peak_index = find( p == max(p) );
        
end

