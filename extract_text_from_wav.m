function [text] = extract_text_from_wav( textLength, filename )

if nargin < 2
    filename = 'stego_audio/carlin_blow_it.wav';
end

if nargin < 1
    textLength = 18;
end

l = 1024 * 3;
m = textLength * 8;

[~, input] = read_wav_file(filename);

Z = dft(input(1:l));
[~, theta] = magnitude_and_phase(Z);

figure(1);
subplot(3, 1, 3); plot(1:length(theta), theta); ylim([-2*pi 2*pi]);

phases = theta((l/2-m+1):(l/2));
textBits = phases < 0;

textBitsMatrix = reshape(textBits, 8, length(textBits)/8)';
textBytes = bi2de(textBitsMatrix);

text = native2unicode(textBytes)';

end

function Y = bi2de(X)
Y = zeros(size(X, 1), 1);
weights = 2.^(7:-1:0);
for i=1:size(X, 1) 
  Y(i) = sum(X(i,:) * weights');
end
end