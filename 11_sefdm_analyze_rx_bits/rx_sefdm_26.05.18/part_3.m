%%
% hdr_n_sym  = 6; % Кол-во ofdm-символов в заголовке (для channel estimation)
% hdr_len_cp = 6; % Длина CP у ofdm-символов
% 
% pld_n_sym  = 20; % Кол-во sefdm-символов в полезной нагрузке
% pld_len_cp = 6; % Длина CP у sefdm-символов
% 
% sym_ifft_size    = 28; % IFFT size (также соответсвует длине ofdm-символов в заголовке)
% sym_len          = 26; % длина sefdm-символа
% sym_n_inf        = 20; % кол-во поднесущих с информацией
% sym_len_left_gi  = 3; % длина левого GI по частоте
% sym_len_right_gi = 2; % длина правого GI по частоте
% sym_modulation   = 'bpsk'; % 'bpsk' or 'qpsk' 

snr = [ ...
	0;
	2;
	4;
	6;
	8;
	10;
	12;
];

thr = [ ...
	0.15;
	0.15;
	0.15;
	0.15;
	0.15;
	0.15;
	0.15;
];

n_detect_pckt = [ ...
	522;
	6222;
	18113;
	19992; % из 20000
	20000;
	20000;
	50000;
];

n_err_bit = [ ...
	25494; % 208800
	119751; % 2488800
	94148; % 7245200
	16685; % 7996800
	1285;
	33;
	1; % 20000000
];

ber = [...
	1.220977e-01;
	4.811596e-02;
	1.299453e-02;
	2.086460e-03;
	1.606250e-04;
	4.125000e-06;
	5.000000e-08;
];


%%
%
folder = '../07_sefdm_init_model/results/';
files = { ...

	'MF_ID_26_0.92857_BPSK_3.mat'; ...
};
results = cell(length(files), 1);
for i = 1 : length(files)
	filename = [folder, files{i}];
	results{i} = load(filename);
end
% results{i}.EbNo, results{i}.BER,


%%
%
figure;
hold on;

legend_test = {'Theory: OFDM', 'Theory: SEFDM', 'Real SEFDM receiver'};

BER_bpsk = berawgn(snr, 'psk', 2, 'nondiff');
g = plot(snr, BER_bpsk, '--', 'LineWidth',  2);
	g.Marker = 'o';
	g.MarkerSize = 8;

g = plot(results{1}.EbNo, results{1}.BER, '-.', 'LineWidth',  2);
	g.Marker = 'X';
	g.MarkerSize = 8;

	g = plot(snr, ber, 'LineWidth', 2.5);
	g.Marker = '*';
	g.MarkerSize = 10;


grid on;
ax = gca;
ax.Box = 'on';
ax.YScale = 'log';
% ax.XTick = 0 : OX_len;
% ax.XLim = [0 OX_len];
% ax.YLim = [1e-4, 1e-1];

x_label_ = '$ SNR, dB $';
xlabel(x_label_, 'FontSize', 16, 'Interpreter', 'latex');  
grid on;
y_label_ = '$ BER $';
ylabel(y_label_, 'FontSize', 16, 'Interpreter', 'latex');
legend(legend_test, 'Location', 'southwest');