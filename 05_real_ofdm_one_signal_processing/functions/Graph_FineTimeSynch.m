function Graph_FineTimeSynch(metric, estFTO, startFTSSample, firstComplexSampleNo)
%
%
%
	O_sample = firstComplexSampleNo + startFTSSample - 1 : firstComplexSampleNo + startFTSSample - 1 + length(metric) - 1;
	figure;
	hold on;
	plot(O_sample, metric);
	stem(estFTO + firstComplexSampleNo - 1, 0.6); % оценка первого отсчёта LTS (первый отсчёта за длинным GI)
	hold off;
	grid on;
	xlabel('samples');
	ylabel('m = abs(CrossCorr)');
	title('Fine Time Synch');
	legend('m', 'Estimation==ResultOfFTS');
	
	
end

