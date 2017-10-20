function [ detectionMetric, signalDetectionSample ] = SignalDetection( rxSamples, sumWindow, shiftSamples, threshold )
%
% sumWindow - размер окна суммирования 16 - 144
% shiftSamples - автокоррелируем со сдвинутой копией на это число отсчётов
% threshold - порог обнаружения
%
% В отсутствии шума и других фиговин первый пик (если sumWindow == 144, то единтсвенный)
% будет на первом отсчёте преамбулы (преамбула без перекрытия, иначе если с перекрытием то на втором отсчёте)
%
% Превышение порога поидее случится раньше (до отсчётов относящихся к пакету/преамбуле)
%
% СДЕЛАЕМ ПРЕДПОЛОЖЕНИЕ В АЛГОРИТМЕ, ЧТО СИГНАЛ ЗАДЕТЕКТИМ ЗА ПЕРВЫЕ ТРИ SHORT TRAINIG SYMBOLS?? (ЗАЧЕМ?? анализируем по графикам)
%

	autoCorr    = zeros(1, length(rxSamples) - sumWindow - shiftSamples + 1);
	localEnergy = zeros(1, length(rxSamples) - sumWindow - shiftSamples + 1);

	for i = 1 : length(rxSamples) - sumWindow - shiftSamples + 1

		autoCorr(i) = rxSamples(i + 0                : i + sumWindow - 1) * ...
		              rxSamples(i + 0 + shiftSamples : i + sumWindow + shiftSamples - 1)';

		% ?? ПОЧЕМУ ИМЕННО СДВИНУТАЯ КОПИЯ
		localEnergy(i) = rxSamples(i + 0 + shiftSamples : i + shiftSamples + sumWindow - 1) * ...
			             rxSamples(i + 0 + shiftSamples : i + shiftSamples + sumWindow - 1)';

	end

	% Нормировка
	detectionMetric = abs(autoCorr).^2 ./ localEnergy.^2; % ?? ЗАЧЕМ В КВАДРАТ

	% Обнаружение
	% номер отсчёта на котором алгоритм обнаружения сигнала сделал вывод о наличии сигнала
	signalDetectionSample = Inf;
	for i = 1 : length(detectionMetric)

		if (detectionMetric(i) > threshold)
			signalDetectionSample = i;
			break;
		end

	end
	
end

