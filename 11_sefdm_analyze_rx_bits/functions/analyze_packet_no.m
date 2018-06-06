function analyze_packet_no( res )
%
%
%
	pckt_no = res{1};

	index_first_pckt = 1;
	if pckt_no(1) ~= 1
		fprintf( ['analyze_packet_no: номер первого пакета - %d; ', ...
			'пропускаем данный пакет\n'], pckt_no(1) );
		index_first_pckt = 2;
	end

	cntr = 1;
	i    = index_first_pckt;
	while i ~= length(pckt_no)

		if pckt_no(i) ~= cntr

			fprintf( 'analyze_packet_no: скорее всего не принят пакет с номером %d\n', ...
				cntr );
		else
			i = i + 1;
		end

		cntr = cntr + 1;

	end
	
	
end

