function [header, data] = read_wav_file(filename)
fileID = fopen(filename,'r');
header = fread(fileID,44);
data = fread(fileID);
fclose(fileID);
end