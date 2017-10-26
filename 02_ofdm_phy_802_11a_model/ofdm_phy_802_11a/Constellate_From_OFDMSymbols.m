function [ inf, pilots ] = Constellate_From_OFDMSymbols( OFDMSymS )
% Извлекает модуляционные символы (частотная область)
% из входного потока OFDM-символов (во временной области)
%
% ~~FFT блок OFDM-преобразования
%
% Выполнение близко к стандарту 802.11a (см. 802.11-2012):
%   - 64-точечное FFT
%   - 4 поднесущих с пилот-символами
%   - 48 поднесущих с информационными символами
%
% in:
%   @OFDMSymS - массив-строка (поток) с OFDM-символами;
%     каждый OFDM-символ - это 64 комплексных числа
%
% out:
%   @inf - массив-строка (поток) с модуляционными информационными символами
%   @pilots - массив-строка (поток) с модуляционными пилотными символами
%       
        N_fft = 64; % Количество комплексных чисел в одном OFDM-символе
        N_OFDMSymS = length(OFDMSymS) / N_fft; % Кол-во OFDM-символов
              
        inf    = zeros(1, 48 * N_OFDMSymS);
        pilots = zeros(1,  4 * N_OFDMSymS);

        for i = 0 : N_OFDMSymS - 1
                
                % Выделили i-ый OFDM-символ из потока
                OFDMSym = OFDMSymS( i * 64 + (1 : 64) );
                
                % 64-точечное FFT
                out_fft64 = fft(OFDMSym);
                
                % Извлекаем символы из информационных поднесущих
                inf_i = [...
                        out_fft64(2 : 7),   ... % 6 символов
                        out_fft64(9 : 21),  ... % 13 символов
                        out_fft64(23 : 27), ... % 5 символов
                        out_fft64(39 : 43), ... % 5 символов
                        out_fft64(45 : 57), ... % 13 символов
                        out_fft64(59 : 64)  ... % 6 символов
                        ];
                
                % Извлекаем символы из поднесущих с пилот-сигналами
                pilots_i = [...
                        out_fft64(8),  ... % ##  7
                        out_fft64(22), ... % ##  21
                        out_fft64(44), ... % ## -21
                        out_fft64(58)  ... % ## -7
                        ];

                inf   ( i * 48 + (1 : 48) ) = inf_i;
                pilots( i *  4 + (1 :  4) ) = pilots_i;
                
        end
                    
end
