% function UBody
% Cтроит тело неоперделённости для С/A-Code
% Используется циклическая свёртка для нахождения
% периодической корреляционной функции
%
% >> Исследуем корреляционные свойства С/A-кодов

close all;

% Параметры:
Fd         = 5 * 10^6; % частота дискретизации
max_deltaF = 100 * 10^3; % максимальный частотный сдвиг по модулю, Гц
Nf         = 201; % кол-во частот для которых строим график (включая случай с нулевым частотным сдвигом)

% Принимаемый сигнал и эталон с которым коррелируем
[LTS, oneLTS] = GenerateLTS('Rx');
Sig1 = oneLTS;
Sig2 = oneLTS;

CorrLen = length(Sig1) + length(Sig2) - 1;

df = 2 * max_deltaF / (Nf - 1);
O_deltaF = -max_deltaF : df : max_deltaF; % ось частот
O_t = -(length(Sig2) - 1) : (length(Sig1) - 1); % ось времени

Ubody = zeros(Nf, CorrLen);
for k = 1 : Nf

	freq_shift = exp( 1i * 2 * pi * O_deltaF(k) * (1 : length(Sig2)) / Fd );
	Ubody(k, :) = conv( Sig1, ...
						conj(fliplr(Sig2 .* freq_shift)) );
end

%Ubody = abs(Ubody) / max( max(abs(Ubody)) );
Ubody = abs(Ubody);
%Ubody = 10*log10(Ubody);

[X,Y] = meshgrid( O_t, O_deltaF );
figure;
surf(X,Y,Ubody);
xlabel('sample');
ylabel('frequence, Hz');
title('Ubody (Ambiguity function)');

figure;
CorrPeakIndex = length(Sig2);
plot( Y(:, 1), Ubody(:, CorrPeakIndex) );
xlabel('frequence, Hz');
ylabel('ACFs(0)');
title('Peaks of ACF (OX - freq shift)');
grid on;

figure;
NullDeltaFIndex = find(O_deltaF == 0); 
plot( X(1, :), Ubody(NullDeltaFIndex, :) );
xlabel('samples');
title('ACF (freq shift == 0)');
grid on;


