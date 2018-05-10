function [ sefdm_sym ] = sefdm_modulator( modulation_sym, ...
                                          alfa, IFFT_size, right_GI_len, left_GI_len )
% @modulation_sym - 1d или 2d массив с модуляционными символами
%   Если 2d, то каждый столбец будет рассматриваться как отдельный sefdm-символ
%   (размер должен быть согласован с @alfa, @IFFT_size, @right_GI_len и @left_GI_len)
%
% @IFFT_size - размер преобразования
%   Возможные значения: 16, 32, 64, 128
%
% @right_GI_len и @left_GI_len - защитный интервал по частоте
%
% @alfa - коэффициент частотного уплотнения
%   Возможные значения alfa для IFFT_size == 32:
%     31/32 ==                 0.9688
%     30/32 == 15/16 ==        0.9375
%     29/32 ==                 0.9062
%     28/32 == 14/16 == 7/8 == 0.8750
%     27/32 ==                 0.8438
%     26/32 == 13/16 ==        0.8125
%     25/32 ==                 0.7812
%     24/32 == 12/16 == 3/4 == 0.7500
%     ...
%
%   Если alfa == 1, то будут сгенерированы ofdm-символы
%   ( их длительность больше чем у sefdm-символов,
%     но в плане поднесущих/СПЕКТРА ofdm-символ аналогичен sefdm-символу )

	%%
	%
	global N_right_inf_subcarr;
	global N_left_inf_subcarr;

	assert( IFFT_size == 16 || IFFT_size == 32 || ...
	        IFFT_size == 64 || IFFT_size == 128, 'Bad @IFFT_size' )

	N = IFFT_size * alfa; % Кол-во поднесущих без "Add zero"
	assert( N - floor(N) == 0 && ...
	        (alfa > 0 && alfa <= 1), 'Bad @alfa' );

	N_inf = N - right_GI_len - left_GI_len - 1; % Кол-во поднесущих под информацию (modulation_symbol)
	assert( N_inf > 1, 'Need change alfa or right/left GI len');
	assert( N_inf == size(modulation_sym, 1), 'Bad rows num in @modulation_sym' );

	N_add_zero = IFFT_size - N; % Кол-во нулей, которые будем добавлять

	if mod(N_inf, 2) == 0
		N_right_inf_subcarr = N_inf / 2;
		N_left_inf_subcarr  = N_inf / 2;
	else
		if right_GI_len < left_GI_len
			N_right_inf_subcarr = ceil(N_inf / 2);
		else
			N_right_inf_subcarr = floor(N_inf / 2);
		end
			N_left_inf_subcarr  = N_inf - N_right_inf_subcarr;
	end

	W = size(modulation_sym, 2); % кол-во sefdm-символов

	%%
	%
	sefdm_sym = [ ...
		modulation_sym(N_right_inf_subcarr + 1 : end, 1 : W); ... % Ифнормационные поднесущие слева от нулевой частоты
		zeros(1, W); ...                                       % DC
		modulation_sym(1 : N_right_inf_subcarr, 1 : W); ... % Ифнормационные поднесущие справа от нулевой частоты
		zeros(right_GI_len, W); ...
		zeros(N_add_zero, W); ...
		zeros(left_GI_len, W); ...
	];

	assert( size(sefdm_sym, 1) == IFFT_size );

	sefdm_sym = ifft(sefdm_sym, IFFT_size);
	sefdm_sym = sefdm_sym(1 : N, :); % усекаем

	% Сдвигаем спектр
	shift_val = N_left_inf_subcarr;
	exp_val = exp( -1i * 2 * pi * (1 : N)' * shift_val / IFFT_size );
	sefdm_sym = sefdm_sym .* repmat(exp_val, 1, W);
	
end

