function hide_text_in_wav( text, filename )

if nargin < 2
    filename = 'audio/carlin_blow_it.wav';
end

if nargin < 1
    text = 'Tekstas uzslepimui';
end

textBytes = unicode2native(text)';
textBitsMatrix = de2bi(textBytes);
textBits = reshape(textBitsMatrix',length(textBitsMatrix(:)),1);

m = length(textBits);
l = 1024 * 3;
display(sprintf('Segment size: %d', l));
display(sprintf('Text length: %d', length(text)));

[header, input] = read_wav_file(filename);

Z = dft(input(1:l));
[~, theta] = magnitude_and_phase(Z);
deltaTheta = theta;
phases = textBits*(-pi) + (pi / 2);
deltaTheta((l/2-m+1):(l/2)) = phases;
deltaTheta((l/2+2):(l/2+m+1)) = -phases(end:-1:1);
deltaTheta = deltaTheta - theta;

output = zeros(size(input));

for i=1:(length(input)/l)
    sampleStart = (i - 1) * l + 1;
    sampleEnd = sampleStart + l - 1;
    
    Z = dft(input(sampleStart:sampleEnd));
    [R, theta] = magnitude_and_phase(Z);
    newTheta = theta + deltaTheta;
    Z = R.*exp(1i*newTheta);
    output(sampleStart:sampleEnd) = idft(Z);
    
    figure(min([i 2]))
    subplot(3, 1, 1); plot(1:length(theta),theta); ylim([-2*pi 2*pi]);
    subplot(3, 1, 2); plot(1:length(newTheta),newTheta); ylim([-2*pi 2*pi]);
end
figure(3)
subplot(2, 1, 1); plot(1:length(input),input); ylim([0-10 256+10]);
subplot(2, 1, 2); plot(1:length(output),output); ylim([0-10 256+10]);

write_wav_file(strcat('stego_',filename), header, output);

end

function write_wav_file(filename, header, data)
fileID = fopen(filename,'w');
fwrite(fileID,header);
fwrite(fileID,data);
fclose(fileID);
end

function Y = de2bi(X)
Y = zeros(size(X, 1), 8);
for i=1:size(X, 1) 
  Y(i,:) = bitget(X(i), 8:-1:1);
end
end