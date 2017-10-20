function [ metric, estCTO ] = CoarseTimeSynch( rxSamples, sumWindow, shiftSamples, ...
                                               startAlgorithmSample, segmentLen )
% Пригодится при моделировании
% startAlgorithmSample - номер отсчёта в rxSamples с которого начинает работать алгоритм CoarseTimeSynch
% endAlgorithmSample - номер отсчёта в rxSamples на котором  заканчивается оценка временного смещения
% segmentLen - кол-во отсчётов для которых выполняется алгоритм, включая отчёт с номером startAlgorithmSample
%
% В идеальном случае (отсутвие шума) получается, что пик на втором отсчёте преамбулы (т.е. timeoffset+2)
% ?? СТРАННО, ПОЧЕМУ НЕ НА ПЕРВОМ.
%
% В идеале даёт пик на первом/втором отсчёте преамбулы (ПОЧЕМУ НА ВТОРОМ???)

	if segmentLen == 0
		
		% По всем отсчётам сигнала
		autoCorr = zeros(1, length(rxSamples) - sumWindow - shiftSamples + 1);

		for i = 1 : length(rxSamples) - sumWindow - shiftSamples + 1

			autoCorr(i) = rxSamples(i + 0                : i + sumWindow - 1) * ...
						  rxSamples(i + 0 + shiftSamples : i + sumWindow + shiftSamples - 1)';

		end

		% Метрика == первый максимум модуля автокорреляции
		metric = abs(autoCorr);
		estCTO = find( max(metric) == metric, 1 );

	else

		% ПОТОМ ОТМОДЕЛИРОВАТЬ
		% Моделирование ближе к реальным условиям: когда автокоррелируем только на заданном отрезке,
		% определяемым после обнаружения сигнала
		autoCorr = zeros(1, segmentLen);
		for i = 1 : segmentLen
			
			offset = i + startAlgorithmSample - 1;
			autoCorr(i) = rxSamples(offset + 0                : offset + sumWindow - 1) * ...
			              rxSamples(offset + 0 + shiftSamples : offset + sumWindow + shiftSamples - 1)';

		end

		% Метрика == первый максимум модуля автокорреляции
		metric = abs(autoCorr);
		estCTO = find( max(metric) == metric, 1 ) + startAlgorithmSample - 1;

	end


	
	
end

