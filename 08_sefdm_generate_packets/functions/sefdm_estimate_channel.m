function [ channel_freq_response ] = sefdm_estimate_channel( R )
% Выполняет оценку канала (Zero Forcing)
%
% Для получения корректной оценки частотной характеристики канала,
% необходимо чтобы статистикам @R соответсвовали ofdm-символы (в частотной области!),
% а не sefdm-символы.
% Ofdm-символы, по которым будет осуществляться оценка канала, по спектру
% должны быть аналогичны sefdm-символам пакета.
% Это достигается за счёт большей длительности ofdm-символов
% (формирование ofdm-символов с помощью sefdm_IFFT.m)
% 
% @R - 1d столбец, если заголовок пакета состоит из одного ofdm-символа
%   2d массив, если заголовок состоит из нескольких ofdm-символов
%   (если 2d, то каждый столбец будет рассматриваться как отдельный ofdm-символ)
%
% @channel_freq_response - 1d столбец, частотная характеристика канала
%   Длина соответствует FFT/IFFT блоку без "Add zero", т.е. FFT_size * alfa
%   или что тоже самое - длителности sefdm-символа
%   Порядок коэффициентов в @channelFreqResponse такой же, как порядок
%   символов на входе блока IFFT или на выходе блока FFT

	filename_bits = '../08_sefdm_generate_packets/bits/information_bits.mat';

	global sefdm_N_inf_sub_carr;

	W = size(R, 2); % кол-во ofdm-символов в заголовке

	% Получаем пилоты
	pilot_modulation = 1; % BPSK
	load(filename_bits);
	n_bit_in_hdr = pilot_modulation * sefdm_N_inf_sub_carr * W;
	pilot_bit = bit(1 : n_bit_in_hdr);
	pilot_bit = reshape(pilot_bit, pilot_modulation * sefdm_N_inf_sub_carr, W);
	pilot_modulation_sym = ConstellationMap(pilot_bit, pilot_modulation); % Modulation Mapping

	% Разбавляем пилоты нулями/меняем порядок, как в модуляторе
	pilot_modulation_sym = sefdm_allocate_subcarriers(pilot_modulation_sym, 'tx');

	channel_freq_response = 1 / W * sum( R .* conj(pilot_modulation_sym), 2 );

end

