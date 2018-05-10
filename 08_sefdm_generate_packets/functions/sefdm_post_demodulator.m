function [ inf_modulation_sym ] = sefdm_post_demodulator( modulation_sym )
% Извлечение информационных поднесущих
% с учётом добавленных защитных нулевых интервалов
%
% Н Е О Б Х О Д И М О выполнять после этапа "Детектирования"!

	%%
	%
	global N_left_inf_subcarr; % получаем после вызова sefdm_modulator.m
	global N_right_inf_subcarr;

	W = size(modulation_sym, 2); % кол-во sefdm-символов

	index_2 = 1                      : N_left_inf_subcarr;
	index_1 = N_left_inf_subcarr + 2 : N_left_inf_subcarr + 2 + N_right_inf_subcarr - 1;

	inf_modulation_sym = ...
		modulation_sym([index_1, index_2], 1 : W);
	
end

