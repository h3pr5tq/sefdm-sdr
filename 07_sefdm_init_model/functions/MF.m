function [ bit ] = MF(R)
% R - матрица со статистиками;
%   каждый столбец соответствует одному отдельному SEFDM-символу
% 
	bit = real(R) <= 0; % BPSK de-mapping

end

