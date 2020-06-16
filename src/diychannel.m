%生成单个信号并查看其时域频域特性
clc;
clear;
close all;
%定义信号种类
modulationTypes = ["QPSK"];        %选择要查看的信号类型（可设置）
% modulationTypes = categorical(["2ASK", "2FSK", "4FSK" ,"MSK","BPSK", "QPSK", "8PSK","16QAM", "OQPSK","B-FM", "DSB-AM"]);
% modulationTypes = categorical(["BPSK", "QPSK", "8PSK","16PSK"，"32PSK",...
%   "OQPSK" ,"DBPSK", "DQPSK"，"D8PSK"...
%   "16QAM", "32QAM","64QAM","128QAM","256QAM" "PAM4","PAM8" ,"2ASK","4ASK"...
%   "16APSK"，"32APSK"...
%   "GFSK", "2FSK", "4FSK" ,"MSK","GMSK",...
%   "B-FM", "DSB-AM", "SSB-AM"]);
%定义参数
sps = 8;                           % 每个符号的采样点(可设置)
spf = 128;                        % 单个样本长度——帧长度（可设置）
fs = 200e3;                        % 采样率（可设置）
fc = 70e6;                        % 中心频率（可设置，[数字调制中心频率 模拟调制中心频率]）
SNR=5;                             % 信噪比（可设置）
maxOffset=5;              % 最大时钟偏移（可设置）
symbolsPerFrame = spf / sps;       % 每一帧的符号数
%生成信道，包含莱斯多径衰落信道，中心频率偏移，采样率偏移，高斯噪声因素
multipathChannel = comm.RicianChannel(...
  'SampleRate', fs, ...
  'PathDelays', [0 1.8 3.4] / 200e3, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4);
% 计算偏移因子C
clockOffset = (rand() * 2*maxOffset) - maxOffset;
C = 1 + clockOffset / 1e6;
% 计算载波频率偏移
frequencyShifter = comm.PhaseFrequencyOffset(...
  'SampleRate', fs);
frequencyShifter.FrequencyOffset = -(C-1)*fc;
% 计算采样率偏移
t = (0:(2*spf-1))' / fs;
newFs = fs * C;
tp = (0:(2*spf-1))' / newFs;
true = newFs*1/C;
tt = (0:(2*spf-1))' / true;
%保存当前时间
tic  
%输出信道相关信息
transDelay = 50;
%输出当前信号生成的信息,包括时间，产生的帧
fprintf('%s - Generating %s frames\n', ...
  datestr(toc/86400,'HH:MM:SS'), modulationTypes)
%产生2*spf个M进制数字
dataSrc = get_Source(modulationTypes, sps, 2*spf, fs);
%产生调制器
modulator = get_Modulator(modulationTypes, sps, fs);
% 生成M进制随机序列
x = dataSrc();
% 调制
y = modulator(x);
rx1 = awgn(y,SNR,0);
frame_channel1 = normalize(rx1, spf, spf, transDelay, sps);
% 过莱斯多径衰落
outMultipathChan = multipathChannel(y);
rx2 = awgn(outMultipathChan,SNR,0);
frame_channel2 = normalize(rx2, spf, spf, transDelay, sps);
% 加中心频率偏移
outFreqShifter = frequencyShifter(outMultipathChan);
rx3= awgn(outFreqShifter,SNR,0);
frame_channel3 = normalize(rx3, spf, spf, transDelay, sps);
% 加采样率偏移
outTimeDrift = interp1(t, outFreqShifter, tp);
rx4 = awgn(outTimeDrift,SNR,0);
frame_channel4= normalize(rx4, spf, spf, transDelay, sps);

%第一列
figure(1);
n=length(frame_channel1);
f = (-n/2:n/2-1)*(fs/n);   % frequency range  
subplot(4,4,1);
plot(f,abs(fftshift(fft(frame_channel1))));
title('原始包络谱');
subplot(4,4,5);
plot(f,abs(fftshift(fft(frame_channel1.^2))));
title('原始二次方谱');
subplot(4,4,9);
plot(f,abs(fftshift(fft(frame_channel1.^4))));
title('原始4次谱');
subplot(4,4,13);
plot(f,abs(fftshift(fft(frame_channel1.^8))));
title('原始8次谱');
%第2列
subplot(4,4,2);
plot(f,abs(fftshift(fft(frame_channel2))));
title('莱斯包络谱');
subplot(4,4,6);
plot(f,abs(fftshift(fft(frame_channel2.^2))));
title('莱斯2次谱');
subplot(4,4,10);
plot(f,abs(fftshift(fft(frame_channel2.^4))));
title('莱斯4次谱');
subplot(4,4,14);
plot(f,abs(fftshift(fft(frame_channel2.^8))));
title('莱斯8次谱');
%第3列
subplot(4,4,3);
plot(f,abs(fftshift(fft(frame_channel3))));
title('莱斯+CFO包络谱');
subplot(4,4,7);
plot(f,abs(fftshift(fft(frame_channel3.^2))));
title('莱斯+CFO2次谱');
subplot(4,4,11);
plot(f,abs(fftshift(fft(frame_channel3.^4))));
title('莱斯+CFO4次谱');
subplot(4,4,15);
plot(f,abs(fftshift(fft(frame_channel3.^8))));
title('莱斯+CFO8次谱');
%第4列
subplot(4,4,4);
plot(f,abs(fftshift(fft(frame_channel4))));
title('莱斯+CFO+SFO包络谱');
subplot(4,4,8);
plot(f,abs(fftshift(fft(frame_channel4.^2))));
title('莱斯+CFO+SFO2次谱');
subplot(4,4,12);
plot(f,abs(fftshift(fft(frame_channel4.^4))));
title('莱斯+CFO+SFO4次谱');
subplot(4,4,16);
plot(f,abs(fftshift(fft(frame_channel4.^8))));
title('莱斯+CFO+SFO8次谱');
% 
titlename=[modulationTypes+" ClockOffset="+maxOffset+" SNR="+SNR];
sgtitle(titlename) 