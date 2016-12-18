function [recovered_watermark] = extract_pc_watermark(text_length, ...
    file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Retrieve global variables

    [~, out_dir_pc, ~] = globals.global_folders();
    [sample_size, dft_impl, ~] = globals.global_vars_pc();

    % Analyze the specified aprameters set defaults wehere needed

    if nargin < 1
%         text_length = sample_size / 16; % entire segment (usable part)
%         text_length = 18;
        text_length = 15;
    end
    
    if nargin < 2
        file_path = out_dir_pc;
    end
    
    if nargin < 3
%         filename = 'carlin_blow_it.wav';
        filename = '69.wav';
    end

    % Read the data from the File
    full_path = [file_path '/' filename];

%    [~, input] = helpers.read_wav_file(full_path);
    [input_stereo, ~] = audioread(full_path, 'native');
    
    channel_count = size(input_stereo, 2);

    for channel_index = 1 : channel_count
        input_mono = double(input_stereo(:, channel_index));

        decoded_watermark = algorithm(input_mono, text_length, ...
            sample_size, dft_impl)

        % Experiment 1 - compute the similiraty between the expected result
        % and the decoded value

        % NOTE: this experiment is a dud, because it needs to be a lot more
        % complex and evaluate the results with a "sliding padding", in 
        % order to actually determine anything useful. Since the recovered 
        % text can have invalid segments at the start and end, witch will
        % mess up the entire similarity result!
        % Essiantially the results should be compared with both the
        % whitespaces removed and any completely random symbols in between

%          original_watermark = 'Tekstas uzslepimui';
        original_watermark = 'Slaptas Tekstas';
                %'scrt txt'; % 'ж∆ди@ири'; 'xxxX xXx'; 'xyxy 0%$';

        similarity = compute_vector_similarity( ...
            helpers.text2bits(original_watermark), ...
            helpers.text2bits(decoded_watermark));

        % Debug only
        similarity

    end

end

function [recovered_watermark] = algorithm(input_bits, text_length, ...
    sample_size, dft_impl)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    text_bit_length = text_length * 8;

    fprintf('Attempting to extract and decode %d bits of watermark data in a sample of %d bits (%d actually usable)\n', ...
        text_bit_length, sample_size, sample_size / 2);

    tic

    % Calculate starting position so that any silence in the begining of 
    % the recording can be safely ignored
    start_segment_position = find(input_bits, 1);

    Z = dft_impl(input_bits(start_segment_position ...
        : (start_segment_position - 1 + sample_size)));

    [~, theta] = magnitude_and_phase(Z);

    phases = theta((sample_size / 2 - text_bit_length + 1) ...
        : (sample_size / 2));

    % NOTE: should be '< -(pi / 2) - <some threashold>' if we want to be
    % completely accurate. But in general terms the below should do just
    % fine
    decoded_bit_string = phases < 0;

    toc

    % Debug only
%    decoded_bit_string

    % Retrieve the textual representation of the decoded information
    recovered_watermark = helpers.bits2text(decoded_bit_string);

    % Plot out the sound wave's signal frequencies and phases
    figure(1);
    hold on;

    subplot(3, 1, 3);
    hold on;
    plot(1 : length(theta), theta, 'r');
    ylim([-2 * pi 2 * pi]);
    title('Phase values of sample 1 read from stego audio', ...
        'fontweight', 'bold');
    xlabel('frequency');
    ylabel('phase, rad');

    % Plot out the sound wave's signal amplitudes
    figure(3);
    hold on;

    subplot(3, 1, 3); 
    hold on;
    plot(1 : length(input_bits), input_bits);
    ylim([min(input_bits) - 10 max(input_bits) + 10]); 
    title('Encoded sound signal', 'fontweight', 'bold'); 
    xlabel('time');
    ylabel('amplitude');

end
