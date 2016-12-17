function [init_amplitude, Fs, sample_size, zero_delay, one_delay, ...
    decay_rate] = global_vars_echo()

    % UNTITLED Summary of this function goes here
    %    Detailed explanation goes here

    % The values for these default constants have been taken from the
    % articles and case studies mentioned below.
    %  - http://www.fim.uni-linz.ac.at/lva/Rechtliche_Aspekte/2001SS/Stegano/leseecke/echo%20data%20hiding%20by%20d.%20gruhl%20and%20w.%20bender.pdf
    %  - http://www.tmrfindia.org/ijcsa/v10i11.pdf

    init_amplitude = 0.2;
    Fs = 11025; %44100; % Frequency of sampling
    sample_size = 8; %16; % Bites per sample
    zero_delay = 0.61; %2; %0.61; % Should result in 27 samples
    one_delay = 0.73; %4; %0.73; % Should result in 32 samples
    decay_rate = 0.8; % Must be between 0.3 and 0.85
end
