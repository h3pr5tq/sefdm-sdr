function [ fi0, dfi, symNo ] = sefdm_estimate_residual_freq_offset( R )
% Выполняет оценку остаточной частотной отсройки
% ( остаточная частотная отсройка выражается в фазовом сдвиге,
%   который последовательно меняется взависимости от порядкового номера
%   sefdm/ofdm-символа в пакете; однако данный фазовый сдвиг
%   одинаковый для модуляционных символов внутри одного sefdm/ofdm-символа )
%
% См. sefdm_estimate_channel.m
%
% @R - 2d массив, где каждый столбец рассматривается как отдельный ofdm-символ
%
%
% Для компенсации остаточной частотной остройки у ofdm/sefdm-символов,
% следующих за заголовком использовать следующие выражения:
%   sefdm_sym1 = sefdm_sym1 * exp(-1i * @fi0) * exp(1i * @dfi * (@symNo - 1));
%   @symNo = @symNo + 1;
%   sefdm_sym2 = sefdm_sym2 * exp(-1i * @fi0) * exp(1i * @dfi * (@symNo - 1));
%   @symNo = @symNo + 1;
%   sefdm_sym3 = sefdm_sym3 * exp(-1i * @fi0) * exp(1i * @dfi * (@symNo - 1));
%   @symNo = @symNo + 1;
%   ...
%   (sefdm_sym1, sefdm_sym2, sefdm_sym3 ... - sefdm-символы, следующие за заголовком)
% Или для использовать функцию sefdm_compensate_residual_freq_offset.m:
%   [sefdm_sym1, symNo] = sefdm_compensate_residual_freq_offset(sefdm_sym1, fi0, dfi, symNo);
%   [sefdm_sym2, symNo] = sefdm_compensate_residual_freq_offset(sefdm_sym2, fi0, dfi, symNo);
%   [sefdm_sym3, symNo] = sefdm_compensate_residual_freq_offset(sefdm_sym3, fi0, dfi, symNo);
%   ...

	filename_bits = '../08_sefdm_generate_packets/bits/information_bits.mat';

	global sefdm_N_inf_sub_carr;

	W = size(R, 2); % кол-во ofdm-символов в заголовке

	assert(W > 1, 'Column number of @R must be greater 1');

	% Получаем пилоты
	pilot_modulation = 1; % BPSK
	load(filename_bits);
	n_bit_in_hdr = pilot_modulation * sefdm_N_inf_sub_carr * W;
	pilot_bit = bit(1 : n_bit_in_hdr);
	pilot_bit = reshape(pilot_bit, pilot_modulation * sefdm_N_inf_sub_carr, W);
	pilot_modulation_sym = ConstellationMap(pilot_bit, pilot_modulation); % Modulation Mapping

	% Разбавляем пилоты нулями/меняем порядок, как в модуляторе
	pilot_modulation_sym = sefdm_allocate_subcarriers(pilot_modulation_sym, 'tx');

	% Оценили начальный фазовый сдвиг (для первого ofdm-символа)
	fi0 = angle( R(:, 1).' * conj(pilot_modulation_sym(:, 1)) );

	% Оценим разностный фазовый сдвиг от символа к символу:
	fi_    = zeros(W, 1);
	dfi_   = zeros(W - 1, 1);
	fi_(1) = fi0;
	for i = 2 : W
		fi_(i)      = angle( R(:, i).' * conj(pilot_modulation_sym(:, i)) );
		dfi_(i - 1) = fi_(i - 1) - fi_(i);
	end
	dfi = mean(dfi_);
	symNo = W + 1;

% 	% del, for debug
% 	for i = 1 : W
% 		R(:, i) = R(:, i) .* exp(-1i * fi0) .* exp(1i * dfi * (i - 1));
% 	end
% 	scatterplot(reshape(R, 1, []));

	
	%% Нужны одинаковые пилоты!
	% МЕТОД 2:

end

