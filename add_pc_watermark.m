function add_pc_watermark(watermark, file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here 

    % Retrieve global variables

    [in_dir, out_dir_pc, ~] = globals.global_folders();
    [segment_size, dft_impl, idft_impl] = globals.global_vars_pc();

    % Analyze the specified aprameters set defaults wehere needed

    if nargin < 1
%         watermark = 'Tekstas uzslepimui';
        watermark = 'Slaptas Tekstas';
    end
    
    if nargin < 2
        file_path = in_dir;
    end
    
    if nargin < 3
%         filename = 'carlin_blow_it.wav';
        filename = '69.wav';
    end

    % Read the data from the File
    full_path = [file_path '/' filename];
%    [header, input] = helpers.read_wav_file(full_path);
    [input_stereo, Fs] = audioread(full_path, 'native');

    channel_count = size(input_stereo, 2);

    watermark_bits = helpers.text2bits(watermark);

    % NOTE: all channels should be the same size or the procedures might
    % break unexpectedly...
%     output_stereo = input_stereo;
    % NOTE: in order to avoid loss of quality initialize to int16!
    output_stereo = int16(zeros(size(input_stereo, 1), channel_count));

    for channel_index = 1 : channel_count
        input_mono = double(input_stereo(:, channel_index));

        output_mono = algorithm(watermark_bits, input_mono, ...
            segment_size, dft_impl, idft_impl);

        output_stereo(:, channel_index) = output_mono;
    end

    % Write the data back to a File
    % FIXME
%    helpers.write_wav_file([out_dir_pc '/' filename], header, output);

%     output_stereo = input_stereo;
%     output_stereo(:, 1) = processed_wave;

    audiowrite([out_dir_pc '/' filename], output_stereo, Fs);

end

function [processed_wave] = algorithm(watermark_bits, input_bits, ...
    segment_size, dft_impl, idft_impl)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Some statically configurable options (for debugging)
    is_phase_correction_animated = false;


    text_bit_length = length(watermark_bits);

    display(sprintf('Segment size: %d', segment_size));
    display(sprintf('Text length: %d', text_bit_length / 8));

    if text_bit_length >= segment_size / 2,
        throw(MException('EchoHider:NoSpace', ...
            'The selected size of the segment is not large enough to hide the specified bits (needed: %d bits, have: %d bits, actually usable: %d)\n', ...
            text_bit_length, segment_size, segment_size / 2));
    end

    fprintf('Attempting to embed %d bits of watermark data in a segment of %d bits (%d actually usable)\n', ...
        text_bit_length, segment_size, segment_size / 2);

    %%% Process the first valid segment %%%

    tic

    % Calculate starting position so that any silence in the begining of 
    % the recording can be safely ignored
    start_segment_position = find(input_bits, 1);

    % For simplicity just cut (skip) these empty bits entirely
    adjusted_input = input_bits(start_segment_position : end);

    % Compute 'delta theta' � the amount to shift phases
    Z = dft_impl(adjusted_input(1 : segment_size));

    [~, theta] = magnitude_and_phase(Z);

    delta_theta = theta;

    phases = watermark_bits * (-pi) + (pi / 2);

    delta_theta((segment_size / 2 - text_bit_length + 1) ...
        : (segment_size / 2)) = phases;

    delta_theta((segment_size / 2 + 2) : (segment_size / 2 ...
        + text_bit_length + 1)) = -phases(end : -1 : 1);

    delta_theta = delta_theta - theta;

    processed_wave = zeros(size(adjusted_input));

    toc

    %%% Process (correct) the remaining segments %%%
    % NOTE: since the skipped bits are 0 there is nothing to correct there

    for i = 1 : (length(adjusted_input) / segment_size)
        segment_start = (i - 1) * segment_size + 1;
        segment_end = segment_start + segment_size - 1;

        % Shift phases of the segment
        Z = dft_impl(adjusted_input(segment_start : segment_end));
        [R, theta] = magnitude_and_phase(Z);
        new_theta = theta + delta_theta;
        Z = R .* exp(1i * new_theta);
        processed_wave(segment_start : segment_end) = idft_impl(Z);

        if ~is_phase_correction_animated && i > 1
            continue
        end
        
        % Plot out the segment's frequencies and phases
        figure(min([i 2]));
        hold on;

        subplot(3, 1, 1);
        hold on;
        plot(1 : length(theta), theta, 'r');
        ylim([-2 * pi 2 * pi]);
        title(sprintf( ... 
            'Phase values of segment %d before shifting phases', i), ...
            'fontweight', 'bold');
        xlabel('frequency');
        ylabel('phase, rad');
        
        subplot(3, 1, 2);
        hold on;
        plot(1 : length(new_theta), new_theta, 'r');
        ylim([-2 * pi 2 * pi]);
        title(sprintf( ... 
            'Phase values of segment %d after shifting phases', i), ...
            'fontweight', 'bold');
        xlabel('frequency');
        ylabel('phase, rad');
    end

    % Post-processing the wave
    processed_wave = [zeros(start_segment_position - 1, 1); ...
        processed_wave];

    toc

    % Plot out the sound wave's signal amplitudes
    figure(3);
    hold on;

    subplot(3, 1, 1); 
    hold on;
    plot(1 : length(input_bits), input_bits);
    ylim([min(input_bits) - 10 max(input_bits) + 10]); 
    title('Input channel sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude');

    subplot(3, 1, 2);
    hold on;
    plot(1 : length(processed_wave), processed_wave);
    ylim([min(real(processed_wave)) - 10 max(real(processed_wave)) + 10]); 
    title('Processed channel sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude');

end
