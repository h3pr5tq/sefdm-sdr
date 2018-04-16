path(path, '../../02_ofdm_phy_802_11a_model/ofdm_phy_802_11a/');

[~, one_lts] = GenerateLTS('Rx');

for i = 1 : length(one_lts)

	str = ['gr_complex(', num2str( real(one_lts(i)) ), 'f', ', ', num2str( imag(one_lts(i)) ), 'f),'];

	disp(str);

end
