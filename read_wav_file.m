function [header, data] = read_wav_file(filename)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    fileID = fopen(filename, 'r');
    header = fread(fileID, 44);
    data = fread(fileID);
    fclose(fileID);
end
