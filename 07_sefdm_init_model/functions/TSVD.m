function [ S_est ] = TSVD(R)
% R - матрица со статистиками;
%   каждый столбец соответствует одному отдельному SEFDM-символу
% 
	global trunc_C;

	S_est = trunc_C * R;
% 	bit = real(S_est) <= 0; % BPSK de-mapping

end


