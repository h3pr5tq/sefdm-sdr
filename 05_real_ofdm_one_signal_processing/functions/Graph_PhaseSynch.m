function Graph_PhaseSynch(sigBeforeCompensation,  sigAfterCompensation, N_ofdm_sym)
%
%
% @N_ofdm_sym - кол-во OFDM-символов в payload пакета // N_ofdm_sym > 10
%
	n = N_ofdm_sym - 5;

	% График до компенсации
	figure;

	graph = plot( real(sigBeforeCompensation(1 : 104 + 5*48)), ... преамбула + 2 первых OFDM-символа из payload
	              imag(sigBeforeCompensation(1 : 104 + 5*48)), ...
	              ...
	              real(sigBeforeCompensation(1 + 104 + 5*48 : 104 + n*48)), ...
	              imag(sigBeforeCompensation(1 + 104 + 5*48 : 104 + n*48)), ...
	              ...
				  real(sigBeforeCompensation(1 + 104 + n*48 : end)), ... % последнии 5 OFDM-символа из payload
	              imag(sigBeforeCompensation(1 + 104 + n*48 : end)) );

	for i = 1 : 3
		graph(i).LineStyle = 'none';
		graph(i).Marker = '.';
		graph(i).MarkerSize = 6;
	end

	axes = gca;
	axesMaxAbsVal = max( abs([axes.YLim, axes.XLim]) );
	axes.XLim = [-axesMaxAbsVal, axesMaxAbsVal];
	axes.YLim = [-axesMaxAbsVal, axesMaxAbsVal];

	grid on;
	xlabel('In-Phase');
	ylabel('Quadrature');
	title('Before Phase Offset Compensation')
	legend('Preamble + First 5 OFDM-syms', 'Central OFDM-syms', 'Last 5 OFDM-syms');


	% График после компенсации
	figure;

	graph = plot( real(sigAfterCompensation(1 : 104 + 5*48)), ... преамбула + 2 первых OFDM-символа из payload
	              imag(sigAfterCompensation(1 : 104 + 5*48)), ...
	              ...
	              real(sigAfterCompensation(1 + 104 + 5*48 : 104 + n*48)), ...
	              imag(sigAfterCompensation(1 + 104 + 5*48 : 104 + n*48)), ...
	              ...
				  real(sigAfterCompensation(1 + 104 + n*48 : end)), ... % последнии 5 OFDM-символа из payload
	              imag(sigAfterCompensation(1 + 104 + n*48 : end)) );

	for i = 1 : 3
		graph(i).LineStyle = 'none';
		graph(i).Marker = '.';
		graph(i).MarkerSize = 6;
	end

	axes = gca;
	axesMaxAbsVal = max( abs([axes.YLim, axes.XLim]) );
	axes.XLim = [-axesMaxAbsVal, axesMaxAbsVal];
	axes.YLim = [-axesMaxAbsVal, axesMaxAbsVal];

	grid on;
	xlabel('In-Phase');
	ylabel('Quadrature');
	title('After Phase Offset Compensation')
	legend('Preamble + First 5 OFDM-syms', 'Central OFDM-syms', 'Last 5 OFDM-syms');

end

