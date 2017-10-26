function Graph_CoarseTimeSynch(metric, estCTO, startCTSSample, firstComplexSampleNo)
%
%
%
	O_sample = firstComplexSampleNo + startCTSSample - 1 : firstComplexSampleNo + startCTSSample - 1 + length(metric) - 1;
	figure;
	hold on;
	plot(O_sample, metric);
	stem(estCTO + firstComplexSampleNo - 1, 1.2); % оценка первого отсчёта преамбулы
	hold off;
	grid on;
	xlabel('samples');
	ylabel('m = abs(AutoCorr)');
	title('Coarse Time Synch');
	legend('m', 'Estimation==ResultOfCTS');

end

