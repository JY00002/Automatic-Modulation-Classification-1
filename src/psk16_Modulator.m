function y = psk16_Modulator(x,sps)

persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
% Modulate
syms = pskmod(x,16);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

