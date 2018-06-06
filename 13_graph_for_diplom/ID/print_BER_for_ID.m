%%
% Графики BER для MF ID при разных ню
%%
% Параметры
folder = '../../07_sefdm_init_model/results/';
files = { ...
	'MF_ID_26_0.8125_BPSK_1.mat'; ...
	'MF_ID_26_0.8125_BPSK_2.mat'; ...
	'MF_ID_26_0.8125_BPSK_3.mat'; ...
	'MF_ID_26_0.8125_BPSK_4.mat'; ...
	'MF_ID_26_0.8125_BPSK_5.mat'; ...
% 	...
% 	'MF_TSVD_16_0.8_QPSK.mat'; ...
% 	'MF_IC_16_0.8_QPSK.mat'; ...
% 	'MF_MF_16_0.8_QPSK.mat'; ...
% 	'MF_ZF_16_0.8_QPSK.mat'; ...
};

line_spec = {
	'-*'; ...
	'-+'; ...
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

%%
% Read files
results = cell(length(files), 1);
for i = 1 : length(files)
	filename = [folder, files{i}];
	results{i} = load(filename);
end

%%
% Print
EbNo_bpsk = 0 : 12;
BER_bpsk = berawgn(EbNo_bpsk, 'psk', 2, 'nondiff');

figure;

hold on;
ax = gca;
ax.YScale = 'log';
ax.XLim = [0 10];

g=plot(EbNo_bpsk, BER_bpsk, line_spec{1}, 'LineWidth', 2);
g.MarkerSize = 8;
for i = 1 : length(results)

	g=plot(results{i}.EbNo, results{i}.BER, line_spec{i + 1}, 'LineWidth', 1.6);



	g.MarkerSize = 8;

end

xlabel('Eb/No (dB)');
ylabel('BER');
grid on;
legend_text = {'OFDM, BPSK/QPSK', '\it \nu = 1', '\it \nu = 2', '\it \nu = 3', '\it \nu = 4', '\it \nu = 5'};
legend(legend_text, 'Location', 'southwest');
ax.Box = 'on';
x_label_ = '$ E_{b}/N_{0} $';
xlabel(x_label_, 'FontSize', 16, 'Interpreter', 'latex');  
grid on;
y_label_ = '$ BER $';
ylabel(y_label_, 'FontSize', 16, 'Interpreter', 'latex');



