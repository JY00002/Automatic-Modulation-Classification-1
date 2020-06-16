function y = oqpsk_Modulator(x,sps)

persistent  mod
if isempty(mod)
  mod  = comm.OQPSKModulator('BitInput',false,'SamplesPerSymbol',sps,'PulseShape','Root raised cosine','RolloffFactor',0.35,'FilterSpanInSymbols',4);
end
%Modulate
y = mod(x);
end

