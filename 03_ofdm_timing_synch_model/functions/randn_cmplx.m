function [ cmplx_nums ] = randn_cmplx( nr, nc )

        cmplx_nums = randn(nr, nc) + 1i * randn(nr, nc);
        
end

