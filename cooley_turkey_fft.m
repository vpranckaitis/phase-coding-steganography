function [Z] = cooley_turkey_fft(X)
l = length(X);
if l == 1
    Z = dft(X);
else 
    E = cooley_turkey_fft(X(1:2:end));
    O = cooley_turkey_fft(X(2:2:end));
    w = transpose(0:(l/2 - 1));
    ex = exp(-2j*pi*w/l);
    Z = [E + ex.*O;
         E - ex.*O];
end
end

