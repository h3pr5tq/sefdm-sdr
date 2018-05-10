function [ R ] = sefdm_MF_demodulator( sefdm_sym, alfa, FFT_size )
% См. sefdm_modulator.m + // Ahmed, p. 115+; Grammenos, p. 125+
%
% П Р Е Д П О Л А Г А Е Т С Я, что все проверки выполнены в функцией sefdm_modulator.m

	%%
	% 
	global N_left_inf_subcarr; % получаем после вызова sefdm_modulator.m

	N = FFT_size * alfa; % Кол-во поднесущих без "Add zero"
	N_add_zero = FFT_size - N; % Кол-во нулей, которые будем добавлять

	W = size(sefdm_sym, 2); % кол-во sefdm-символов

	%%
	%

	% Сдвигаем спектр
	shift_val = N_left_inf_subcarr;
	exp_val = exp( 1i * 2 * pi * (1 : N)' * shift_val / FFT_size );
	sefdm_sym = sefdm_sym .* repmat(exp_val, 1, W);

	sefdm_sym = [ sefdm_sym; zeros(N_add_zero, W) ]; % Добавили нули
	R = fft(sefdm_sym, FFT_size);
	R = R(1 : N, :); % Усекаем
	
end

