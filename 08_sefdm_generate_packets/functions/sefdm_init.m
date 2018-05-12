function sefdm_init(FFT_size, alfa, right_GI_len, left_GI_len, modulation)
% Инициализирует глобальные переменные (константы) - параметры
% для алгоритмов формирования и приёма SEFDM-сигналов
%
% @FFT_size - размер преобразования
%   Возможные значения: 16, 32, 64, 128
%
% @right_GI_len и @left_GI_len - защитные интервалы по частоте
%
% @modulation - 1 - BPSK or 2 - QPSK
%
% @alfa - коэффициент частотного уплотнения
%   Возможные значения alfa для FFT_size == 32:
%     31/32 ==                 0.9688
%     30/32 == 15/16 ==        0.9375
%     29/32 ==                 0.9062
%     28/32 == 14/16 == 7/8 == 0.8750
%     27/32 ==                 0.8438
%     26/32 == 13/16 ==        0.8125
%     25/32 ==                 0.7812
%     24/32 == 12/16 == 3/4 == 0.7500
%     ...

	%%
	%
	path(path, '../07_sefdm_init_model/functions/');

	global sefdm_FFT_size;            % Размерность блока FFT/IFFT
	global sefdm_alfa;                % Коэффициент частотного уплотнения
	global sefdm_N_subcarr;           % Кол-во поднесущих без "Add zero" == длительность SEFDM-символа
	global sefdm_N_add_zero;          % Кол-во нулей которые добавляем до FFT/IFFT и усекаем после
	global sefdm_N_inf_sub_carr;      % Кол-во поднесущих под информацию (под модуляционные символы)
	global sefdm_N_right_inf_subcarr; % Кол-во информационных поднесущих справа от нулевой частоты
	global sefdm_N_left_inf_subcarr;  % Кол-во информационных поднесущих слева от нулевой частоты
	global sefdm_right_GI_len;        % Длина защитного интервала по частоте справа от нулевой частоты
	global sefdm_left_GI_len;         % Длина защитного интервала по частоте слева от нулевой частоты

	assert( FFT_size == 16 || FFT_size == 32 || ...
	        FFT_size == 64 || FFT_size == 128, 'Bad @FFT_size' )

	N = FFT_size * alfa; % Кол-во поднесущих без "Add zero"
	assert( N - floor(N) == 0 && ...
	        (alfa > 0 && alfa < 1), 'Bad @alfa' );

	N_inf = N - right_GI_len - left_GI_len - 1; % Кол-во поднесущих под информацию (модуляционные символы)
	assert( N_inf > 1, 'Need change alfa or right/left GI len');

	N_add_zero = FFT_size - N; % Кол-во нулей, которые будем добавлять

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
	
	assert(modulation == 1 || modulation == 2, 'Bad @modulation');
	form_const_for_detection_algorithm(N, N, alfa, modulation);

	%%
	% Инициализируем глобальные константы
	sefdm_FFT_size            = FFT_size;
	sefdm_alfa                = alfa;
	sefdm_N_subcarr           = N;
	sefdm_N_inf_sub_carr      = N_inf;
	sefdm_N_add_zero          = N_add_zero;
	sefdm_N_right_inf_subcarr = N_right_inf_subcarr;
	sefdm_N_left_inf_subcarr  = N_left_inf_subcarr;
	sefdm_right_GI_len        = right_GI_len;
	sefdm_left_GI_len         = left_GI_len;
	
end

