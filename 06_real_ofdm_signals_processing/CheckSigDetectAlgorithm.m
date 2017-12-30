%%
% Для оценки, какие пики не обнаружили
% (когда передаём посылку, состоящую из точного известного числа пакетов)


%%
%
sig_filename                  = 'rx_randi_20ofdm_20000pckt_15';
sigProcessingResults_filename = 'SigDetect_s.mat';
N_ofdm_sym = 20;

filename = ['./ProcessingResults/', sig_filename, '/', sigProcessingResults_filename];



load(filename);

detectSigNum = length(SigDetect_s.SampleNo); % кол-во обноруженных пакетов (сигналов)
for i = 1 : detectSigNum - 1

	sampleNo = SigDetect_s.SampleNo(i) + 320 + 80 * N_ofdm_sym;
	
	if ~( sampleNo - 100 < SigDetect_s.SampleNo(i + 1) && ...
	      SigDetect_s.SampleNo(i + 1) < sampleNo + 100 )
		fprintf( 'Вероятно пропущен пакет между пакетами %d (%d) и %d (%d)\n', ...
		         i, SigDetect_s.SampleNo(i), i + 1, SigDetect_s.SampleNo(i + 1) );
	end

end