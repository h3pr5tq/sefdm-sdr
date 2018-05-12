function [ sefdm_sym ] = sefdm_IFFT( modulation_sym, mode )
% Выполняет IFFT для генерации SEFDM-символов
%
% @modulation_sym - 1d столбец или 2d массив с модуляционными символами
%   Если 2d, то каждый столбец будет рассматриваться как отдельный sefdm-символ
%
% @mode - 'sefdm' or 'ofdm'
%   Если режим 'ofdm', то усечение после IFFT не будет делаться, т.о. на выходе
%   получим ofdm-символы, по спектру аналогичные sefdm-символам, за счёт большей длительности

	global sefdm_FFT_size;
	global sefdm_N_subcarr;
	global sefdm_N_add_zero;
	global sefdm_N_left_inf_subcarr;

	assert( sefdm_N_subcarr == size(modulation_sym, 1), 'Bad rows num in @modulation_sym' );

	if strcmp(mode, 'sefdm')
		N = sefdm_N_subcarr;
	elseif strcmp(mode, 'ofdm')
		N = sefdm_FFT_size;
	else
		error('Bad @mode');
	end

	W = size(modulation_sym, 2); % кол-во sefdm-символов

	sefdm_sym = [ ...
		modulation_sym;
		zeros(sefdm_N_add_zero,   W);
	];

	assert( size(sefdm_sym, 1) == sefdm_FFT_size );

	sefdm_sym = ifft(sefdm_sym, sefdm_FFT_size);
	sefdm_sym = sefdm_sym(1 : N, :); % усекаем

	% Сдвигаем спектр
	shift_val = sefdm_N_left_inf_subcarr;
	exp_val   = exp( -1i * 2 * pi * (1 : N).' * shift_val / sefdm_FFT_size );
	sefdm_sym = sefdm_sym .* repmat(exp_val, 1, W);
	
end

