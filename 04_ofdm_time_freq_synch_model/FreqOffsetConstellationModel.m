%%
% 

Fd = 10 * 10^6;
N_sample = 2 * 64;
deltaF = 2000; % Гц

% bpsk_data = ones(1, N_sample);
bpsk_data = randi([0, 1], 1, N_sample);
bpsk_data = 2 * bpsk_data - 1;

freq_offset = exp(1i * 2 * pi * deltaF * (1 : N_sample) / Fd);
bpsk_data_freq_offset = bpsk_data .* freq_offset;

scatterplot(bpsk_data_freq_offset);
title('bpsk, without ofdm. influence residual freq offset');
grid on;

% tx_bpsk_sym = ones(1, N_sample);
tx_bpsk_sym = randi([0, 1], 1, N_sample);
tx_bpsk_sym = 2 * tx_bpsk_sym - 1;

tx_ofdm_sym = reshape(tx_bpsk_sym, 64, N_sample/64);
tx_ofdm_sym = ifft(tx_ofdm_sym, 64);
tx_ofdm_sym = reshape(tx_ofdm_sym, 1, N_sample);

tx_ofdm_sym_freq_offset = tx_ofdm_sym .* freq_offset;
tx_ofdm_sym_freq_offset = reshape(tx_ofdm_sym_freq_offset, 64, N_sample/64);
tx_ofdm_sym_freq_offset = fft(tx_ofdm_sym_freq_offset, 64);
tx_ofdm_sym_freq_offset = reshape(tx_ofdm_sym_freq_offset, 1, N_sample);

scatterplot(tx_ofdm_sym_freq_offset);
title('ofdm, influence residual freq offset after FFT');
grid on;
