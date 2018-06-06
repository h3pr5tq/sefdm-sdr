%%
% Отрисовка графиков BER по экспериментальным данным
% Экспериментальные данные взяты из 11_sefdm_analyze_rx_bits/rx_sefdm_26.05.18/
clear;
close all;

snr = [0; 2; 4; 6; 8; 10; 12;];

ber_26_28 = [
	1.220977e-01;
	4.811596e-02;
	1.299453e-02;
	2.086460e-03;
	1.606250e-04;
	4.125000e-06;
	5.000000e-08;
];

ber_26_32 = [
	0.137129828326180;
	0.066004039131401;
	0.023907715582451;
	6.043250e-03;
	9.712500000000000e-04;
	1.058750000000000e-04;
	5.250000000000000e-06;
];

ber_26_36 = [
	1.650563e-01;
	9.392521e-02;
	4.216501e-02;
	1.515550e-02;
	4.037875e-03;
	7.998750000000000e-04;
	1.098750000000000e-04;
];

real_sefdm_ber = {ber_26_28; ber_26_32; ber_26_36};

folder = '../../07_sefdm_init_model/results/';
files = {
	'MF_ID_26_0.92857_BPSK_3.mat';
	'MF_ID_26_0.8125_BPSK_3.mat';
	'MF_ID_26_0.72222_BPSK_3.mat';
};

model_sefdm = cell(length(files), 1);
for i = 1 : length(files)
	filename = [folder, files{i}];
	model_sefdm{i} = load(filename);
end


for i = 1 : length(real_sefdm_ber)

	fg = figure;
% 	fg.Position = [200, 200, 400, 350];
	hold on;

	BER_bpsk = berawgn(snr, 'psk', 2, 'nondiff');
	g = plot(snr, BER_bpsk, '--', 'LineWidth',  2);
	g.Marker = 'o';
	g.MarkerSize = 8;

	g = plot(model_sefdm{i}.EbNo, model_sefdm{i}.BER, '-.', 'LineWidth',  2);
	g.Marker = 'X';
	g.MarkerSize = 8;

	g = plot(snr, real_sefdm_ber{i}, 'LineWidth', 5);
	g.Marker = '*';
	g.MarkerSize = 12;
	g.Color = [0 0.2470 0.9410];

	grid on;
	ax = gca;
	ax.Box = 'on';
	ax.YLim = [10^-9 10^0];
	ax.YTick = [10^-9 10^-8 10^-7 10^-6 10^-5 10^-4 10^-3 10^-2 10^-1 10^0];
	ax.YScale = 'log';
	ax.FontSize = 13;

	x_label_ = '$ SNR, dB $';
	xlabel(x_label_, 'FontSize', 16, 'Interpreter', 'latex');  
	grid on;
	y_label_ = '$ BER $';
	ylabel(y_label_, 'FontSize', 16, 'Interpreter', 'latex');

	legend_test = {'Theory: OFDM', 'Theory: SEFDM', 'Real SEFDM receiver'};
	legend(legend_test, 'Location', 'southwest');

end
hold off;


figure;
hold on;
line_spec = {
	'-*'; ...
	'-X'; ...
	'-<'; ...
	'-o'; ...
	'--X'; ...
	'-.<'; ...
	'-o'; ...
	'-+'; ...
	'-x'; ...
	'->'; ...
	'-<'
};
		BER_bpsk = berawgn(snr, 'psk', 2, 'nondiff');
		g = plot(snr, BER_bpsk, '--', 'LineWidth',  2);
% 		g.Marker = 'o';
% 		g.MarkerSize = 8;
for i = 1 : length(real_sefdm_ber)

	g = plot(snr, real_sefdm_ber{i}, line_spec{i}, 'LineWidth', 5);
% 	g.Marker = '*';
	g.MarkerSize = 12;

end
grid on;
ax = gca;
ax.Box = 'on';
ax.YScale = 'log';

ax.YLim = [10^-9 10^0];
ax.YTick = [10^-9 10^-8 10^-7 10^-6 10^-5 10^-4 10^-3 10^-2 10^-1 10^0];
ax.FontSize = 13;

x_label_ = '$ SNR, dB $';
xlabel(x_label_, 'FontSize', 16, 'Interpreter', 'latex');  
grid on;
y_label_ = '$ BER $';
ylabel(y_label_, 'FontSize', 16, 'Interpreter', 'latex');

legend_test = {'Theory: OFDM', '\alpha \approx 0.93', '\alpha \approx 0.81', '\alpha \approx 0.72'};
legend(legend_test, 'Location', 'southwest');
