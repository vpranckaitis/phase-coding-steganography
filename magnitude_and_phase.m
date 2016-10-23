function [R, theta] = magnitude_and_phase(Z)
R = sqrt(real(Z).^2 + imag(Z).^2);
theta = atan2(imag(Z),real(Z));
end