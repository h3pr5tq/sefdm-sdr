function GraphSave_CoarseTimeSynch( metric, estCTO, startCTSSample, packetNo, ...
                                    mode, folder)
%
%
%
	O_sample = startCTSSample : startCTSSample + length(metric) - 1;

	fig = figure;
	if strcmp(mode, 'save')
		fig.Visible = 'off';
		fig.PaperPositionMode = 'auto';
	end

	hold on;
	plot(O_sample, metric);
	stem(estCTO, 1.2); % оценка первого отсчёта преамбулы
	hold off;
	grid on;
	xlabel('samples');
	ylabel('m = abs(AutoCorr)');
	title({'Coarse Time Synch', ['Packet No: ', num2str(packetNo)]});
	legend('m', 'Estimation==ResultOfCTS');

	%% Save
	if strcmp(mode, 'save')
		filename = [folder, num2str(packetNo)];
		print(fig, filename, '-dpng', '-r0' );
		delete(fig);
	end

end

