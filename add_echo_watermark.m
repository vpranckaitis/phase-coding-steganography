function [processed_wave] = add_echo_watermark(watermark, file_path, filename, Fs, zero_delay, one_delay, decay_rate)
    % UNTITLED Summary of this function goes here
    %	Detailed explanation goes here

    [alpha_default, Fs_default, zero_delay_default, one_delay_default, ...
        decay_rate_default] = global_vars_echo();

    [in_dir, out_dir_lsb, out_dir_echo] = global_folders();

    if nargin < 1
        watermark = 'Tekstas uzslepimui';
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

    [header, input] = read_wav_file(full_path);


    zero_delay_signal = single_echo(input, Fs, zero_delay, decay_rate);
    one_delay_signal = single_echo(input, Fs, one_delay, decay_rate);

    zero_delay = zero_delay / 1000;
    one_delay = one_delay / 1000;

    watermark = dec2bin(watermark);
    watermark = ['0', '1', '0', '1', '0', '1', '0'; watermark];
    segment_length = round(Fs / 16);
    segment_transition_time = round(segment_length / 32);

    bitrate = round(Fs / (segment_length + segment_transition_time));
    length_in_s = round(length(input) / Fs);
    watermark_len = (size(watermark, 1) * size(watermark, 2));

    if watermark_len >= length_in_s * bitrate,
        throw(MException('EchoHider:NoSpace', 'Not enough cover audio for the given bitrate (%d b/s, needed: %d bits, have: %d bits)\n', bitrate, watermark_len,length_in_s * bitrate));
    end

    fprintf('Attempting to embed %d bits of watermark data in %d seconds of audio (%d bits max) at %d b/s\n', watermark_len, length_in_s, length_in_s * bitrate, bitrate);
    
    one_mixer_signal = zeros(size(input, 1), 1);
    zero_mixer_signal = zeros(size(input, 1), 1);
    original_mixer_signal = zeros(size(input, 1), 1);
    
    % generate the one mixer signal based on watermark information
    last_bit = 2;
    one_mixer_position = 1;

    for char = 1 : size(watermark, 1),
        for bit = 1 : size(watermark, 2),
            watermark_bit = str2num(watermark(char, bit));
            % write the transition if necessary
            for i = 1 : segment_transition_time,
                if watermark_bit == last_bit || last_bit == 2
                    one_mixer_signal(one_mixer_position + i) = watermark_bit;
                else
                    if watermark_bit == 1,
                        trans_val = (i / segment_transition_time);
                    else
                        trans_val = (segment_transition_time - i) / segment_transition_time;
                    end
                    one_mixer_signal(one_mixer_position + i) = trans_val;
                end
            end
            
            one_mixer_position = one_mixer_position + segment_transition_time;
            % write the echo
            one_mixer_signal(one_mixer_position : one_mixer_position + segment_length) = watermark_bit;
            one_mixer_position = one_mixer_position + segment_length;
            last_bit = watermark_bit;
        end
    end

    zero_mixer_signal = 1 - one_mixer_signal;
    original_mixer_signal = 1 - (zero_mixer_signal + one_mixer_signal);

    size(zero_delay_signal);
    size(zero_mixer_signal);

    zero_signal = zero_delay_signal .* zero_mixer_signal;
    one_signal = one_delay_signal .* one_mixer_signal;
    original_signal = input .* original_mixer_signal;

    processed_wave = zero_signal + one_signal + original_signal;

    figure(1);
    hold on;
    axis([-20, length(zero_mixer_signal), -0.1, 1.1]);
    q = plot(one_mixer_signal);
    set(q, 'Color', 'black', 'LineWidth', 2);

    % Write the data back to a File
    output = processed_wave;

    write_wav_file([out_dir_echo '/' filename], header, output);

end
