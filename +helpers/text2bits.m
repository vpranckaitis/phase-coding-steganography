function [ textBits ] = text2bits(text)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    textBytes = unicode2native(text)';
    textBitsMatrix = de2bi(textBytes);
    textBits = reshape(textBitsMatrix', length(textBitsMatrix(:)), 1);
end
