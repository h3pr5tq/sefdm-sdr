function [ metric, estFTO ] = FineTimeSynch( rxSamples, etalonSamples, ...
                                             startAlgorithmSample, segmentLen )
% Корреляция входного сигнала с эталоном.
% Эталон - первые 32 отсчёта Long Training Symbol'а (32 отсчёта из 64)
% 
% ПРИ выборе отрезка не забыть о выкидывании длинного GI

	if segmentLen == 0
		
		% По всем отсчётам сигнала
		crossCorr = zeros(1, length(rxSamples) - length(etalonSamples) + 1);

		% Коррелируем
		for i = 1 : length(rxSamples) - length(etalonSamples) + 1

			crossCorr(i) = rxSamples(i + 0 : i + length(etalonSamples) - 1) * etalonSamples';

		end

		% Метрика == первый максимум модуля автокорреляции
		metric = abs(crossCorr);
		estFTO = find( max(metric) == metric, 1 );

	else

		% ПОТОМ ОТМОДЕЛИРОВАТЬ
		% Моделирование ближе к реальным условиям: когда коррелируем только на заданном отрезке,
		% определяемый алгоритмом CTS
		crossCorr = zeros(1, segmentLen);

		% Коррелируем
		for i = 1 : segmentLen
			
			offset = i + startAlgorithmSample - 1;
			crossCorr(i) = rxSamples(offset + 0 : offset + length(etalonSamples) - 1) * etalonSamples';

		end

		% Метрика == первый максимум модуля автокорреляции
		metric = abs(crossCorr);
		estFTO = find( max(metric) == metric, 1 ) + startAlgorithmSample - 1;

	end

	
end

