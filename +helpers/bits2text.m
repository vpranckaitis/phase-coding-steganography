function [ text ] = bits2text(textBits)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    textBitsMatrix = reshape(textBits, 8, round(length(textBits) / 8))';
    textBytes = bi2de(textBitsMatrix);
    text = native2unicode(textBytes)';
end
