function [processed_wave] = add_echo_watermark(watermark, file_path, ...
    filename, Fs, zero_delay, one_delay, decay_rate)
    % UNTITLED Summary of this function goes here
    %	Detailed explanation goes here

    % Retrieve global variables

    [in_dir, ~, out_dir_echo] = globals.global_folders();
    [alpha_default, Fs_default, zero_delay_default, one_delay_default, ...
        decay_rate_default] = globals.global_vars_echo();

    % Analyze the specified aprameters set defaults wehere needed

    if nargin < 1
%        watermark = 'test didelis ir baisus';
%        watermark = 'test';
%        watermark = 'Tekstas uzslepimui';
%        watermark = 'Slaptas Tekstas';
%        watermark = 'hidden txt';
        watermark = 'scrt txt';
    end

    if nargin < 2
        file_path = in_dir;
    end

    if nargin < 3
        filename = 'carlin_blow_it.wav';
    end

    if nargin < 4
        Fs = Fs_default;
    end

    if nargin < 5
        zero_delay = zero_delay_default;
    end

    if nargin < 6
        one_delay = one_delay_default;
    end

    if nargin < 7
        decay_rate = decay_rate_default;
    end

    % Read the data from the File
    full_path = [file_path '/' filename];
    [header, input] = helpers.read_wav_file(full_path);

    watermark_bits = helpers.text2bits(watermark);
%     watermark_bits = [ 0; 1; 0; 1; 0; 1; 0; watermark_bits ];

    zero_delay_signal = single_echo(input, Fs, zero_delay, decay_rate);
    one_delay_signal = single_echo(input, Fs, one_delay, decay_rate);

    zero_delay = zero_delay / 1000;
    one_delay = one_delay / 1000;

    segment_length = round(Fs / 8);
    segment_transition_time = round(segment_length / 16);

    bitrate = round(Fs / (segment_length + segment_transition_time));

    length_in_s = round(length(input) / Fs);
    watermark_size = size(watermark_bits, 1);

    display(sprintf('Segment size: %d', segment_length));
    display(sprintf('Text length: %d', watermark_size));

    if watermark_size >= length_in_s * bitrate,
        throw(MException('EchoHider:NoSpace', ...
            'Not enough cover audio for the given bitrate (%d b/s, needed: %d bits, have: %d bits)\n', ...
            bitrate, watermark_size, length_in_s * bitrate));
    end

    fprintf('Attempting to embed %d bits of watermark data in %d seconds of audio (%d bits max) at %d b/s\n', ...
        watermark_size, length_in_s, length_in_s * bitrate, bitrate);

    % Initialize the mixer signals
    one_mixer_signal = zeros(size(input, 1), 1);
    zero_mixer_signal = zeros(size(input, 1), 1);
    original_mixer_signal = zeros(size(input, 1), 1);

    % Generate the one mixer signal based on watermark information
    last_bit = 2;
    one_mixer_position = 1;
    
    tic

    for index = 1 : watermark_size,
        watermark_bit = watermark_bits(index);
        % write the transition if necessary
        for i = 1 : segment_transition_time,
            if watermark_bit == last_bit || last_bit == 2
                one_mixer_signal(one_mixer_position + i) = watermark_bit;
            else
                if watermark_bit == 1,
                    trans_val = (i / segment_transition_time);
                else
                    trans_val = (segment_transition_time - i) ...
                        / segment_transition_time;
                end
                one_mixer_signal(one_mixer_position + i) = trans_val;
            end
        end
        
        one_mixer_position = one_mixer_position + segment_transition_time;

        % write the echo
        one_mixer_signal(one_mixer_position : one_mixer_position ...
            + segment_length) = watermark_bit;

        one_mixer_position = one_mixer_position + segment_length;

        last_bit = watermark_bit;
    end
    
    toc

    zero_mixer_signal = 1 - one_mixer_signal;
    original_mixer_signal = 1 - (zero_mixer_signal + one_mixer_signal);

    % Debug only
     size(zero_delay_signal);
     size(zero_mixer_signal);

    zero_signal = zero_delay_signal .* zero_mixer_signal;
    one_signal = one_delay_signal .* one_mixer_signal;
    original_signal = input .* original_mixer_signal;

    processed_wave = zero_signal + one_signal + original_signal;
    
    toc

    % Write the data back to a File
    output = processed_wave;

    % Plot out mixer signals
    figure(1);
    hold on;

    subplot(2, 1, 1);
    one_mixer_plot = plot(one_mixer_signal);
    set(one_mixer_plot, 'Color', 'green', 'LineWidth', 2);
    axis([-20, length(one_mixer_signal), -0.1, 1.1]);
    title('One mixer signal', 'fontweight', 'bold');
    xlabel('Time');
    ylabel('Offset intensity');

    subplot(2, 1, 2);
    zero_mixer_plot = plot(zero_mixer_signal);
    set(zero_mixer_plot, 'Color', 'red', 'LineWidth', 2);
    axis([-20, length(one_mixer_signal), -0.1, 1.1]);
    title('Zero mixer signal', 'fontweight', 'bold');
    xlabel('Time');
    ylabel('Offset intensity');

    % Plot out soudn wave signal aplitudes
    figure(3);
    hold on;

    subplot(3, 1, 1); 
    hold on;
    plot(1 : length(input), input);
    ylim([0 - 10 512 + 10]); 
    title('Input sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude');
    
    subplot(3, 1, 2);
    hold on;
    plot(1 : length(output), output);
    ylim([0 - 10 512 + 10]); 
    title('Output sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude');

    helpers.write_wav_file([out_dir_echo '/' filename], header, output);

end
