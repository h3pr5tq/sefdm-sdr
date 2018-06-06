function analyze_err_bit( res )
%
%
%
% 	n_rx_err_bit = res{2};
% 	index_with_rx_err_bit = find(res{3} ~= 0).';
	index_with_rx_err_bit = find(res{3} > 180).';

	fprintf('analyze_err_bit:\n');
	fprintf('  index in @res     PacketNo     BitErrNum\n');
	for i = index_with_rx_err_bit

		fprintf('  %-13d     %-8d     %-9d\n', i, res{1}(i), res{3}(i));

	end
	
end

