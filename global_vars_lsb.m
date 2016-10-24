function [sample_size, dft_impl, idft_impl] = global_vars_lsb()
    % UNTITLED Summary of this function goes here
    %    Detailed explanation goes here

    sample_size = 1024 * 2;
    %dft_impl = @dft;
    dft_impl = @cooley_turkey_fft;
    idft_impl = @(X) idft(X, dft_impl);
end
