function [sample_size, dft_impl, idft_impl] = global_vars_lsb()
    % UNTITLED Summary of this function goes here
    %    Detailed explanation goes here

    sample_size = 1024 * 2;
    dft_impl = @(X) dft(X);
    %dft_impl = @(X) cooley_turkey_fft(X);
    idft_impl = @(Z) idft(Z, dft_impl);
end
