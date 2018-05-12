function [ R ] = sefdm_FFT( sefdm_sym, mode )
% Выполняет FFT для получения статистик (MF Demodulator)
% См. sefdm_IFFT.m + // Ahmed, p. 115+; Grammenos, p. 125+

	global sefdm_FFT_size;
	global sefdm_N_subcarr;
	global sefdm_N_add_zero;
	global sefdm_N_right_inf_subcarr;
	global sefdm_N_left_inf_subcarr;
	global sefdm_right_GI_len;

	if strcmp(mode, 'sefdm')

		N          = sefdm_N_subcarr;
		N_add_zero = sefdm_N_add_zero;
		index      = 1 : sefdm_N_subcarr;

	elseif strcmp(mode, 'ofdm')

		N          = sefdm_FFT_size;
		N_add_zero = 0;

		% Выкидываем центральные нули, а не последнии в качестве "Add zero"
		index = [ 1 : ...
		          sefdm_N_left_inf_subcarr + 1 + sefdm_N_right_inf_subcarr + sefdm_right_GI_len, ...
		          ...
	              sefdm_N_left_inf_subcarr + 1 + sefdm_N_right_inf_subcarr + sefdm_right_GI_len + sefdm_N_add_zero + 1 : ...
		          sefdm_FFT_size ];

	else
		error('Bad @mode');
	end

	W = size(sefdm_sym, 2); % кол-во sefdm-символов

	% Сдвигаем спектр
	shift_val = sefdm_N_left_inf_subcarr;
	exp_val   = exp( 1i * 2 * pi * (1 : N).' * shift_val / sefdm_FFT_size );
	sefdm_sym = sefdm_sym .* repmat(exp_val, 1, W);

	sefdm_sym = [ sefdm_sym; zeros(N_add_zero, W) ]; % Добавили нули
	R = fft(sefdm_sym, sefdm_FFT_size);
	R = R(index, 1 : W); % Усекаем

% 	% Обнулили null-поднесущие (ВРОДЕ БЫ НЕМНОГО ПРОИГРЫВАЕМ, НУЖНЫ ДОПОЛНИТЕЛЬНО ПРОВЕРЯТЬ)
% 	R(N_left_inf_subcarr + 1, 1 : W) = 0; % DC
% 	R(N_right_inf_subcarr + N_left_inf_subcarr + 2 : N, 1 : W) = 0; % GI
	
end

