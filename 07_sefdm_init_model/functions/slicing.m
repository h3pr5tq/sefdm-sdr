function [ sym ] = slicing( sym )
%
%
	global modulation_method;
	
	if modulation_method == 1 % BPSK

		index = real(sym) <= 0;
		sym( index) = -1; 
		sym(~index) =  1;

	else % QPSK

		index1 = and(real(sym)  > 0, imag(sym)  > 0);
		index2 = and(real(sym) <= 0, imag(sym)  > 0);
		index3 = and(real(sym) <= 0, imag(sym) <= 0);
		index4 = and(real(sym)  > 0, imag(sym) <= 0);

		sym(index1) = +1 + 1i;
		sym(index2) = -1 + 1i;
		sym(index3) = -1 - 1i;
		sym(index4) = +1 - 1i;
	end
	
end

