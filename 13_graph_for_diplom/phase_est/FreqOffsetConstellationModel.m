%%
% 

Fd = 4 * 10^6;
N = 64;
N_sample = 4 * N;
deltaF = 3000; % Гц

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

tx_ofdm_sym = reshape(tx_bpsk_sym, N, N_sample/N);
tx_ofdm_sym = ifft(tx_ofdm_sym, N);
tx_ofdm_sym = reshape(tx_ofdm_sym, 1, N_sample);

tx_ofdm_sym_freq_offset = tx_ofdm_sym .* freq_offset;
tx_ofdm_sym_freq_offset = reshape(tx_ofdm_sym_freq_offset, N, N_sample/N);
tx_ofdm_sym_freq_offset = fft(tx_ofdm_sym_freq_offset, N);
tx_ofdm_sym_freq_offset = reshape(tx_ofdm_sym_freq_offset, 1, N_sample);

% scatterplot(tx_ofdm_sym_freq_offset);
figure;
graph = plot( real(tx_ofdm_sym_freq_offset(1 : 1*N)), ... первые groupSize OFDM-символов из payload
			  imag(tx_ofdm_sym_freq_offset(1 : 1*N)), ...
			  ...
			  real(tx_ofdm_sym_freq_offset(1 + 1*N : 2*N)), ...
			  imag(tx_ofdm_sym_freq_offset(1 + 1*N : 2*N)), ...
			  ...
			  real(tx_ofdm_sym_freq_offset(1 + 2*N : 3*N)), ... последнии groupSize OFDM-символов из payload
			  imag(tx_ofdm_sym_freq_offset(1 + 2*N : 3*N)) , ...
...
			  real(tx_ofdm_sym_freq_offset(1 + 3*N : 4*N)), ... последнии groupSize OFDM-символов из payload
			  imag(tx_ofdm_sym_freq_offset(1 + 3*N : 4*N)));
marker = { ...
	'.'; ...
	'+'; ...
	'<'; ...
	'o'; ...
	'+'};
for i = 1 : 4
	graph(i).LineStyle = 'none';
	graph(i).Marker = marker{i};
	graph(i).MarkerSize = 10;
end
grid on;

axes = gca;
% axesMaxAbsVal = max( abs([axes.YLim, axes.XLim]) );
axes.XLim = [-1.2, 1.2];
axes.YLim = [-1.2, 1.2];

% % Перемещение графиков: Передний/Задний план
% axes.Children = [graph(1); graph(3); graph(2)];

grid on;
xlabel('In-Phase');
ylabel('Quadrature');
% title({'Before Channel and', 'Residual Freq Offset Compensation'});
legend('\it OFDM_{0}', '\it OFDM_{1}', '\it OFDM_{2}', '\it OFDM_{3}', 'Location','northwest' );
ax.Box = 'on';