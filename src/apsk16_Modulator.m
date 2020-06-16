function y =apsk16_Modulator(x,sps)
M = [8 8];
radii = [0.5 1.5];
persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
%µ÷ÖÆ
syms = apskmod(x,M,radii);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end






