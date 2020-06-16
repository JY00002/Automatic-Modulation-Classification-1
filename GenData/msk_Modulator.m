function y = msk_Modulator(x,sps)
%mskModulator MSK modulator
%   Y = msk_Modulator(X,SPS) MSK modulates the input X and returns
%   the signal Y. X must be a column vector of values in the set [0 1].
%   the modulation index is 0.5. The output signal Y has unit power.

persistent mod 
if isempty(mod)
  mod = comm.MSKModulator(...
    'BitInput', true, ...
    'InitialPhaseOffset', pi/4, ...
    'SamplesPerSymbol', sps);
end
% Modulate
y = mod(x);
end
