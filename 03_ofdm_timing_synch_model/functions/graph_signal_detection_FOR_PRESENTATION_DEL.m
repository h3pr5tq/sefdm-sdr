function graph_signal_detection_FOR_PRESENTATION_DEL( c__, m__, EbNo, L, isAvg )
%
% Строит графики модуля автокорреляции
% и нормированной атокорреляции, вычисляемых
% на этапе "обнаружение сигнала"
%
% См. [ c, m ] = autocorr_L_D( r, L, D )
%
% in:
%   @c__ - 3d массив со значениями модуля автокорреляции
%     при разных Eb/No и L.
%     Массив-строка с модулями автокорр. при некотором Eb/No
%     и L выбирается так: с__(2, 1, :),
%     где "2" означает @EbNo(2), "1" означает @L(1).
%   @m__ - 3d массив со значениями нормированной автокорреляции
%     при разных Eb/No и L.
%     Массив-строка с нормированной актокорр. при некотором Eb/No
%     и L выбирается так: m__(2, 1, :),
%     где "2" означает @EbNo(2), "1" означает @L(1).
%   @EbNo - массив-строка со значениями ОСШ (Eb/No) используемых
%     при моделировании
%   @L - массив-строка со значениями размера окна суммирования
%     используемых при моделировании
%   @isAvg - true или false; указывает являются ли @c__ и @m__
%     усреднёнными значениями (true) или соответствуют
%     одиночному эксперименту (false).
%     Этот аргумент нужен только для правильной подписи
%     оси OY на графике
% 
        OX = 1 : size(m__, 3);
        
        % Заголовок
        suptitle_text = 'Signal Detection';
        
        % Текст для легенд
        leg_EbNo = form_leg_text_EbNo(EbNo);
        leg_L    = form_leg_text_L   (L);
        
        % Размеры окон (в нормированных единицах)
        fig_left   = 0.2;
        fig_bottom = 0.2;
        fig_width  = 0.5;
        fig_height = 0.5;
        
        % Подпись OY
        if isAvg == true
                y_label_1 = '$ E[|Autocorr|] $';
                y_label_2 = '$ E[\frac{|Autocorr|^{2}}{(Power)^{2}}] $';
        else
                y_label_1 = '$ |Autocorr| $';
                y_label_2 = '$ \frac{|Autocorr|^{2}}{(Power)^{2}} $';
        end
        
%%
% П Е Р В О Е   О К Н О:
% L - Ф И К С И Р У Е М,   EbNo - Р А З Н Ы Е

        figure('Units', 'normalized', ...
                'Position', [fig_left, fig_bottom, fig_width, fig_height]);
             
        %% Автокорреляция
        
%         % L(1)
%         subplot(2, 2, 1);     
%         hold on;
%         for i = 1 : length(EbNo)
%               plot( OX, squeeze(c__(i, 1, :)) );             
%         end
%         hold off;
%         tune_common;
%         ylabel(y_label_1, 'FontSize', 16, 'Interpreter', 'latex');
%         legend(leg_EbNo);
%         title(['L = ', num2str(L(1)), ' samples'], 'FontWeight', 'normal');
%         
%         % L(end)
%         subplot(2, 2, 2);     
%         hold on;
%         for i = 1 : length(EbNo)
%               plot( OX, squeeze(c__(i, end, :)) );             
%         end
%         hold off;
%         tune_common;
%         ylabel(y_label_1, 'FontSize', 16, 'Interpreter', 'latex');
%         legend(leg_EbNo);
%         title(['L = ', num2str(L(end)), ' samples'], 'FontWeight', 'normal');
%               
        %% Нормированная Автокорреляция
        
        % L(1)
        subplot(2, 2, 1);
        hold on;
        for i = 1 : length(EbNo)
              plot( OX, squeeze(m__(i, 1, :)) );
        end
        hold off;
        tune_common;
        ylabel(y_label_2, 'FontSize', 16, 'Interpreter', 'latex');
        legend(leg_EbNo);
        title(['L = ', num2str(L(1)), ' samples'], 'FontWeight', 'normal');
        
        % L(end)
        subplot(2, 2, 2);
        hold on;
        for i = 1 : length(EbNo)
              plot( OX, squeeze(m__(i, end, :)) );
        end
        hold off;
        tune_common;
        ylabel(y_label_2, 'FontSize', 16, 'Interpreter', 'latex');        
        legend(leg_EbNo);
        title(['L = ', num2str(L(end)), ' samples'], 'FontWeight', 'normal');
        
        suptitle(suptitle_text);

%%
% В Т О Р О Е   О К Н О:
% EbNo - Ф И К С И Р У Е М,   L - Р А З Н Ы Е
        
%         figure('Units', 'normalized', ...
%                 'Position', [fig_left + 0.2, fig_bottom, fig_width, fig_height]);
%         
%         %% Автокорреляция
%         
%         % EbNo(1)
%         subplot(2, 2, 1);
%         for i = 1 : length(L)
%               plot( OX, squeeze(c__(1, i, :)) );
%               hold on;
%         end
%         hold off;
%         tune_common;
%         ylabel(y_label_1, 'FontSize', 16, 'Interpreter', 'latex');
%         legend(leg_L);
%         title(['Eb/No = ', num2str(EbNo(1)), ' dB'], 'FontWeight', 'normal');
%         
%         % EbNo(end)
%         subplot(2, 2, 2);
%         for i = 1 : length(L)
%               plot( OX, squeeze(c__(end, i, :)) );
%               hold on;
%         end
%         hold off;
%         tune_common;
%         ylabel(y_label_1, 'FontSize', 16, 'Interpreter', 'latex');
%         legend(leg_L);
%         title(['Eb/No = ', num2str(EbNo(end)), ' dB'], 'FontWeight', 'normal');
        
        %% Нормированная Автокорреляция
        
        % EbNo(1)
        subplot(2, 2, 3);
        hold on;
        for i = 1 : length(L)
              plot( OX, squeeze(m__(1, i, :)) );
        end
        hold off;
        tune_common;
        ylabel(y_label_2, 'FontSize', 16, 'Interpreter', 'latex');         
        legend(leg_L);
        title(['Eb/No = ', num2str(EbNo(1)), ' dB'], 'FontWeight', 'normal');
        
        % EbNo(end)   
        subplot(2, 2, 4);
        for i = 1 : length(L)
              plot( OX, squeeze(m__(end, i, :)) );
              hold on;
        end
        hold off;
        tune_common;
        ylabel(y_label_2, 'FontSize', 16, 'Interpreter', 'latex');        
        legend(leg_L);
        title(['Eb/No = ', num2str(EbNo(end)), ' dB'], 'FontWeight', 'normal');
        
        suptitle(suptitle_text);
        
end


function leg_text = form_leg_text_EbNo( EbNo )
%
% Формирует легенду с EbNo для графика
%
% in:
%   @EbNo - массив-строка со значениями Eb/No в
%     числовом формате (double)
%
        leg_text = cell(1, length(EbNo));     
        for i = 1 : length(EbNo)
                leg_text{i} = ['Eb/No = ', num2str(EbNo(i)), ' dB'];
        end        
end


function leg_text = form_leg_text_L( L )
%
% Формирует легенду с L для графика
%
% in:
%   @L - массив-строка со значениями L в
%     числовом формате (double)
%
        leg_text = cell(1, length(L));       
        for i = 1 : length(L)
                leg_text{i} = ['L = ', num2str(L(i)), ' samples'];
        end        
end


function tune_common
%
% Общие настройки для всех графиков
%
        xlabel('samples');
        grid on;
        
end
