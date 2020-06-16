function modulator = get_Modulator(modType, sps, fs)
%getModulator Modulation function selector
%   MOD = getModulator(TYPE,SPS,FS) returns the modulator function handle
%   MOD based on TYPE. SPS is the number of samples per symbol and FS is
%   the sample rate.

switch modType
  case "2ASK"
    modulator = @(x)ask2_Modulator(x,sps);
  case "4ASK"
    modulator = @(x)ask4_Modulator(x,sps);
  case "BPSK"
    modulator = @(x)bpsk_Modulator(x,sps);
  case "QPSK"
    modulator = @(x)qpsk_Modulator(x,sps);
  case "8PSK"
    modulator = @(x)psk8_Modulator(x,sps);
  case "16PSK"
    modulator = @(x)psk16_Modulator(x,sps);
  case "32PSK"
    modulator = @(x)psk32_Modulator(x,sps);
  case "DBPSK"
    modulator = @(x)dbpsk_Modulator(x,sps);
  case "DQPSK"
    modulator = @(x)dqpsk_Modulator(x,sps);
  case "D8PSK"
    modulator = @(x)d8psk_Modulator(x,sps);
  case "16QAM"
    modulator = @(x)qam16_Modulator(x,sps);
  case "32QAM"
    modulator = @(x)qam32_Modulator(x,sps);
  case "64QAM"
    modulator = @(x)qam64_Modulator(x,sps);
  case "128QAM"
    modulator = @(x)qam128_Modulator(x,sps);
  case "256QAM"
    modulator = @(x)qam256_Modulator(x,sps);
  case "16APSK"
    modulator = @(x)apsk16_Modulator(x,sps);
  case "32APSK"
    modulator = @(x)apsk32_Modulator(x,sps);
  case "GFSK"
    modulator = @(x)gfsk_Modulator(x,sps);
  case "2FSK"
    modulator = @(x)fsk2_Modulator(x,sps);
  case "4FSK"
    modulator = @(x)fsk4_Modulator(x,sps);
  case "MSK"
    modulator = @(x)msk_Modulator(x,sps);
  case "GMSK"
    modulator = @(x)gmsk_Modulator(x,sps);
  case "PAM4"
    modulator = @(x)pam4_Modulator(x,sps);
  case "PAM8"
    modulator = @(x)pam8_Modulator(x,sps);
  case "OQPSK"
    modulator = @(x)oqpsk_Modulator(x,sps);
  case "B-FM"
    modulator = @(x)bfm_Modulator(x, fs);
  case "DSB-AM"
    modulator = @(x)dsbam_Modulator(x, fs);
  case "SSB-AM"
    modulator = @(x)ssbam_Modulator(x, fs);
end
end