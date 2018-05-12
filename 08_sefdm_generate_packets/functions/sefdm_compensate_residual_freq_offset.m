function [ R, symNo ] = sefdm_compensate_residual_freq_offset( R, fi0, dfi, symNo )
% Выполняет компенсацию остаточной частотной отстройки
% См. sefdm_estimate_residual_freq_offset.m

	assert(symNo > 1, 'Bad @symNo');

	W = size(R, 2);

	for i = 1 : W
		R(:, i) = R(:, i) .* exp(-1i * fi0) .* exp(1i * dfi * (symNo + i - 2));
	end

	symNo = symNo + W;
	
end

