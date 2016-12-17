function write_wav_file(filename, data, Fs)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

%     fileID = fopen(filename, 'w');
%     fwrite(fileID, header);
%     fwrite(fileID, data);
%     fclose(fileID);

    % NOTE: modified to work with all types of WAV's 
    audiowrite(filename, data, Fs);
end
