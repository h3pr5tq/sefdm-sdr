function [ bit ] = IC(R)
% R - матрица со статистиками;
%   каждый столбец соответствует одному отдельному SEFDM-символу
% 
	global triu_C;

	N_subcarrier = size(R, 1);
	W            = size(R, 2);

	S_est = zeros(N_subcarrier, W);

	% Первая итерация
	m = N_subcarrier;
	S_est(m, :) = R(m, :) / triu_C(m, m);

	% Slicing == bpsk de-mapping
	index = real(S_est(m, :)) <= 0;
	S_est(m,  index) = -1; 
	S_est(m, ~index) =  1;


	% Остальные итерации
	for m = N_subcarrier - 1 : -1 : 1

		summation = ...
			triu_C(m, m + 1 : N_subcarrier) * S_est(m + 1 : N_subcarrier, :);

		S_est(m, :) = 1 / triu_C(m, m) * (R(m, :) - summation);

		index = real(S_est(m, :)) <= 0;
		S_est(m,  index) = -1;
		S_est(m, ~index) =  1;

	end

	bit = real(S_est) <= 0;


% 	% IC детектор (Внимание! Алгоритм зависит от используемого демодулятора)
%   % А Л Г О Р И Т М  Н И Ж Е  С О Д Е Р Ж И Т   О Ш И Б К И !
% 	bit = zeros(N_subcarrier, W);
% 	S_est = zeros(N_subcarrier, 1);
% 	for l = 1 : size(R, 2) % по SEFDM-символам пакета/посылки
% 
% 		R_ = R(:, l);
% 
% 		% Первая итерация
% 		m = N_subcarrier;
% 		S_est(m) = R_(m) / triu_C(m, m);
% 		S_est(m) = real(S_est(m)) <= 0; % slicing == bpsk de-mapping
% 
% 		% Остальные итерации
% 		for m = N_subcarrier - 1 : -1 : 1
% 
% 			summation = 0;
% 			for n = m + 1 : N_subcarrier
% 				summation = summation + triu_C(m, n) * S_est(n);
% 			end
% 
% 			S_est(m) = 1 / triu_C(m, m) * (R_(m) - summation);
% 			S_est(m) = real(S_est(m)) <= 0;
% 
% 		end
% 		bit(:, l) = S_est;
% 
% 	end


end


