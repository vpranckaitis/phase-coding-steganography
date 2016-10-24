function [recovered_watermark] = ... 
    extract_pc_watermark(textLength, file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
 
    [~, out_dir_pc, ~] = global_folders();

    if nargin < 1
        textLength = 18;
    end
    
    if nargin < 2
        file_path = out_dir_pc;
    end
    
    if nargin < 3
        filename = 'carlin_blow_it.wav';
    end

    % Read the data from the File
    full_path = [file_path '/' filename];

    [~, input] = read_wav_file(full_path);


    [ l, dft_impl, ~ ] = global_vars_lsb();
    m = textLength * 8;

    Z = dft_impl(input(1 : l));
    [~, theta] = magnitude_and_phase(Z);

    figure(1);
    subplot(3, 1, 3); plot(1 : length(theta), theta); ylim([-2 * pi 2 * pi]);

    phases = theta((l / 2 - m + 1) : (l / 2));
    textBits = phases < 0;

    textBitsMatrix = reshape(textBits, 8, length(textBits) / 8)';
    textBytes = bi2de(textBitsMatrix);

    recovered_watermark = native2unicode(textBytes)';
end

function Y = bi2de(X)
    Y = zeros(size(X, 1), 1);
    weights = 2 .^ (7 : -1 : 0);
    for i = 1 : size(X, 1) 
        Y(i) = sum(X(i, :) * weights');
    end
end
