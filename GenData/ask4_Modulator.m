function y = ask4_Modulator(x,sps)

syms=[]
for i=1:length(x)
    syms(i)=(x(i)+1)*2;
end
persistent filterCoeffs
if isempty(filterCoeffs)
  filterCoeffs = rcosdesign(0.35, 4, sps);
end
% Pulse shape
y = filter(filterCoeffs, 1, upsample(syms,sps));
y = y';
end