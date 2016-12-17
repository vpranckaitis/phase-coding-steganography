function [processed_wave] = add_pc_watermark(watermark, file_path, ...
    filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Retrieve global variables

    [in_dir, out_dir_pc, ~] = globals.global_folders();
    [l, dft_impl, idft_impl] = globals.global_vars_pc();

    % Analyze the specified aprameters set defaults wehere needed

    if nargin < 1
        watermark = 'Tekstas uzslepimui';
    end
    
    if nargin < 2
        file_path = in_dir;
    end
    
    if nargin < 3
        filename = 'carlin_blow_it.wav';
    end

    % Read the data from the File
    full_path = [file_path '/' filename];
    [header, input] = helpers.read_wav_file(full_path);

    textBits = helpers.text2bits(watermark);

    m = length(textBits);
    display(sprintf('Segment size: %d', l));
    display(sprintf('Text length: %d', length(watermark)));

    % Compute 'deltaTheta' – the amount to shift phases
    Z = dft_impl(input(1 : l));
    [~, theta] = magnitude_and_phase(Z);
    deltaTheta = theta;
    phases = textBits * (-pi) + (pi / 2);
    deltaTheta((l / 2 - m + 1) : (l / 2)) = phases;
    deltaTheta((l / 2 + 2) : (l / 2 + m + 1)) = -phases(end : -1 : 1);
    deltaTheta = deltaTheta - theta;

    processed_wave = zeros(size(input));

    tic

    for i = 1 : (length(input) / l)
        segmentStart = (i - 1) * l + 1;
        segmentEnd = segmentStart + l - 1;

        % Shift phases of the segment
        Z = dft_impl(input(segmentStart:segmentEnd));
        [R, theta] = magnitude_and_phase(Z);
        newTheta = theta + deltaTheta;
        Z = R .* exp(1i * newTheta);
        processed_wave(segmentStart : segmentEnd) = idft_impl(Z);

        % Plot out the segment's frequencies and phases
        figure(min([i 2]));
        hold on;
        subplot(3, 1, 1); 
        plot(1 : length(theta), theta, 'r'); ylim([-2 * pi 2 * pi]); 
        title(sprintf( ... 
            'Phase values of segment %d before shifting phases', i), ...
            'fontweight', 'bold'); 
        xlabel('frequency'); ylabel('phase, rad');
        
        subplot(3, 1, 2); 
        plot(1 : length(newTheta), newTheta, 'r'); ylim([-2 * pi 2 * pi]);
        title(sprintf( ... 
            'Phase values of segment %d after shifting phases', i), ...
            'fontweight', 'bold'); 
        xlabel('frequency'); ylabel('phase, rad');
    end

    toc

    % Write the data back to a File
    output = processed_wave;
    helpers.write_wav_file([out_dir_pc '/' filename], header, output);

    % Plot out the sound wave's signal amplitudes
    figure(3);
    hold on;

    subplot(2, 1, 1); 
    plot(1 : length(input), input);
    ylim([0 - 10 256 + 10]); 
    title('Input sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude'); 
    
    subplot(2, 1, 2); 
    plot(1 : length(output), output);
    ylim([0 - 10 256 + 10]); 
    title('Output sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude'); 

end
