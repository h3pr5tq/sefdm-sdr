function draw_frame( OY_lvl_frame )
%
% Рисует на графике горизонтальную полосу - фрейм,
% представляющий структуру передаваемого сигнала
%
% ВАЖНО:
% - перед вызовом функции необходим
%   оператор "hold on;"
% - данная функция выполняется достаточно долго
% - возможно понадобится корректировка некоторых
%   параметров ниже
%
% in:
%   @OY_lvl_frame - число, значение по оси OY,
%     которое определяет уровень, на котором
%     будет изображен фрейм
%
        %%
        % Настройка полей фрейма
        field0 = 'len';   % длина (кол-во занимаемых "samples" вдоль OX)
        field1 = 'num';   % кол-во кусочков данного типа
        field2 = 'color'; % цвет

        time_offset = struct(field0, 200, ...
                             field1, 1, ...
                             field2, [200 200 200]./255);

        ShTrSyms = struct(field0, 16, ...
                          field1, 10, ...
                          field2, [255 242 204]./255);

        LnGI = struct(field0, 32, ...
                      field1, 1, ...
                      field2, [219 238 243]./255);

        LnTrSyms = struct(field0, 64, ...
                          field1, 2, ...
                          field2, [183 221 232]./255);

        OFDM_sym = struct(field0, [16, 64], ...
                          field1, 10, ...
                          field2, [235 241 223]./255);

        y = [ repmat( time_offset.len, [1, time_offset.num] ) + 0.5, ...
              repmat( ShTrSyms.len,    [1, ShTrSyms.num] ), ...
              repmat( LnGI.len,        [1, LnGI.num] ), ...
              repmat( LnTrSyms.len,    [1, LnTrSyms.num] ), ...
              repmat( OFDM_sym.len,    [1, OFDM_sym.num] ), ...
              repmat( time_offset.len, [1, time_offset.num] ), ...
             ];
        y = [y; zeros(1, length(y))];
 
        %%
        % Рисуем
        b = bar([OY_lvl_frame, -1], y);
        
        % Настройки фрейм-графика
        for i = 1 : size(b, 2)
                b(i).BarLayout  = 'stacked';
                b(i).Horizontal = 'on';
                b(i).BarWidth   = 0.1;
                b(i).FaceAlpha  = 0.5;
                b(i).EdgeAlpha  = 0.5;
        end
        
        %%
        % Расскрашиваем фрейм:

        % time_offset
        b(1).FaceColor = time_offset.color;

        % ShTrSyms
        for i = 2 : 11
                b(i).FaceColor = ShTrSyms.color;
        end

        % LnGI
        b(12).FaceColor = LnGI.color;

        % LnTrSyms
        b(13).FaceColor = LnTrSyms.color;
        b(14).FaceColor = LnTrSyms.color;

        % OFDM_sym
        for i = 15 : 34
                b(i).FaceColor = OFDM_sym.color;
        end

        % time_offset
        b(35).FaceColor = time_offset.color;
            
end

