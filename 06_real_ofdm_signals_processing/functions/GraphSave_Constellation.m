function GraphSave_Constellation(cnstlltBeforeCompensation, ...
                                 cnstlltnAfterOnlyChannelCompensation, ...
                                 cnstlltnAfterFullCompensation, N_ofdm_sym, packetNo, ...
                                 mode, folder)
%
% @cnstlltBeforeCompensation           - точки созвездия до компенсации влияния канала и остаточной частотной отстройки
% @cnstlltAfterOnlyChannelCompensation - точки созвездия ТОЛЬКО после компенсации влияния канала
% @cnstlltAfterFullCompensation        - точки созвездия после компенсации влияния канала и остаточной частотной отстройки
%
% @N_ofdm_sym - кол-во OFDM-символов в payload пакета // N_ofdm_sym > 10
% @packetNo - порядковый номер обнаруженного пакета
%
% @mode - 'save' or 'display'; если 'save' - то график не выводится, только сохраняется; 'display' - обычный вывод графика
% @folder - папка, куда сохранять график (используется только при @mode == 'save')
%
	groupSize = 5; % группируем
	n = N_ofdm_sym - groupSize;

	figure;
	fig = gcf;
	fig.Units = 'normalized';
	fig.Position(3 : 4) = [0.8, 0.4];
	
	if strcmp(mode, 'save')
		fig.Visible = 'off';
		fig.PaperPositionMode = 'auto';
	end

	%% График до компенсации влияния канала и остаточной частотной отстройки
	subplot(1, 3, 1);
	graph = plot( real(cnstlltBeforeCompensation(1 : groupSize*48)), ... первые groupSize OFDM-символов из payload
	              imag(cnstlltBeforeCompensation(1 : groupSize*48)), ...
	              ...
	              real(cnstlltBeforeCompensation(1 + groupSize*48 : n*48)), ...
	              imag(cnstlltBeforeCompensation(1 + groupSize*48 : n*48)), ...
	              ...
				  real(cnstlltBeforeCompensation(1 + n*48 : end)), ... последнии groupSize OFDM-символов из payload
	              imag(cnstlltBeforeCompensation(1 + n*48 : end)) );

	for i = 1 : 3
		graph(i).LineStyle = 'none';
		graph(i).Marker = '.';
		graph(i).MarkerSize = 6;
	end

	axes = gca;
	axesMaxAbsVal = max( abs([axes.YLim, axes.XLim]) );
	axes.XLim = [-axesMaxAbsVal, axesMaxAbsVal];
	axes.YLim = [-axesMaxAbsVal, axesMaxAbsVal];

	% Перемещение графиков: Передний/Задний план
	axes.Children = [graph(1); graph(3); graph(2)];

	grid on;
	xlabel('In-Phase');
	ylabel('Quadrature');
	title({'Before Channel and', 'Residual Freq Offset Compensation'});
	legend( [graph(1), graph(2), graph(3)], ...
	        'First 5 OFDM-syms', 'Central OFDM-syms', 'Last 5 OFDM-syms' );


	%% График после компенсации ТОЛЬКО влияния канала
	subplot(1, 3, 2);
	graph = plot( real(cnstlltnAfterOnlyChannelCompensation(1 : groupSize*48)), ... первые groupSize OFDM-символов из payload
	              imag(cnstlltnAfterOnlyChannelCompensation(1 : groupSize*48)), ...
	              ...
	              real(cnstlltnAfterOnlyChannelCompensation(1 + groupSize*48 : n*48)), ...
	              imag(cnstlltnAfterOnlyChannelCompensation(1 + groupSize*48 : n*48)), ...
	              ...
				  real(cnstlltnAfterOnlyChannelCompensation(1 + n*48 : end)), ... последнии groupSize OFDM-символов из payload
	              imag(cnstlltnAfterOnlyChannelCompensation(1 + n*48 : end)) );

	for i = 1 : 3
		graph(i).LineStyle = 'none';
		graph(i).Marker = '.';
		graph(i).MarkerSize = 6;
	end

	axes = gca;
	axesMaxAbsVal = max( abs([axes.YLim, axes.XLim]) );
	axes.XLim = [-axesMaxAbsVal, axesMaxAbsVal];
	axes.YLim = [-axesMaxAbsVal, axesMaxAbsVal];

	% Перемещение графиков: Передний/Задний план
	axes.Children = [graph(1); graph(3); graph(2)];

	grid on;
	xlabel('In-Phase');
	ylabel('Quadrature');
	title({ ['Packet No: ', num2str(packetNo)], '', 'After Only Channel', 'Compensation' });
	legend( [graph(1), graph(2), graph(3)], ...
	        'First 5 OFDM-syms', 'Central OFDM-syms', 'Last 5 OFDM-syms' );


	%% График после компенсации влияния канала и остаточной частотной отстройки
	subplot(1, 3, 3);
	graph = plot( real(cnstlltnAfterFullCompensation(1 : groupSize*48)), ... первые groupSize OFDM-символов из payload
	              imag(cnstlltnAfterFullCompensation(1 : groupSize*48)), ...
	              ...
	              real(cnstlltnAfterFullCompensation(1 + groupSize*48 : n*48)), ...
	              imag(cnstlltnAfterFullCompensation(1 + groupSize*48 : n*48)), ...
	              ...
				  real(cnstlltnAfterFullCompensation(1 + n*48 : end)), ... последнии groupSize OFDM-символов из payload
	              imag(cnstlltnAfterFullCompensation(1 + n*48 : end)) );

	for i = 1 : 3
		graph(i).LineStyle = 'none';
		graph(i).Marker = '.';
		graph(i).MarkerSize = 6;
	end

	axes = gca;
	axesMaxAbsVal = max( abs([axes.YLim, axes.XLim]) );
	axes.XLim = [-axesMaxAbsVal, axesMaxAbsVal];
	axes.YLim = [-axesMaxAbsVal, axesMaxAbsVal];

	% Перемещение графиков: Передний/Задний план
	axes.Children = [graph(1); graph(3); graph(2)];

	grid on;
	xlabel('In-Phase');
	ylabel('Quadrature');
	title({'After Channel and', 'Residual Freq Offset Compensation'});
	legend( [graph(1), graph(2), graph(3)], ...
	        'First 5 OFDM-syms', 'Central OFDM-syms', 'Last 5 OFDM-syms' );

	%% Save
	if strcmp(mode, 'save')
		filename = [folder, num2str(packetNo)];
		print(fig, filename, '-dpng', '-r0' );
		delete(fig);
	end

end

