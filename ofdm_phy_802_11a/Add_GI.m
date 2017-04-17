function [ OFDMSymS_GI ] = Add_GI( OFDMSymS )
% Добавляет GI к каждому OFDM-символу потока, а именно
% преобразует поток OFDM-символов в поток OFDM-символов с GI
%
% in:
%   @OFDMSymS - массив-строка (поток) с OFDM-символовами
%
% out:
%   @OFDMSymS_GI - массив-строка (поток) с OFDM-символами + GI
%
        N_fft = 64; % Кол-во комплексных чисел в одном OFDM-символе
        N_GI  = 16; % Длина GI
        N     = N_fft + N_GI; % Длина OFDM-символа с GI
        
        N_OFDMSymS = length(OFDMSymS) / N_fft; % Кол-во OFDM-символов
        
        % 2d массив с OFDM-символами с GI
        % Одна строка массива - один OFDM-символ с GI
        % Кол-во строк == кол-во OFDM-символов c GI
        OFDMSymS_GI = zeros(N_OFDMSymS, N);
        
        for i = 0 : N_OFDMSymS - 1
           
                % Выделили i-ый OFDM-символ
                OFDMSym = ...
                        OFDMSymS( i * N_fft + (1 : N_fft) );
                
                GI = OFDMSym(end - N_GI + 1 : end);
                
                % Записали i-ый OFDM-символ с GI
                OFDMSymS_GI(i + 1, :) = [GI, OFDMSym];
                
        end
        
        % 2d массив в массив-строку (поток)
        OFDMSymS_GI = reshape(OFDMSymS_GI.', 1, N_OFDMSymS * N);
        
end

