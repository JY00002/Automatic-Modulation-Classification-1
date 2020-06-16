function y = pam4_Modulator(x,sps)
%pam4Modulator PAM4 modulator with pulse shaping
%   Y = pam4Modulator(X,SPS) PAM4 modulates the input X, and returns the
%   root-raised cosine pulse shaped signal Y. X must be a column vector
%   of values in the set [0 3]. The root-raised cosine filter has a
%   roll-off factor of 0.35 and spans four symbols. The output signal
%   Y has unit power.

persistent filterCoeffs amp
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
  amp = 1 / sqrt(mean(abs(pammod(0:3, 4)).^2));
end
% Modulate
syms = amp * pammod(x,4);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

