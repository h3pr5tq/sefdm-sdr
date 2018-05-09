function [ bit ] = ConstellationDemap( sym, modulation )
% Выполняет de-mapping из модуляционных символов в биты
% (hard desicion)
%
% @sym - 1d или 2d массив;
%   если 2d массив, то каждый столбец рассматривается,
%   как независимая последовательность модуляционных символов
%
% @modulation - метод модуляции:
%   1 - BPSK
%   2 - QPSK
%
% Созвездие как в IEEE 802.11-2016, стр. 2299

	assert( modulation == 1 || modulation == 2 , 'Bad argument @modulation' );

	switch modulation

		% BPSK
		case 1
			bit = zeros(size(sym));
			bit( real(sym) >  0 ) = 1;
			bit( real(sym) <= 0 ) = 0;

		% QPSK
		case 2

			bit = zeros(2 * size(sym, 1), size(sym, 2));
			for j = 1 : size(sym, 2) % по столбцам
				for i = 1 : size(sym, 1) % по строкам

					k = 2 * i;

					if real( sym(i, j) ) > 0
						if imag( sym(i, j) ) > 0
							bit([k - 1, k], j) = [1 1];
						else
							bit([k - 1, k], j) = [1 0];
						end
					else
						if imag( sym(i, j) ) > 0
							bit([k - 1, k], j) = [0 1];
						else
							bit([k - 1, k], j) = [0 0];
						end
					end

				end
			end

		otherwise
			error('Bad argument @modulation');
	end
	
end

