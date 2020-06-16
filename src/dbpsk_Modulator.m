function y = dbpsk_Modulator(x,sps)

persistent  mod filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
if isempty(mod)
  mod  = comm.DPSKModulator(2,pi/8,'BitInput',false);
end
%Modulate
syms = mod(x);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

