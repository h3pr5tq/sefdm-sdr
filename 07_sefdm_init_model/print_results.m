%%
% Строит графики результатов моделирования BER из папки results/

%%
% Параметры
folder = 'results/';
files = { ...
	'MF_ML_4_0.8.mat'; ...
% 	'MF_ZF_4_0.8.mat'; ...
	'MF_TSVD_4_0.8.mat'; ...
	'MF_IC_4_0.8.mat'; ...
	'MF_ZF_16_0.8.mat'; ...
	'MF_TSVD_16_0.8.mat';...
	'MF_IC_16_0.8.mat'
};

line_spec = {
	'-*'; ...
	'-*'; ...
	'-*'; ...
	'-*'; ...
	'->'; ...
	'-<'; ...
	'-o'; ...
	'-+'; ...
	'-x'; ...
	'->'; ...
	'-<'
};

%%
% Read files
results = cell(length(files), 1);
for i = 1 : length(files)
	filename = [folder, files{i}];
	results{i} = load(filename);
end

%%
% Print
EbNo_ofdm = 0 : 12;
BER_ofdm = berawgn(EbNo_ofdm, 'psk', 2, 'nondiff');

figure;

hold on;
ax = gca;
ax.YScale = 'log';
ax.XLim = [0 10];

legend_text = cell(1, length(results) + 1);
plot(EbNo_ofdm, BER_ofdm, line_spec{1});
legend_text{1} = 'OFDM';
for i = 1 : length(results)

	plot(results{i}.EbNo, results{i}.BER, line_spec{i + 1});
	legend_text{i + 1} = ...
		[ results{i}.demodulation_algorithm, '-', results{i}.detection_algorithm, ...
		  ', N = ', num2str(results{i}.N_subcarrier), ', a = ', num2str(results{i}.alfa) ];

end

xlabel('Eb/No (dB)');
ylabel('BER');
grid on;
legend(legend_text);




