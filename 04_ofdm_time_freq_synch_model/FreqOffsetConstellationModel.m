%%
% 

Fd = 10 * 10^6;
N_sample = 5 * 64;
deltaF = 1000; % Гц

bpsk_data = ones(1, N_sample);


freq_offset = exp(1i * 2 * pi * deltaF * (1 : N_sample) / Fd);
bpsk_data_freq_offset = bpsk_data .* freq_offset;

scatterplot(bpsk_data_freq_offset);
title('bpsk');


tx_bpsk_sym = ones(1, N_sample);
tx_ofdm_sym = reshape(tx_bpsk_sym, 64, N_sample/64);
tx_ofdm_sym = ifft(tx_ofdm_sym, 64);
tx_ofdm_sym = reshape(tx_ofdm_sym, 1, N_sample);

tx_ofdm_sym_freq_offset = tx_ofdm_sym .* freq_offset;
tx_ofdm_sym_freq_offset = reshape(tx_ofdm_sym_freq_offset, 64, N_sample/64);
tx_ofdm_sym_freq_offset = fft(tx_ofdm_sym_freq_offset, 64);
tx_ofdm_sym_freq_offset = reshape(tx_ofdm_sym_freq_offset, 1, N_sample);

scatterplot(tx_ofdm_sym_freq_offset);
title('ofdm')