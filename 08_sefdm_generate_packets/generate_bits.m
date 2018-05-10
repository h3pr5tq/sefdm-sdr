%%
% Используется для генерации информации (последовательности бит),
% которая будет использоваться при формировании пакетов / передачи
%
% Сгенерированные биты также используются при формировании пилотных OFDM-символов,
% используемых для оценки канала
%
clear;

N = 8 * 10e4;
bit = randi([0 1], N, 1);

folder = './bits/';
filename = 'information_bits';

%% Make txt-файл
full_filename = [folder, filename, '.txt'];
if exist(full_filename, 'file') ~= 0
    error('File is exist'); 
end
fd = fopen(full_filename, 'wt');
if fd == -1
    error('File is not opened');  
end
fprintf(fd, '%d\n', bit);
fclose(fd);

%% Make mat-файл
full_filename = [folder, filename, '.mat'];
save(full_filename, 'bit');

