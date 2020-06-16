function y = gfsk_Modulator(x,sps)
%gfskModulator GFSK modulator
%   Y = gfskModulator(X,SPS) GFSK modulates the input X and returns the
%   signal Y. X must be a column vector of values in the set [0 1]. The
%   BT product is 0.35 and the modulation index is 1. The output signal
%   Y has unit power.

persistent mod meanM
if isempty(mod)
  M = 2;
  mod = comm.CPMModulator(...
    'ModulationOrder', M, ...
    'FrequencyPulse', 'Gaussian', ...
    'BandwidthTimeProduct', 0.35, ...
    'ModulationIndex', 1, ...
    'SamplesPerSymbol', sps);
  meanM = mean(0:M-1);
end
% Modulate
y = mod(2*(x-meanM));
end

