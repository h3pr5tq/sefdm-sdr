function [ txt_EbNo ] = num2txt_EbNo( num_EbNo )
%
% Преобразует число @num_EbNo в строку вида:
% 'Eb/No = 10 dB'
% (при @num_EbNo == 10)
%
% in:
%   @num_EbNo - число
%
% out:
%   @txt_EbNo - строка
%
        txt_EbNo = ['Eb/No = ', num2str(num_EbNo), ' dB'];       
end

