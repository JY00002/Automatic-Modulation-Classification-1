function y = qam16_Modulator(x,sps)
%qam16Modulator 16-QAM modulator with pulse shaping
%   Y = qam16Modulator(X,SPS) 16-QAM modulates the input X, and returns the
%   root-raised cosine pulse shaped signal Y. X must be a column vector
%   of values in the set [0 15]. The root-raised cosine filter has a
%   roll-off factor of 0.35 and spans four symbols. The output signal
%   Y has unit power.

persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
% Modulate and pulse shape
syms = qammod(x,16,'UnitAveragePower',true);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

