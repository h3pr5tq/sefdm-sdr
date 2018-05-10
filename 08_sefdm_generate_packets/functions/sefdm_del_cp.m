function [ sefdm_sym ] = sefdm_del_cp( cp_sefdm_sym, cp_len )
% Удаляет CP
%
% @cp_sefdm_sym - 1d или 2d массив с sefdm-символами+CP
%   Если 2d, то каждый столбец будет рассматриваться как отдельный sefdm-символ+CP
%
% @cp_len - длина Cyclic Prefix'а

	if cp_len == 0
		return;
	end
	
	cp_sefdm_sym_len = size(cp_sefdm_sym, 1); % длина sefdm-символа+CP
	assert( cp_len <= floor(cp_sefdm_sym_len / 2) || cp_len < 0, 'Bad @cp_len' );

	W = size(cp_sefdm_sym, 2); % кол-во sefdm-символов

	sefdm_sym = cp_sefdm_sym(cp_len + 1 : end, 1 : W);
	
end

