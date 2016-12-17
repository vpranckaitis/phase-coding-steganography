function [recovered_watermark] = ... 
    extract_pc_watermark(textLength, file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
 
    [~, out_dir_pc, ~] = globals.global_folders();
    [ l, dft_impl, ~ ] = globals.global_vars_pc();

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

    [~, input] = helpers.read_wav_file(full_path);

    m = textLength * 8;

    Z = dft_impl(input(1 : l));
    [~, theta] = magnitude_and_phase(Z);

    phases = theta((l / 2 - m + 1) : (l / 2));
    textBits = phases < 0;

    recovered_watermark = helpers.bits2text(textBits);
    
    figure(1);
    hold on;
    subplot(3, 1, 3);
    plot(1 : length(theta), theta, 'r');
    ylim([-2 * pi 2 * pi]);
    title('Phase values of sample 1 read from stego audio', ...
        'fontweight', 'bold');
    xlabel('frequency');
    ylabel('phase, rad');

end
