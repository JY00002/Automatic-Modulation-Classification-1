function y = qam128_Modulator(x,sps)


persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
% Modulate
syms = qammod(x,128,'UnitAveragePower',true);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end

