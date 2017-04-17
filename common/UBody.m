function UBody( sig, Fd )
% Строит график Тела Неоперделённости для входного сигнала (последовательности)
%
% Также выводятся графики:
%   1) функции автокорреляции при нулевом частотном сдвиге
%   2) зависимость максимума функции автокорреляции от частотного сдвига
%
% in:
%   @sig - входной сигнал
%   @Fd - частота дискретизации для @sig
        
        df = 100; % шаг частотного сдвига, Гц
        Nf = 50; % Nf*df - максимальный частотный сдвиг в Гц        
        Nt = length(sig);
        
        % Ubody - 2d массив
        % Каждая строка массива соответствует функции автокорреляции при некотором частотном сдвиге
        % Строка (Nf+1) соответствует автокорр. при НУЛЕВОМ частотном сдвиге
        % Столбец (Nt) соответствует максимуму автокорр.
        Ubody = zeros(2 * Nf + 1, 2 * Nt - 1);
        for k = 1 : (2 * Nf + 1)
                
                freq_shift = exp(1i * 2 * pi * (k - Nf - 1 ) * df * (1 : Nt) / Fd);
                Ubody(k, :) = conv(sig, ...
                                   conj( fliplr(sig .* freq_shift) ) ...
                                   );
        end
        
        % Метрика (мб изменить  (?))
%         P_sig = sum( abs(sig) .^ 2 ) / Nt;
        Ubody = abs(Ubody) / max( max(abs(Ubody)) );
        %Ubody = 10*log10(Ubody);
        
        % Графики
        [X, Y] = meshgrid( -(Nt - 1) : (Nt - 1), df * (-Nf : Nf) );
        
        figure;
        surf(X, Y, Ubody);
        xlabel('sample');
        ylabel('frequence, Hz');
        title('Ubody (Ambiguity function)');

        figure;
        plot( X(1, :), Ubody(Nf + 1, :) );
        xlabel('sample');
        ylabel('ACF');
        title('ACF (freq shift of carrier is 0 Hz)');
        grid on;

        figure;
        plot( Y(:, 1), Ubody(:, Nt) );
        xlabel('frequence, Hz');
        ylabel('ACFs(0)');
        title('Peaks of ACF (OX - freq shift of carrier)');
        grid on;
        
end