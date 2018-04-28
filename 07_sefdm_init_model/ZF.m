function [ bits ] = ZF(R)
% R - столбец со статистиками одного SEFDM-символа
% 
	global inv_C;

	S_est = inv_C * R;
	bits = real(S_est(m)) <= 0; % BPSK de-mapping

end

