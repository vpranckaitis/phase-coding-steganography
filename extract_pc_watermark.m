function [recovered_watermark] = ... 
    extract_pc_watermark(textLength, file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Retrieve global variables

    [~, out_dir_pc, ~] = globals.global_folders();
    [ l, dft_impl, ~ ] = globals.global_vars_pc();

    % Analyze the specified aprameters set defaults wehere needed

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

    tic

    m = textLength * 8;

    Z = dft_impl(input(1 : l));
    [~, theta] = magnitude_and_phase(Z);

    phases = theta((l / 2 - m + 1) : (l / 2));
    decoded_bit_string = phases < 0;

    toc

    % Debug only
    decoded_bit_string

    % Retrieve the textual representation of the decoded information
    recovered_watermark = helpers.bits2text(decoded_bit_string);

    % Plot out the sound wave's signal frequencies and phases
    figure(1);
    hold on;
    subplot(3, 1, 3);
    plot(1 : length(theta), theta, 'r');
    ylim([-2 * pi 2 * pi]);
    title('Phase values of sample 1 read from stego audio', ...
        'fontweight', 'bold');
    xlabel('frequency');
    ylabel('phase, rad');

    % Experiment 1 - compute the similiraty between the expected result and
    % the decoded value
    original_watermark = 'scrt txt'; % 'ж∆ди@ири'; 'xxxX xXx'; 'xyxy 0%$';
    similarity = compute_vector_similarity( ...
        helpers.text2bits(original_watermark), decoded_bit_string);

    % Debug only
    similarity

end
