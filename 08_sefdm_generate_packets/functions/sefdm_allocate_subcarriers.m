function [ modulation_sym ] = sefdm_allocate_subcarriers( modulation_sym, mode )
% @mode == 'tx':
%   Подготовливает поднесущие для последующей передачи на блок IFFT
%   А именно модуляционные символы распалагаются в нужном порядке,
%   а также добавляются защитные интервалы по частоте
%
% @mode == 'rx':
%   Извлекает модуляциооные символы из поднесущих после FFT/алгоритма детектирования
%
% @modulation_sym - 1d столбец или 2d массив с модуляционными символами
%   Если 2d, то каждый столбец будет рассматриваться как отдельный sefdm-символ
%
% @mode - 'tx' или 'rx'
	
	global sefdm_N_subcarr;
	global sefdm_N_inf_sub_carr;
	global sefdm_N_right_inf_subcarr;
	global sefdm_N_left_inf_subcarr;
	global sefdm_right_GI_len;
	global sefdm_left_GI_len;

	W = size(modulation_sym, 2); % кол-во sefdm-символов

	if strcmp(mode, 'tx')

		assert( sefdm_N_inf_sub_carr == size(modulation_sym, 1), 'Bad rows num in @modulation_sym' );

		modulation_sym = [ ...
			modulation_sym(sefdm_N_right_inf_subcarr + 1 : end, 1 : W); ... % Ифнормационные поднесущие слева от нулевой частоты
			zeros(1, W); ...                                             % DC
			modulation_sym(1 : sefdm_N_right_inf_subcarr, 1 : W); ... % Ифнормационные поднесущие справа от нулевой частоты
			zeros(sefdm_right_GI_len, W); ...
			zeros(sefdm_left_GI_len,  W); ...
		];

	elseif strcmp(mode, 'rx')

		assert( sefdm_N_subcarr == size(modulation_sym, 1), 'Bad rows num in @modulation_sym' );

		index_2 = 1                            : sefdm_N_left_inf_subcarr;
		index_1 = sefdm_N_left_inf_subcarr + 2 : sefdm_N_left_inf_subcarr + 2 + sefdm_N_right_inf_subcarr - 1;

		modulation_sym = ...
			modulation_sym([index_1, index_2], 1 : W);

	else
		error('Bad @mode');
	end
	
end

