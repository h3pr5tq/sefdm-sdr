function Graph_ChannelAndResidualFOCompensation(sigBeforeCompensation,  sigAfterCompensation, N_ofdm_sym)
%
%
% @N_ofdm_sym - кол-во OFDM-символов в payload пакета // N_ofdm_sym > 10
%
	groupSize = 5; % группируем
	n = N_ofdm_sym - groupSize;

	% График до компенсации
	figure;

	graph = plot( real(sigBeforeCompensation(1 : groupSize*48)), ... первые groupSize OFDM-символов из payload
	              imag(sigBeforeCompensation(1 : groupSize*48)), ...
	              ...
	              real(sigBeforeCompensation(1 + groupSize*48 : n*48)), ...
	              imag(sigBeforeCompensation(1 + groupSize*48 : n*48)), ...
	              ...
				  real(sigBeforeCompensation(1 + n*48 : end)), ... последнии groupSize OFDM-символов из payload
	              imag(sigBeforeCompensation(1 + n*48 : end)) );

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


	% График после компенсации
	figure;

	graph = plot( real(sigAfterCompensation(1 : groupSize*48)), ... первые groupSize OFDM-символов из payload
	              imag(sigAfterCompensation(1 : groupSize*48)), ...
	              ...
	              real(sigAfterCompensation(1 + groupSize*48 : n*48)), ...
	              imag(sigAfterCompensation(1 + groupSize*48 : n*48)), ...
	              ...
				  real(sigAfterCompensation(1 + n*48 : end)), ... последнии groupSize OFDM-символов из payload
	              imag(sigAfterCompensation(1 + n*48 : end)) );

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

end

