function y =apsk32_Modulator(x,sps)
M = [4 8 20];
radii = [0.3 0.7 1.2];
persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
%µ÷ÖÆ
syms = apskmod(x,M,radii);
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
end






