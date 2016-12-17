function extract_echo_watermark(file_path, filename, Fs, sample_size, ...
    zero_delay, one_delay)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Retrieve global variables

    [~, ~, out_dir_echo] = globals.global_folders();
    [~, Fs_default, sample_size_default, zero_delay_default, ...
    	one_delay_default, ~] = globals.global_vars_echo();

    % Analyze the specified aprameters set defaults wehere needed
    
    if nargin < 1
        file_path = out_dir_echo;
    end
    
    if nargin < 2
 %       filename = 'carlin_blow_it.wav';
        filename = '69.wav';
    end

    if nargin < 3
%         Fs = Fs_default;        
%         Fs = 11025; % for carlin
        Fs = 44100; % for 69
    end

    if nargin < 4
%         sample_size = sample_size_default;
%         sample_size = 8; % for carlin
        sample_size = 16; % for 69
    end

    if nargin < 5
        zero_delay = zero_delay_default;
    end

    if nargin < 6
        one_delay = one_delay_default;
    end

    % Read the data from the File
    full_path = [file_path '/' filename];

%    [~, input] = helpers.read_wav_file(full_path);
    [input_stereo, ~] = audioread(full_path, 'native');
    
    channel_count = size(input_stereo, 2);

    for channel_index = 1 : channel_count
        input_mono = double(input_stereo(:, channel_index));

        decoded_watermark = algorithm(input_mono, Fs, sample_size, ...
            zero_delay, one_delay)

        % Experiment 1 - compute the similiraty between the expected result
        % and the decoded value
        original_watermark = 'Tekstas uzslepimui';
                %'scrt txt'; % 'ж∆ди@ири'; 'xxxX xXx'; 'xyxy 0%$';

        similarity = compute_vector_similarity( ...
            helpers.text2bits(original_watermark), ...
            helpers.text2bits(decoded_watermark));

        % Debug only
        similarity

    end

end

function [recovered_watermark] = algorithm(input_bits, Fs, sample_size, ...
    zero_delay, one_delay)
    % UNTITLED Summary of this function goes here
    %	Detailed explanation goes here 

    % divide up a signal into windows
    zero_delay = zero_delay / 1000;
    one_delay = one_delay / 1000;

    segment_length = round(Fs / sample_size);
    segment_transition_time = round(segment_length / (sample_size * 2));

    length_in_s = round(length(input_bits) / Fs);

    fprintf('Attempting to extract and decode watermark data in %d seconds of audio (%d bits max) at %d b/s\n', ...
        length_in_s, length_in_s * sample_size, sample_size);

    nx = length(input_bits);                    % size of signal
%   w = hamming(bitrate * segment_length / 2);  % hamming window
    w = hamming(segment_length);                % hamming window
    nw = length(w);                             % size of window

    % Calculate starting position so that any silence in the begining of
    % the recording can be safely ignored
    pos = find(input_bits, 1);

    % NOTE: the linter recomended preallocation here!
    zero_delay_signal = zeros(nx, 1);
    one_delay_signal = zeros(nx, 1);
    decision_signal = zeros(nx, 1);

    tic

    % while enough signal left
    while (pos + nw <= nx)                       
        y = input_bits(pos : pos + nw - 1) .* w;     % make window y

        % Only process the signal if the segment (vector y) contains some
        % non-zero values. There will be no echoes in an empty segment :)
        if any(y)
            c = abs(rceps(y));
            % NOTE: no longer used becasue of a serious bug!
%            ac = abs(autoceps(y));

            zero_delay_signal(pos) = c(round(zero_delay * Fs) + 1);
            one_delay_signal(pos) = c(round(one_delay * Fs) + 1);
        end

        pos = pos + round(nw / segment_transition_time);    % next window
    end

    toc

    last_recorded_bit = 0;
    for pos = 1 : length(zero_delay_signal),
        if one_delay_signal(pos) - zero_delay_signal(pos) > 0
        	decision_signal(pos) = 1;
            last_recorded_bit = 1;
        elseif one_delay_signal(pos) - zero_delay_signal(pos) < 0
            decision_signal(pos) = 0;
            last_recorded_bit = 0;
        else
            decision_signal(pos) = last_recorded_bit;
        end        
    end

    toc 

    current_bit = 2;
    current_run = 0;
    decoded_bit_count = 0;

    % Predict the size of the decoded bit String (bit count)
    bits_to_decode_size_prediction = ceil(length(decision_signal) / 8 ...
        / segment_length) * 8;

    % Initialize the decoded bit String with all zeroes
    decoded_bit_string = zeros(bits_to_decode_size_prediction, 1);

    % Debug only
%     decoded_segment_count = 0;
%     runs = [];
%     deciders = [];

    for pos = 1 : length(decision_signal),
        if current_bit == 2
            current_bit = decision_signal(pos);
        end

        if decision_signal(pos) == current_bit
            current_run = current_run + 1;
        else
            % Calculate the number of corresponding bits we decoded
            segment = current_run / round(segment_length);
            number_of_bits = round(segment);
            last_bit_position = decoded_bit_count + number_of_bits;
            
            decoded_bit_string(decoded_bit_count + 1 : ...
                last_bit_position, 1) = current_bit;

            decoded_bit_count = last_bit_position;

            current_bit = decision_signal(pos);

            % Debug only
%             runs = [runs, current_run];
%             deciders = [deciders, segment];
%             decoded_segment_count = decoded_segment_count + 1;

            current_run = 0;
        end
    end

    toc

    % Debug only
%     decoded_segment_count
%     decoded_bit_count
%     runs;
%     deciders;
%     decoded_bit_string

    % Retrieve the textual representation of the decoded information
    recovered_watermark = helpers.bits2text(decoded_bit_string);

    % Plot out decision signals for debugging purposes
    figure(1);
    subplot(2, 1, 1);
    hold on;
    decision_plot = plot(decision_signal);
    set(decision_plot, 'Color', 'black', 'LineWidth', 1.5);
    axis([-20, length(decision_signal), -0.1, 1.1]);

    % Plot out decision signals
    figure(2);
    hold on;

    subplot(3, 1, 1);
    hold on;

    difference_plot = plot(one_delay_signal - zero_delay_signal);
    set(difference_plot, 'Color', 'blue', 'LineWidth', 0.5);

    decision_plot = plot(decision_signal);
    set(decision_plot, 'Color', 'black', 'LineWidth', 0.75);
    axis([-20, length(decision_signal), -0.1, 1.1]);
    title('Difference between delay signals and Decision signal', ...
        'fontweight', 'bold');
    xlabel('Time');
    ylabel('Offset intensity and calculated values');

    subplot(3, 1, 2);
    hold on;
    one_mixer_plot = plot(one_delay_signal);
    set(one_mixer_plot, 'Color', 'green', 'LineWidth', 0.5);
    axis([-20, length(one_delay_signal), -0.1, 1.1]);
    title('One delay signal', 'fontweight', 'bold');
    xlabel('Time');
    ylabel('Offset intensity');

    subplot(3, 1, 3);
    hold on;
    zero_mixer_plot = plot(zero_delay_signal);
    set(zero_mixer_plot, 'Color', 'red', 'LineWidth', 0.5);
    axis([-20, length(zero_delay_signal), -0.1, 1.1]);
    title('Zero delay signal', 'fontweight', 'bold');
    xlabel('Time');
    ylabel('Offset intensity');

    % Plot out the sound wave's signal amplitudes
    figure(3);
    hold on;

    subplot(3, 1, 3); 
    hold on;
    plot(1 : length(input_bits), input_bits);
    ylim([0 - 10 512 + 10]); 
    title('Encoded sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude');

end
