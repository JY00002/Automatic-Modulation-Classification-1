function y = pam8_Modulator(x,sps)
%pam8Modulator PAM8 modulator with pulse shaping
%   Y = pam4Modulator(X,SPS) PAM8 modulates the input X, and returns the
%   root-raised cosine pulse shaped signal Y. X must be a column vector
%   of values in the set [0 7]. The root-raised cosine filter has a
%   roll-off factor of 0.35 and spans four symbols. The output signal
%   Y has unit power.

persistent filterCoeffs amp
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
  amp = 1 / sqrt(mean(abs(pammod(0:7, 8)).^2));
end
% Modulate
syms = amp * pammod(x,8);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

