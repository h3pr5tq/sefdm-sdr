%%
% Строит графики для ID по данным из ./results/:
%   1) BER(nu) при разных alfa, фикированные: Eb/No, N_subcarr;
%   2) BER(nu) при разных N, фикированные: Eb/No, alfa;

%%
% Параметры
clear;

folder = 'results/';
EbNo = 8; % fixed parameter
files = { ...

% 	'8_16_0.5_BPSK.mat'; ...
% 	'8_16_0.66667_BPSK.mat'; ...
% 	'8_18_0.75_BPSK.mat'; ...
% 	'8_16_0.8_BPSK.mat'; ...
% 	'8_15_0.83333_BPSK.mat'; ...
% 	'8_18_0.85714_BPSK.mat'; ...
% 	'8_16_0.88889_BPSK.mat'; ...


% 	'8_64_0.5_BPSK.mat'; ...
% 	'8_64_0.66667_BPSK.mat'; ...
% 	'8_64_0.8_BPSK.mat'; ...
% 	'8_64_0.88889_BPSK.mat'; ...


% 	'8_32_0.5_BPSK.mat'; ...
% 	'8_32_0.66667_BPSK.mat'; ...
% 	'8_32_0.8_BPSK.mat'; ...
% 	'8_32_0.88889_BPSK.mat'; ...

	'8_16_0.66667_BPSK.mat'; ...
	'8_32_0.66667_BPSK.mat'; ...
	'8_48_0.66667_BPSK.mat'; ...
	'8_64_0.66667_BPSK.mat'; ...

};

% legend_test = {'\it \alpha = 1/2', '\it \alpha = 2/3', '\it \alpha = 3/4',  '\it \alpha = 4/5', '\it \alpha = 5/6', '\it \alpha = 6/7', '\it \alpha = 8/9'};
legend_test = {'\it N_{s} = 16', '\it N_{s} = 32', '\it N_{s} = 48', '\it N_{s} = 64'};
OX_len = 10;
% line_spec = {
% 	'-*'; ...
% 	'-o'; ...
% 	'-+'; ...
% 	'-X'; ...
% 	'->'; ...
% 	'-<'; ...
% 	'-o'; ...
% 	'-+'; ...
% 	'-x'; ...
% 	'->'; ...
% 	'-<'
% };


marker = { ...
	'*'; ...
	'X'; ...
	'<'; ...
	'o'; ...
	'>'; ...
	'X'; ...
	'*'};

%%
% Read files
results = cell(length(files), 1);
for i = 1 : length(files)
	filename = [folder, files{i}];
	results{i} = load(filename);
end


fd = figure;
fd.Position = [100, 100, 380, 280];
hold on;

% BER_bpsk = berawgn(EbNo, 'psk', 2, 'nondiff');
% plot(1 : 10, repmat(BER_bpsk, 1, 10), '--', 'LineWidth', 1.6);


for i = 1 : length(results)

	g = plot(results{i}.nu, results{i}.BER, 'LineWidth', 2);
	g.Marker = marker{i};
	g.MarkerSize = 8;

end

grid on;
ax = gca;
ax.Box = 'on';
ax.YScale = 'log';
ax.XTick = 1 : OX_len;
ax.XLim = [1 OX_len];
ax.YLim = [1e-4, 1e-1];

x_label_ = '$ \nu $';
xlabel(x_label_, 'FontSize', 16, 'Interpreter', 'latex');  
grid on;
y_label_ = '$ BER $';
ylabel(y_label_, 'FontSize', 16, 'Interpreter', 'latex');
legend(legend_test);


