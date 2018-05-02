function [ bit ] = ML( R )
% R - матрица со статистиками;
%   каждый столбец соответствует одному отдельному SEFDM-символу
%
	global CS;
	global inv_herm_F;
	global S;

	W = size(R, 2);

	metric = zeros(size(CS, 2), W);
	for k = 1 : size(CS, 2) % по эталонам
		
		CS_ = repmat(CS(:, k), 1, W);
		metric(k, :) = sum( abs(inv_herm_F * (R - CS_)).^2 );

	end

	[~, min_index] = min(metric);
	S_est = S(:, min_index);

	bit = real(S_est) <= 0; % BPSK de-mapping


% 	% ML детектор (Внимание! Алгоритм зависит от используемого демодулятора)
% 	rx_bpsk_sym = [];
% 	for l = 1 : size(R, 2) % по SEFDM-символам пакета/посылки
% 
% 		min = Inf;
% 		for k = 1 : size(CS, 2) % по эталонам
% 
% 			est = sum( abs(inverse_herm_F * (R(:, l) - CS(:, k))).^2 );
% 	% 						est = sum( abs(1 * (R(:, l) - CS(:, k))).^2 );
% 
% 
% 			if (est < min)
% 				min = est;
% 				S_est = S(:, k);
% 			end
% 
% 		end
% 
% 		rx_bpsk_sym = [rx_bpsk_sym; S_est];
% 
% 	end
	
end

