function [ S_uncnstr_est, S_cnstr_est ] = ID( R )
% @R - матрица со статистиками;
%   каждый столбец соответствует одному отдельному SEFDM-символу
%
% @S_uncnstr_est - оценки символа до slicing
% @S_cnstr_est - оценки символа после slicing
%
% См. "An Improved Fixed Sphere Decoder Employing Soft Decision for the Detection of Non-orthogonal Signals"

	global eye_lamda_C;
	global lamda;
	global nu;

	S_cnstr_est = R;
	
	for m = 1 : nu
		S_uncnstr_est = lamda * R + eye_lamda_C * S_cnstr_est;
		d = 1 - m / nu;
		S_cnstr_est = SoftMapping(S_uncnstr_est, d);
	end
	
end


function S_cnstr_est = SoftMapping(S_uncnstr_est, d)
%
%
	global modulation_method;

	S_cnstr_est = S_uncnstr_est;
	re = real(S_uncnstr_est);
	im = imag(S_uncnstr_est);

	if modulation_method == 1 % BPSK

		index1 = re  >      d;
		index2 = re <= -1 * d;

		S_cnstr_est(index1) = +1;
		S_cnstr_est(index2) = -1;

	elseif modulation_method == 2 % QPSK

		index1 = and(re  >      d, im  >      d);
		index2 = and(re <= -1 * d, im  >      d);
		index3 = and(re <= -1 * d, im <= -1 * d);
		index4 = and(re  >      d, im <= -1 * d);

		S_cnstr_est(index1) = +1 + 1i;
		S_cnstr_est(index2) = -1 + 1i;
		S_cnstr_est(index3) = -1 - 1i;
		S_cnstr_est(index4) = +1 - 1i;

	end

end

