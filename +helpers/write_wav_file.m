function write_wav_file(filename, header, data)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    fileID = fopen(filename, 'w');
    fwrite(fileID, header);
    fwrite(fileID, data);
    fclose(fileID);
end
