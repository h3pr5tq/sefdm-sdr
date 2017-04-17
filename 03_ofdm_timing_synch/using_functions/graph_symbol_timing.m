function graph_symbol_timing(p, EbNo, isAvg, DoFrameDraw)
%
% Строит графики взаимных корреляций @p,
% (квадратов модулей взаимных корреляций),
% которые вычисляются при символьной синхронизации,
% при разных значениях ОСШ (Eb/No)
%
% in:
%   @p - 2d массив со значениями квадратов модулей взаимных корреляций;
%     i-ая строка массива - значения взаимной корреляции при ОСШ @EbNo(i);
%     (кол-во строк в @p должно совпадать с length(EbNo))
%   @EbNo - массив-строка со значениями ОСШ (Eb/No, т.е.
%     отношение энергии бита к средней мощности шума, приходящейся на 1 Гц)
%   @isAvg - true или false. Определяет только подпись оси OY;
%     true - подпись OY:  'E[|CrossCorr|^{2}]';
%     false - подпись OY: '|CrossCorr|^{2}'
%   @DoFrameDraw - true или false;
%     true - на графике будeт отрисован фрейм-пакет
%     false - на графике не будeт отрисован фрейм-пакет
%     (отрисовка фрейма занимает значительное время)
%

%%
% Н Е К О Т О Р Ы Е   П А Р А М Е Т Р Ы
%         path(path, '../../graph/');

        % Номер отсчёта, при котором должен быть
        % пик взаимной корреляции
        ideal_peak_index = 393;

        % Размеры окна (в нормированных единицах)
        fig_left   = 0.2;
        fig_bottom = 0.2;
        fig_width  = 0.6;
        fig_height = 0.5;
        
        % Формируем легенду для графика
        leg_str = cell(1, length(EbNo) + 1);
        leg_str{end} = 'Ideal Symbol Timing';
        for i = 1 : length(EbNo)
                leg_str{i} = ['Eb/No = ', num2str(EbNo(i)), ' dB'];
        end
        
        % Порядковые значения отсчётов - ось OX
        OX = 1 : size(p, 2);
        OX_zoom = 1 : 30;
        
        % Подпись OY
        if isAvg == true
                y_label = 'E[|CrossCorr|^{2}]';
        else
                y_label = '|CrossCorr|^{2}';
        end

%%
% Р И С У Е М
        figure('Units', 'normalized', ...
                'Position', [fig_left, fig_bottom, fig_width, fig_height]);
        hold on;

        % График фрейма
        if DoFrameDraw == true
                draw_frame( max(max(p)) + 0.2 * max(max(p)) );
        end
        
        % Графики усреднённых взаимных корреляций     
        lines0 = stem(OX, p.');               
        grid on;
        title('Symbol Timing');
        xlabel('samples')
        ylabel(y_label, 'Interpreter', 'tex');       
        
        ax0 = gca;
        ax0.Box = 'on';
               
        % Вертикальная линия - идеальное значение пика
        OY_min_max_val = get(ax0, 'YLim');
        line1 = plot( [ideal_peak_index, ideal_peak_index], ...
                       [0,      OY_min_max_val(2)] );
        line1.LineStyle = '--';
	line1.LineWidth = 1;
	line1.Color = [1, 0.2, 0.2];
                
        % Передвигаем графики: Задний/Передний план
        if DoFrameDraw == true
                ax0.Children = [ax0.Children(2 : length(EbNo) + 1); ...
                                ax0.Children(1); ...
                                ax0.Children(length(EbNo) + 2 : end)];
        else
                ax0.Children = [lines0 line1];
        end
        
        % Пределы осей
        xlim([1, length(OX)]);
        ylim([0, OY_min_max_val(2)]);

        % Легенда
        legend([lines0, line1], leg_str);
       
        hold off;
                

        %%
        % Zoom In
        ax1 = axes('Position', [0.69 0.35 0.2 0.2]);
        hold on;
        
        stem(OX_zoom, p(:, OX_zoom).');
        
        ax1.Box = 'off';
        ax1.FontSize = 9;
        title('Zoom In');
        xlabel('samples');
        ylabel(y_label, 'Interpreter', 'tex');

        hold off;
            
end

