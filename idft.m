function [ X ] = idft( Z, dft_impl )
X = swap(dft_impl(swap(Z)))/length(Z);
end

function [Zs] = swap( Z )
Zs = real(Z)*1j + imag(Z);
end