function GraphSave_FineTimeSynch( metric, estFTO, startFTSSample, packetNo, ...
                                  mode, folder )
%
%
%
	O_sample = startFTSSample : startFTSSample + length(metric) - 1;

	fig = figure;
	if strcmp(mode, 'save')
		fig.Visible = 'off';
		fig.PaperPositionMode = 'auto';
	end

	hold on;
	plot(O_sample, metric);
	stem(estFTO, 0.6); % оценка первого отсчёта LTS (первый отсчёта за длинным GI)
	hold off;
	grid on;
	xlabel('samples');
	ylabel('m = abs(CrossCorr)');
	title({'Fine Time Synch', ['Packet No: ', num2str(packetNo)]});
	legend('m', 'Estimation==ResultOfFTS');

	%% Save
	if strcmp(mode, 'save')
		filename = [folder, num2str(packetNo)];
		print(fig, filename, '-dpng', '-r0' );
		delete(fig);
	end
	
end

