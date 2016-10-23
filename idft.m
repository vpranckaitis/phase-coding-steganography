function [ X ] = idft( Z )
X = swap(dft(swap(Z)))/length(Z);
end

function [Zs] = swap( Z )
Zs = real(Z)*1j + imag(Z);
end