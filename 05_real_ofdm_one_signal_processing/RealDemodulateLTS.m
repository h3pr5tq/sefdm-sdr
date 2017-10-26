%%
% Decode первого LTS преамбулы
%
% Добавлена компенсация остаточной частотной отсройки + фазового сдвига по пилотам
% ПРи компенсации используем следующее:
%   -- предполагаем, что 1 (+1), 14 (-1), 27 (1) и 40(1) отсчёты bpskLTS1 являются пилотами

%%
%
path(path, '../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

%%
%
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_prmbl_5000_3.dat';

estCTO = 820589;
estFTO = 820781; % Оценка FTS
estCFO = -0.065990; % Оценка CFS
estFFO = 0.076750; % Оценка FFS
estFO = estCFO + estFFO;

N_subcarrier = 64;
% LTS_len = 64;

n_prmbl = 20;
startFOsampleOFFSET = -100;

%%
% Обработка

% Принятый сигнал
fd = fopen(filename, 'r');
if fd == -1
    error('File is not opened');  
end
rxSig = fread(fd, [1, inf], 'float32=>double');
rxSig = rxSig(1 : 2 : end) + 1i * rxSig(2 : 2 : end);
fclose(fd);

% Первая преамбула из файла
% rxSig = rxSig(estFTO : estFTO + LTS_len - 1);

rxSig = rxSig .* exp( 1i * 2 * pi * estFO * (1 : length(rxSig)) / N_subcarrier ); % компенсируем FO
rxSig = rxSig(estFTO : estFTO + 128 + (n_prmbl - 1)*320 - 1); % извлекаем нужное количество преамбул


% bpskLTS = Constellate_From_LTS(rxSig);

bpskLTS = [];
for i = 0 : n_prmbl - 1

	segSig = rxSig( i*(128 + 160 + 32) + (1 : 128) );
	bpskLTS1 = Constellate_From_LTS(segSig(1 : 64));

	angl = angle(bpskLTS1(1) * 1' + bpskLTS1(14) * (-1)' + bpskLTS1(27) * (1)' + bpskLTS1(40) * (1)');
	bpskLTS1 = bpskLTS1 .* exp(-1i*angl);

	bpskLTS2 = Constellate_From_LTS(segSig(65 : 128));
	angl = angle(bpskLTS2(1) * 1' + bpskLTS2(14) * (-1)' + bpskLTS2(27) * (1)' + bpskLTS2(40) * (1)');
	bpskLTS2 = bpskLTS2 .* exp(-1i*angl);
	bpskLTS2 = [];

	bpskLTS = [bpskLTS, bpskLTS1, bpskLTS2];

end

% Компенсация фазового смещения и остаточной частотной отсктройки по пилотам
% 

% L_hard_decision = bpskLTS;
% L_hard_decision(imag(L_hard_decision) > 0) = 1;
% L_hard_decision(imag(L_hard_decision) < 0) = -1;

scatterplot(bpskLTS);
grid on;
