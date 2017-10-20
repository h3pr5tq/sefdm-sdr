function [ tx_ofdm_stream, ...
           prmbl, ....
           Eb] = OFDM_tx( tx_bit )
%
% Формирует один пакет (burst) с OFDM-символами для передачи
% (преамбула + OFDM-символы с информацией)
%
% Процесс формирования близок к 802.11a и имеет следующую структуру:
% BPSK --> IFFT-блок(64, 48, 4) --> Добавление GI(16) --> Добавление Преамбулы(320)
%
% in:
%   @tx_bit - информационные биты
%     (массива-строка с "0" и "1")
%
% out:
%   @tx_ofdm_stream - пакет: преамбула и информационые OFDM-символы;
%     пакет представляет массив-строку с комплексными числами (квадратурами)
%
%   @prmbl - преамбула пакета
%   @Eb - энергия на бит передаваемой информации
%     (необохдима для моделирования канала с АБГШ и получения BER)
%
        N_bit = length(tx_bit);
        assert( ~mod(N_bit, 48) );

        % BPSK
        tx_bpsk_sym = complex( zeros(1, N_bit) );
        tx_bpsk_sym(tx_bit == 1) = -1 + 1i * 0;
        tx_bpsk_sym(tx_bit == 0) = +1 + 1i * 0;

        % IFFT ~~802.11a
        tx_ofdm_stream = Generate_OFDMSymbols( tx_bpsk_sym );

        % (Енергия бита полезного сигнала)
        % (для BER графика)
        Es = sum( abs(tx_ofdm_stream) .^ 2 ) / length(tx_ofdm_stream);
        Eb = 64 * Es / 52;
        
        % Добавление GI
        tx_ofdm_stream = Add_GI(tx_ofdm_stream);

        % Добавление преамбулы (Short and Long Symbols)
        ShortTrainingSymbols = GenerateSTS('Rx');
        LongTrainingSymbols  = GenerateLTS('Rx');
        prmbl = [ShortTrainingSymbols, LongTrainingSymbols];

        tx_ofdm_stream = [prmbl, tx_ofdm_stream];
        
end

