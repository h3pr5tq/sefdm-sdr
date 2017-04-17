function graph_symbol_timing_hist( sym_timing_est, ...
                                   EbNo, ...
                                   ideal_sym_timing )
%
% Строит гистограммы полученых входе моделирования
% оценок символьной синхронизации (некоторый номер отсчёта)
%
% in:
%   @sym_timing_est - 2d массив со значениями оценок
%     символьной синхронизации;
%     (номер строки - идентифицирует Eb/No, номер столбца - номер эксперимента);
%     i-ая строка - оценки символьной синхронизации для каждого эксперимента при ОСШ @EbNo(i) 
%   @EbNo - массив-строка со значениями ОСШ (Eb/No)
%   @ideal_sym_timing - число-скаляр, значение идеальной символьной синхронизации
%
        % Формируем легенду для графика
        leg_str = cell(1, length(EbNo));
        for i = 1 : length(EbNo)
                leg_str{i} = ['Eb/No = ', num2str(EbNo(i)), ' dB'];
        end             

        % Размеры окна (в нормированных единицах)
        fig_left   = 0.2;
        fig_bottom = 0.2;
        fig_width  = 0.6;
        fig_height = 0.4;
        
        figure('Units', 'normalized', ...
                'Position', [fig_left, fig_bottom, fig_width, fig_height]);
        
        subplot(1, 2, 1);
        hist( sym_timing_est.', ...
                min(min(sym_timing_est)) : max(max(sym_timing_est)) );
        grid on;
        xlabel('samples');
        title('Estimates of Symbol Timing');
        legend(leg_str);

        % Аналогично, только приблизили
        subplot(1, 2, 2);
        hist( sym_timing_est.', ...
                min(min(sym_timing_est)) : max(max(sym_timing_est)) );
        grid on;
        
        xlabel('samples');
        title('Estimates of Symbol Timing (Zoom In)');
        legend(leg_str);
        xlim([ideal_sym_timing - 5, ideal_sym_timing + 5]);
        
        ax = gca;
        ax.XTick = ideal_sym_timing - 5 : ideal_sym_timing + 5;
        
        
end

