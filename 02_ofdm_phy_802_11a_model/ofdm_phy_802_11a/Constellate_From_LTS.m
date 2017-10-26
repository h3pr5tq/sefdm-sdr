function [ bpskLTS ] = Constellate_From_LTS( ofdmLTS )
%
% Демодуляция одного LTS (64 IQ-отчёта) == 802.11a OFDM-преобразование на приёмной стороне
% IQ-ofdm sym -> FFT -> IQ-bpsk sym
% @ofdmLTS - один LTS (64 отчсёта)
% @bpskLTS - соответствующие bpsk символы

	bpskLTS = fft(ofdmLTS);
	bpskLTS = [bpskLTS(2 : 27), bpskLTS(39 : 64)];
	
end

