function add_pc_watermark(watermark, file_path, filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    [in_dir, out_dir_pc, ~] = global_folders();

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


    textBytes = unicode2native(watermark)';
    textBitsMatrix = de2bi(textBytes);
    textBits = reshape(textBitsMatrix', length(textBitsMatrix(:)), 1);

    m = length(textBits);
    [l, dft_impl, idft_impl] = global_vars_pc();
    display(sprintf('Sample size: %d', l));
    display(sprintf('Text length: %d', length(watermark)));

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
        sampleStart = (i - 1) * l + 1;
        sampleEnd = sampleStart + l - 1;

        Z = dft_impl(input(sampleStart:sampleEnd));
        [R, theta] = magnitude_and_phase(Z);
        newTheta = theta + deltaTheta;
        Z = R .* exp(1i * newTheta);
        output(sampleStart : sampleEnd) = idft_impl(Z);

        figure(min([i 2]))
        subplot(3, 1, 1); plot(1 : length(theta), theta); ylim([-2 * pi 2 * pi]);
        subplot(3, 1, 2); plot(1 : length(newTheta), newTheta); ylim([-2 * pi 2 * pi]);
    end
    toc

    figure(3)
    subplot(2, 1, 1); plot(1 : length(input), input); ylim([0 - 10 256 + 10]);
    subplot(2, 1, 2); plot(1 : length(output) ,output); ylim([0 - 10 256 + 10]);

    % Write the data back to a File
    write_wav_file([out_dir_pc '/' filename], header, output);

end

function Y = de2bi(X)
    Y = zeros(size(X, 1), 8);
    for i = 1 : size(X, 1)
        Y(i, :) = bitget(X(i), 8 : -1 : 1);
    end
end
