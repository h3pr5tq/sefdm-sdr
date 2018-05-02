function [ idft_matrix ] = generate_idft_matrix( Q, N, alfa )
% Матрица Ф // Ahmed, p. 63+
%
% Q != N, если есть передисретизация в p раз, т.е. Q = pN (p >= 1)
	idft_matrix = zeros(Q, N);

	for k = 0 : Q - 1 % по строкам

		for n = 0 : N - 1 % по столбцам

			idft_matrix(k + 1, n + 1) = ...
				1 / sqrt(Q) * exp(1i * 2 * pi * alfa * n * k / Q);
		end
	end

end

