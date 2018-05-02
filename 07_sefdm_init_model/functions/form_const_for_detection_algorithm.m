function form_const_for_detection_algorithm(Q, N, alfa)
% Формирует глобальные константы, необходимые
% для алгоритмов детектирования

	global inv_C;  % for ZF
	global triu_C;  % for IC
	global trunc_C; % for TSVD

	% for ML:
	global CS;
	global inv_herm_F;
	global S;

	F = generate_idft_matrix( Q, N, alfa );
	C = F' * F;

	inv_C = inv(C);
	triu_C = triu(C);

	% trunc_index = ceil(alfa * N) + 1;
	trunc_index = ceil(alfa * N);
	[U,E,V] = svd(C);
	for i = 1 : trunc_index
		trunc_C = V(i) * U(i)' ./ E(i, i);
	end

	% for ML
	inv_herm_F = inv(F');
	S = de2bi(0 : 2^N - 1);
	S(S == 0) = -1; % BPSK mapping
	S = S.';  % всевозможные комбинации символов для BPSK
	CS = C * S;

end