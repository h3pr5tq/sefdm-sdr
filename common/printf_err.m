function printf_err( est, ideal )
%
% Сравнивает каждый элемент массива @est с числом-идеалом @ideal
% и выводит общее кол-во ошибок
% Также выводятся ошибочные значения и их кол-во
%
% in:
%   @est - массив-строка
%   @ideal - число-скаляр
%
        err_cnt = sum(est ~= ideal);
        fprintf('Общее кол-во ошибок: %d\n', err_cnt);
        
        % Если есть ошибочные значения,
        % отобразим на экране их и их кол-во
        if err_cnt > 0
                
                err_val = est(est ~= ideal); % ошибочные значения
                err_val = unique(err_val);   % удаляем повторы
                
                for i = 1 : length(err_val)
                        
                        err_cnt_i = sum(est == err_val(i));  
                        fprintf('Ошибочное значение: %d, кол-во: %d\n', ...
                                err_val(i), err_cnt_i);
                end                       
        end         
end

