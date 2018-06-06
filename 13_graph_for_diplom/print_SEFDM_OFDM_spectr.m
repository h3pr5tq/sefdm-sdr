%

% hold on;
% lim = 2;
% x = -lim : 0.01 : lim;
% 
% y1 = sin(2 * pi * 1 * x) ./ x;
% plot(x, y1);
% 
% y2 = sin(2 * pi * 0.7 * x) ./ x;
% plot(x, y2);
% 
% x = x + 0.5;
% % y1 = sin(2 * pi * 1 * x) ./ x;
% plot(x, y1);
% 
% % y2 = sin(2 * pi * 0.7 * x) ./ x;
% plot(x, y2);
clear;
color = {...
	[1 1 0]
	[1 0 1]
	[0 1 1]
	[1 0 0]
	[0 1 0]
	[0 0 1]
	[0 0 0]
	[1 1 0]
	[1 0 1]
};

% subplot(2, 1, 1)
hold on;
alfa = 0.6;
n_graph = 9;
lim = 3;
x = (-lim : 0.01 : lim);
y1 = sin(2 * pi * 1 * x) ./ x;
for i = 1 : n_graph
	x = x + 0.5;
	g = plot(x - 2.5, y1, 'LineWidth', 3);
	g.Color = abs(color{i} - 0.23);
end
grid on;
hold off;

% subplot(2, 1, 2)
hold on;
x = -lim : 0.01 : lim;
y2 = 1 / alfa * sin(2 * pi * alfa * x) ./ x - 15;
for i = 1 : n_graph
	x = x + 0.5;
	g = plot(x - 2.5, y2, 'LineWidth', 3);
	g.Color = abs(color{i} - 0.23);
end
grid on;
hold off;

ax = gca;
ax.Box = 'on';
ax.XTick = -4 : 0.5 : 4;
ax.XLim = [-4 4];
x_label_ = '$ fT_{ofdm} $';
xlabel(x_label_, 'FontSize', 16, 'Interpreter', 'latex'); 
ax.YTick = [];
%%
%
% N = 5;
% Fd = 4e6;
% f = 300e3;
% n = 100;
% alfa = 0.5;
% 
% s = [ones(1, 5), zeros(1, n - 5) ] .* exp( 1i * 2 * pi * alfa * 0  * f / Fd * (1 : length(n)) );
% 
% s = s + [ones(1, 5), zeros(1, n - 5) ] .* exp( 1i * 2 * pi * 1 * alfa * f / Fd * (1 : length(n)) );
% 
% s = s + [ones(1, 5), zeros(1, n - 5) ] .* exp( 1i * 2 * pi * 2 * alfa * f / Fd * (1 : length(n)) );
% 
% plot( abs(fft(s)) );