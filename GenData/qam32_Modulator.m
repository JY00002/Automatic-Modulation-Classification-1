function y = qam32_Modulator(x,sps)

persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
% Modulate and pulse shape
syms = qammod(x,32,'UnitAveragePower',true);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

