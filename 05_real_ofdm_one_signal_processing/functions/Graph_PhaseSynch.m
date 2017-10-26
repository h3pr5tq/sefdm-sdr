function Graph_PhaseSynch(sigBeforeCompensation,  sigAfterCompensation)
%
%
%

	scatterplot(sigBeforeCompensation);
	title('Before Phase Offset Compensation')
	grid on;

	scatterplot(sigAfterCompensation);
	title('After Phase Offset Compensation');
	grid on;

end

