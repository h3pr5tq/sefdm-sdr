%%
% hdr_n_sym  = 6; % Кол-во ofdm-символов в заголовке (для channel estimation)
% hdr_len_cp = 6; % Длина CP у ofdm-символов
% 
% pld_n_sym  = 20; % Кол-во sefdm-символов в полезной нагрузке
% pld_len_cp = 6; % Длина CP у sefdm-символов
% 
% sym_ifft_size    = 32; % IFFT size (также соответсвует длине ofdm-символов в заголовке)
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
	2330;
	13493;
	19830;
	20000;
	20000;
	20000;
	20000;
];

n_err_bit = [ ...
	127805; %  932000
	356237; % из 5397200
	189636; % из 7932000
	48346;
	7770;
	847;
	42;
];

ber = [...
	0.137129828326180;
	0.066004039131401;
	0.023907715582451;
	6.043250e-03;
	9.712500000000000e-04;
	1.058750000000000e-04;
	5.250000000000000e-06;
];


%%
%
folder = '../07_sefdm_init_model/results/';
files = { ...

	'MF_ID_26_0.8125_BPSK_3.mat'; ...
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
