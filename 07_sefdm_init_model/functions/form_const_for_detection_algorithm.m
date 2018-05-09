function form_const_for_detection_algorithm(Q, N, alfa, modulation)
% Формирует глобальные константы, необходимые
% для алгоритмов детектирования

	global modulation_method;

	global inv_C;  % for ZF
	global triu_C;  % for IC
	global trunc_C trunc_index; % for TSVD

	% for ML:
	global CS;
	global inv_herm_F;
	global S;

	% for ID
	global eye_lamda_C;
	global lamda; % convergence factor (from 1 to 2)
	global nu; % number of iteration

	modulation_method = modulation;
	if modulation_method == 1 % BPSK

	  	% Всевозможные комбинации символов для BPSK
		if N <= 16
			S = fullfact(repmat(2, 1, N));
		else
			fprintf('Not use @ML algorithm! @N is too much --> S = 1\n');
			S = 1;
		end
		S(S == 1) = +1;
		S(S == 2) = -1;
		S = S.';

		trunc_index = ceil(alfa * N); % trunc index for TSVD algorithm

	elseif modulation_method == 2 % QPSK

		if N <= 12
			S = fullfact(repmat(4, 1, N));
		else
			fprintf('Not use @ML algorithm! @N is too much --> S = 1\n');
			S = 1;
		end
		S(S == 1) = +1 + 1i;
		S(S == 2) = -1 + 1i;
		S(S == 3) = -1 - 1i;
		S(S == 4) = +1 - 1i;
		S = S.';

		trunc_index = ceil(alfa * N) + 1;
% 		trunc_index = ceil(alfa * N);

	end

	F = generate_idft_matrix( Q, N, alfa );
	C = F' * F;

	inv_C = inv(C);
	triu_C = triu(C);

	[U,E,V] = svd(C);
	for i = 1 : trunc_index
		trunc_C = V(i) * U(i)' ./ E(i, i);
	end

	inv_herm_F = inv(F');
	CS = C * S;

	lamda = 1;
	nu = 3;
	eye_lamda_C = eye(N) - lamda * C;

end