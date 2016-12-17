function [text] = bits2text(textBits)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    textBitsMatrix = reshape(textBits, 8, round(length(textBits) / 8))';
    textBytes = bi2de(textBitsMatrix);
    text = native2unicode(textBytes)';
end

function Y = bi2de(X)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    Y = zeros(size(X, 1), 1);
    weights = 2 .^ (7 : -1 : 0);
    for i = 1 : size(X, 1)
        Y(i) = sum(X(i, :) * weights');
    end
end
