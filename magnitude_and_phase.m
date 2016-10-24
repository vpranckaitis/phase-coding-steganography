function [R, theta] = magnitude_and_phase(Z)
    % UNTITLED Summary of this function goes here
    % Detailed explanation goes here

    R = sqrt(real(Z) .^ 2 + imag(Z) .^ 2);
    theta = atan2(imag(Z), real(Z));
end
