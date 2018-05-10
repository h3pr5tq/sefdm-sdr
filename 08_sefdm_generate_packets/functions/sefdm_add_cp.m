function [ cp_sefdm_sym ] = sefdm_add_cp( sefdm_sym, cp_len )
% Добавляет CP к sefdm-символу
%
% @sefdm_sym - 1d или 2d массив с sefdm-символами
%   Если 2d, то каждый столбец будет рассматриваться как отдельный sefdm-символ
%
% @cp_len - длина Cyclic Prefix'а

	if cp_len == 0
		return;
	end
	
	sefdm_sym_len = size(sefdm_sym, 1); % длина sefdm-символа
	assert( cp_len <= sefdm_sym_len || cp_len < 0, 'Bad @cp_len' );

	W = size(sefdm_sym, 2); % кол-во sefdm-символов

	cp_sefdm_sym = [ sefdm_sym(sefdm_sym_len - cp_len + 1 : sefdm_sym_len, 1 : W); ...
	                 sefdm_sym ];
	
end

