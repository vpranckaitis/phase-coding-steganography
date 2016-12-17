function Y = de2bi(X)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    Y = zeros(size(X, 1), 8);
    for i = 1 : size(X, 1)
        Y(i, :) = bitget(X(i), 8 : -1 : 1);
    end
end
