% function UBody
% Строим Тело неопределённости для исследования корреляционных свойств последовательности
% По графикам можно прикинуть нужна ли частотная синхронизации до временной синхронизации или нет
%

% close all;
path(path, '../../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

% Параметры:
Fd         = 4 * 10^6; % частота дискретизации
max_deltaF = 110 * 10^3; % максимальный частотный сдвиг по модулю, Гц
Nf         = 201; % кол-во частот для которых строим график (включая случай с нулевым частотным сдвигом)

% Принимаемый сигнал и эталон с которым коррелируем
[LTS, oneLTS] = GenerateLTS('Rx');
Sig1 = oneLTS(1:32);
Sig2 = oneLTS(1:32);

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
plot( Y(:, 1), Ubody(:, CorrPeakIndex), 'LineWidth', 2 );
xlabel('Частотная отстройка, Гц');
ylabel('Модуль автокорреляции');
% title('Peaks of CF (OX - freq shift)');
grid on;

figure;
NullDeltaFIndex = find(O_deltaF == 0); 
plot( X(1, :), Ubody(NullDeltaFIndex, :) );
xlabel('samples');
title('CF (freq shift == 0)');
grid on;


