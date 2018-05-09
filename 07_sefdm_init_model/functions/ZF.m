function [ S_est ] = ZF(R)
% R - матрица со статистиками;
%   каждый столбец соответствует одному отдельному SEFDM-символу
% 
	global inv_C;

	S_est = inv_C * R;
% 	bit = real(S_est) <= 0; % BPSK de-mapping

end

