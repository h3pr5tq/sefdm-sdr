function [ sym ] = ConstellationMap( bit, modulation )
% Выполняет mapping из бит в модуляционные символы (точки созвездия)
%
% @bit - 1d или 2d массив;
%   если 2d массив, то каждый столбец рассматривается,
%   как независимая последовательность бит
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
			sym = complex( zeros(size(bit)) );
			sym(bit == 1) = +1 + 1i * 0;
			sym(bit == 0) = -1 + 1i * 0;

		% QPSK
		case 2
			assert( mod(size(bit, 1), 2) == 0, 'Bad size of @bit' );

% 			normalization_factor = 1 / sqrt(2);
			sym = complex( size(bit, 1) / 2, size(bit, 1) );
			for j = 1 : size(bit, 2) % по столбцам
				for i = 1 : 2 : size(bit, 1) - 1 % по строкам

					k = floor(i / 2) + 1;

					if bit(i, j) == 0
						if bit(i + 1, j) == 0
							sym(k, j) = -1 - 1i;
						else
							sym(k, j) = -1 + 1i;
						end
					else
						if bit(i + 1, j) == 0
							sym(k, j) = +1 - 1i;
						else
							sym(k, j) = +1 + 1i;
						end
					end

% 					sym(k, j) = normalization_factor * sym(k, j);

				end
			end

		otherwise
			error('Bad argument @modulation');
	end
	
end

