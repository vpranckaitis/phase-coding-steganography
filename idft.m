function [X] = idft(Z, dft_impl)
    % UNTITLED Summary of this function goes here
    %    Detailed explanation goes here

    X = swap(dft_impl(swap(Z))) / length(Z);
end

%--------------------------------------------------------------------------
function [Zs] = swap(Z)
    % UNTITLED Summary of this function goes here
    %    Detailed explanation goes here

    Zs = real(Z) * 1j + imag(Z);
end
