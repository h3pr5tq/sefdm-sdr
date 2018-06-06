%%
% Обрезка файла для дальнешей удобной обработки
 

%%
%
clear;

firstComplexSampleNo = uint64( 1.685 * 10^7 );
endComplexSampleNo   = uint64( 1.6876 * 10^7 );
envelope_graph = 'display'; % 'display' or 'no_display'

filename_original = ...
	[ '/home/ivan/Documents/Signals/RxBaseband_ComplexFloat32_bin/', ...
	  'rx_randi_20ofdm_13.dat' ];
filename_result   = ...
	[ '/home/ivan/Documents/Signals/RxBaseband_ComplexFloat32_bin/several_packets/', ...
	  'tr_rx_randi_20ofdm_13.dat' ];

% filename_result   = filename_original;


%%

if exist(filename_result, 'file') ~= 0
	fprintf('"%s" is exist! Exit\n', filename_result);
	return;
end

fd = fopen(filename_original, 'r');
if fd == -1
    error('File is not opened');  
end
rxSig = fread(fd, [1, inf], 'float32=>float32');
fclose(fd);

rxSig = rxSig(2 * firstComplexSampleNo - 1 : 2 * endComplexSampleNo);

fd = fopen(filename_result, 'w');
if fd == -1
    error('File is not opened');  
end
fwrite(fd, rxSig, 'float32');
fclose(fd);

if strcmp(envelope_graph, 'display')

	envelope = abs( double(rxSig(1 : 2 : end)) + 1i * double(rxSig(2 : 2 : end)) );
	figure;
	plot(envelope);
	grid on;
	xlabel('sample');
	ylabel('abs(rxIQ)');
	title('Truncated Complex Envelope')

end

