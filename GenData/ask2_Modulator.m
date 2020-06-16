function y = ask2_Modulator(x,sps)

persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
% Pulse shape
y = filter(filterCoeffs, 1, upsample(x,sps));
end