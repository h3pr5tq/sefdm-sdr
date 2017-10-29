%%
%  Для просмотра модуля комплексной огибающей сигнала
%
%
% бинарный файл вначале содержит фиговый кусок, который надо удалить! С чем он связан? Мб с AGC модулем? хз
% примерно где-то первые 40000-60000 отсчётов
% мы будем вырезать поболее: 1*10^6 отсчётов == 1000 000 отсчётов


%%
%
clear;

% filename = '../Signals/RxBaseband_ComplexFloat32_bin/rx_randi_2ofdm_13.dat';
filename = '../Signals/RxBaseband_Truncate_ComlexFloat32_bin/rx_tr_randi_1000ofdm_10.dat';


%%
%

% % Вывести доступные файлы
% fprintf('\n%-30s %s\n', 'FILE NAME:', 'BYTES:');
% file_inf = dir('../Signals/RxBaseband_ComplexFloat32_bin/');
% for i = 1 : length(file_inf)
% 	fprintf('%-30s %d\n', file_inf(i).name, file_inf(i).bytes);
% end
% fprintf('\n');


fd = fopen(filename, 'r');
if fd == -1
    error('File is not opened');  
end
rxSig = fread(fd, [1, inf], 'float32=>double');
rxSig = rxSig(1 : 2 : end) + 1i * rxSig(2 : 2 : end);
fclose(fd);

envelope = abs(rxSig);
figure;
plot(envelope);
grid on;
xlabel('sample');
ylabel('abs(rxIQ)');
title('Complex Envelope Module');


