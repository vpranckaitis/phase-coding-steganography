function [Z] = dft(X)
l = length(X);
w = (0:(l-1));
[W1,W2] = meshgrid(w, w);
W = W1.*W2 / l;
e = exp((-1j)*2*pi*W);
Z = e*X;
end

