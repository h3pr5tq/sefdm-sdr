function draw_text( w_norm, h_norm, my_text )
%
% Рисует окошко с надписью @my_text на графике
% Местоположение окоша определяется координатами
% @w_norm, @h_norm
%
% in:
%   @w_norm - число от 0 до 1, нормированная
%     координата по горизонтали
%   @h_norm - число от 0 до 1, нормированная
%     координата по вертикали
%   @my_text - надпись:
%     или массив-строка с типом char;
%     или одномерный cell, содержащий строки
%       
        txt_hndlr = text(0, 0, my_text);

        txt_hndlr.Units    = 'normalized';
        txt_hndlr.Position = [w_norm h_norm];
        
        txt_hndlr.BackgroundColor = 'white';
        txt_hndlr.EdgeColor = 'black';
            
end

