function [ R ] = sefdm_equalizer(R, channel_freq_response)
% Выполняет компенсацию влияния канала
%
% @R - 1d столбец или 2d массив со стастистиками (выход sefdm_FFT.m)
%   Если 2d, то каждый столбец будет рассматриваться как набор статистик отдельного sefdm/odfm-символа
	
	global sefdm_N_right_inf_subcarr;
	global sefdm_N_left_inf_subcarr;

	W = size(R, 2); % кол-во sefdm/ofdm-символов

	channel_freq_response = repmat(channel_freq_response, 1, W);

	% Вместо деления на нули, мы обнуляем нулевые поднесущие:
	% DC и левый/правый GI по частоте
	R(sefdm_N_left_inf_subcarr + 1, :) = 0; % DC
	R(sefdm_N_left_inf_subcarr + 1 + sefdm_N_right_inf_subcarr + 1 : end, :) = 0; % GI по частоте

	index = 1 : sefdm_N_left_inf_subcarr;
	R(index, :) = R(index, :) ./ channel_freq_response(index, :);

	index = sefdm_N_left_inf_subcarr + 1 + 1 : ...
	        sefdm_N_left_inf_subcarr + 1 + 1 + sefdm_N_right_inf_subcarr - 1;
	R(index, :) = R(index, :) ./ channel_freq_response(index, :);
	
end

