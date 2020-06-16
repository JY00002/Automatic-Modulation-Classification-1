function y = fsk4_Modulator(x,sps)
%4fskModulator CPFSK modulator
%   Y = fsk4Modulator(X,SPS) 4FSK modulates the input X and returns
%   the signal Y. X must be a column vector of values in the set [0 1].
%   the modulation index is 0.5. The output signal Y has unit power.

persistent mod meanM
if isempty(mod)
  M = 4;
  mod = comm.CPFSKModulator(...
    'ModulationOrder', M, ...
    'ModulationIndex', 2, ...
    'SamplesPerSymbol', sps);
  meanM = mean(0:M-1);
end
% Modulate
y = mod(2*(x-meanM));
end
