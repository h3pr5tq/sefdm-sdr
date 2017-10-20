function [ estFO ] = FreqSynch( rxSamples, sumWindow, shiftSamples, startAlgorithmSample, roundToInteger)
%
%startAlgorithmSample: - отсчёт с которого стартует алгоритм 
% Частотная отстройка оценивается по отрезку: [startAlgorithmSample; startAlgorithmSample + sumWindow + shiftSamples].
% Путём моделирования прошлых этапов, надо гарантировать, чтоб в данный отрезок попали только STS
%
% ideal_time_offset - идеальное значение временного сдвига (номер первого отсчёта преабмулы == time_offset + 1)
%
% ВЕЛИЧИНА (sumWindow + shiftSamples) определяет отрезок по которому ищим CFO! ОТрезок должен содержать только STS!!!
%
% Диапазон относительной частотной отсройки, которая может быть оценена алгоритмом:
% | e == deltfaF / (1/Tofdm) | <= Nfft / (2 * shiftSamples)
%
% ОБЕСПЕЧИТЬ, ЧТОБЫ ОТСЧЁТЫ ЗАДЕЙСТВОВАННЫЕ В ПОДСЧЁТЕ АВТОКОРРЕЛЯЦИИ БЫЛИ ОДИНАКОВЫМИ !!!! (сдвиг!)
%
% ДЛЯ КОМПЕНСАЦИИ НАДО ЛИ БРАТЬ ЦЕЛУЮ ЧАСТЬ? ДА-НЕТ, зависит от параметров алгоритма (shuftSamples)
% ДА Согласно статье Canet, берём целуя часть, округляя в сторону нуля МБ ВАЩЕ НАФИГ ЭТО???
%
% Этот алгоритм должен легко встраиваться в алгоритм CTS
%
% ФУНКЦИЯ ПОДХОДИТ КАК ДЛЯ Fine Freq Synch, так и для Coarse Freq Synch (Fine и Coarse определяются
% параметрами sumWindow и shiftSamples)
%

	autoCorr = rxSamples(startAlgorithmSample                : startAlgorithmSample + sumWindow - 1) * ...
			   rxSamples(startAlgorithmSample + shiftSamples : startAlgorithmSample + sumWindow + shiftSamples - 1)';

	angl = angle(autoCorr);
	estFO = 64 / (2 * pi * shiftSamples) * angl;
	if strcmp(roundToInteger, 'yes')
		estFO = fix(estFO);
	end
	
end

