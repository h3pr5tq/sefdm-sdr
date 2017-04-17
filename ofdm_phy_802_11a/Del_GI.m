function [ OFDMSymS ] = Del_GI( OFDMSymS_GI )
% Удаляет GI из каждого OFDM-символа, а именно
% преобразует поток OFDM-символов с GI в поток OFDM-символов без GI
%
% in:
%   @OFDMSymS_GI - массив-строка (поток) с OFDM-символами + GI
%
% out:
%   @OFDMSymS - массив-строка (поток) с OFDM-символовами без GI
%
        N_fft = 64; % Кол-во комплексных чисел в одном OFDM-символе без GI
        N_GI  = 16; % Длина GI
        N     = N_fft + N_GI; % Длина OFDM-символа с GI
        
        N_OFDMSymS = length(OFDMSymS_GI) / N; % Кол-во OFDM-символов
        
        % 2d массив с OFDM-символами без GI
        % Одна строка массива - один OFDM-символ без GI
        % Кол-во строк == кол-во OFDM-символов без GI
        OFDMSymS = zeros(N_OFDMSymS, N_fft);
        
        for i = 0 : N_OFDMSymS - 1
           
                % Выделили i-ый OFDM-символ с GI
                OFDMSym_GI = ...
                        OFDMSymS_GI( i * N + (1 : N) );           
                
                % Записали i-ый OFDM-символ, удалив GI
                OFDMSymS(i + 1, :) = OFDMSym_GI(N_GI + 1 : end);
                
        end
        
        % 2d массив в массив-строку (поток)
        OFDMSymS = reshape(OFDMSymS.', 1, N_OFDMSymS * N_fft);        
        
end

