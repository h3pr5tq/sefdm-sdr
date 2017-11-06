function Graph_SignalDetection( metric, signalDetectionSample, firstComplexSampleNo )
%
%
%
	% По оси X номера отсчётов отсносительно заданного входного файла (filename)
	O_sample = firstComplexSampleNo : firstComplexSampleNo + length(metric) -1;
	figure;
	hold on;
	plot(O_sample, metric);
	stem( signalDetectionSample + firstComplexSampleNo - 1, 1.2*ones(1, length(signalDetectionSample)) ); % отсчёт, на котором обнаружили сигнал
	hold off;
	grid on;
	xlim([O_sample(1), O_sample(end)]);
	xlabel('samples');
	ylabel('m = abs(AutoCorr).^2 ./ Energy.^2');
	title('Signal Detection');
	legend('m', 'SampleOfThresholdExcess');
	
	
end

