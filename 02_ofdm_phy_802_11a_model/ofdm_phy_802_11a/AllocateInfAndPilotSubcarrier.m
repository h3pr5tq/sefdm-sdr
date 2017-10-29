function [ infSubcarrier, pilotSubcarrier ] = AllocateInfAndPilotSubcarrier( noNullSubcarrier )
%
% Выделяем 48 информационных поднесущих из 52 поднесущих после 802.11a FFT
% Порядок поднесущих в массивах - номарльный, т.е:
% noNullSubcarrier[1 : 26] == 1 : 26 поднесущие в нумерации 802.11a
% noNullSubcarrier[27 : 52] == -26 : -1 поднесущие в нумерации 802.11a
%
% infSubcarrier - аналогичный (обычный) порядок поднесущих

	infSubcarrier = [ noNullSubcarrier(1  :  6), ...
	                  noNullSubcarrier(8  : 20), ...
	                  noNullSubcarrier(22 : 31), ...
	                  noNullSubcarrier(33 : 45), ...
	                  noNullSubcarrier(47 : 52) ];

	pilotSubcarrier = [ noNullSubcarrier( 7), ... % ##  7
	                    noNullSubcarrier(21), ... % ##  21
	                    noNullSubcarrier(32), ... % ## -21
	                    noNullSubcarrier(46) ];   % ## -7
	
end

