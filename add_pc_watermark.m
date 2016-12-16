function add_pc_watermark(watermark, file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Retrieve global variables

    [l, dft_impl, idft_impl] = global_vars_pc();
    [in_dir, out_dir_pc, ~] = global_folders();

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
    [header, input] = read_wav_file(full_path);

    textBits = text2bits(watermark);

    m = length(textBits);
    display(sprintf('segment size: %d', l));
    display(sprintf('Text length: %d', length(watermark)));

    % Compute 'deltaTheta' – the amount to shift phases
    Z = dft_impl(input(1 : l));
    [~, theta] = magnitude_and_phase(Z);
    deltaTheta = theta;
    phases = textBits * (-pi) + (pi / 2);
    deltaTheta((l / 2 - m + 1) : (l / 2)) = phases;
    deltaTheta((l / 2 + 2) : (l / 2 + m + 1)) = -phases(end : -1 : 1);
    deltaTheta = deltaTheta - theta;

    output = zeros(size(input));

    tic

    for i = 1 : (length(input) / l)
        segmentStart = (i - 1) * l + 1;
        segmentEnd = segmentStart + l - 1;

        % Shift phases of the segment
        Z = dft_impl(input(segmentStart:segmentEnd));
        [R, theta] = magnitude_and_phase(Z);
        newTheta = theta + deltaTheta;
        Z = R .* exp(1i * newTheta);
        output(segmentStart : segmentEnd) = idft_impl(Z);

        figure(min([i 2]))
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

    figure(3)

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

    % Write the data back to a File
    write_wav_file([out_dir_pc '/' filename], header, output);

end

function Y = de2bi(X)
    Y = zeros(size(X, 1), 8);
    for i = 1 : size(X, 1)
        Y(i, :) = bitget(X(i), 8 : -1 : 1);
    end
end

function [ textBits ] = text2bits(text)
    textBytes = unicode2native(text)';
    textBitsMatrix = de2bi(textBytes);
    textBits = reshape(textBitsMatrix', length(textBitsMatrix(:)), 1);
end
