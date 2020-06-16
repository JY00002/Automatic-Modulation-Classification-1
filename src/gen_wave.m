%生成单个信号并查看其时域频域特性
clc;
clear;
close all;
%定义信号种类
modulationTypes = ["8PSK"];        %选择要查看的信号类型（可设置）
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
fc = [902e6 100e6];                % 中心频率（可设置，[数字调制中心频率 模拟调制中心频率]）
SNR=5;                            % 信噪比（可设置）
MaximumClockOffset=5;              % 最大时钟偏移（可设置）
symbolsPerFrame = spf / sps;       % 每一帧的符号数
%生成信道，包含莱斯多径衰落信道，时钟偏移，中心频率偏移，采样率偏移，高斯噪声因素
channel = helperModClassTestChannel(...
  'SampleRate', fs, ...
  'SNR', SNR, ...
  'PathDelays', [0 1.8 3.4] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4, ...
  'MaximumClockOffset', MaximumClockOffset, ...
  'CenterFrequency', fc(1))
%保存当前时间
tic  
%输出信道相关信息
channelInfo = info(channel);
transDelay = 50;
%输出当前信号生成的信息,包括时间，产生的帧
fprintf('%s - Generating %s frames\n', ...
  datestr(toc/86400,'HH:MM:SS'), modulationTypes)
%产生2*spf个M进制数字
dataSrc = get_Source(modulationTypes, sps, 2*spf, fs);
%产生调制器
modulator = get_Modulator(modulationTypes, sps, fs);
%设置中心频率，数字信号和模拟信号不同
if contains(char(modulationTypes), {'B-FM','DSB-AM','SSB-AM'})
  % 模拟信号中心频率为100MHz
  channel.CenterFrequency = 100e6;
else
  % 数字信号中心频率为902MHz
  channel.CenterFrequency = 902e6;
end
% 生成M进制随机序列
x = dataSrc();
% 调制
y = modulator(x);
% 通过信道
rxSamples_channel = channel(y);
frame_channel = normalize(rxSamples_channel, spf, spf, transDelay, sps);
%不过信道
rxSamplesc_nonechannel = y;
frame_nonechannel = normalize(rxSamplesc_nonechannel, spf, spf, transDelay, sps);
%第一列
figure(1);
n=length(frame_nonechannel);
f = (-n/2:n/2-1)*(fs/n);   % frequency range  
subplot(4,4,1);
plot(y,'o');
title('原始信号散点图');
subplot(4,4,5);
plot(abs(fftshift(fft(y))));
title('原始信号频谱图');
subplot(4,4,9);
plot(frame_channel,'o');
title('过信道散点图');
subplot(4,4,13);
plot(frame_nonechannel,'o');
title('不过信道散点图');
%第2列
subplot(4,4,2);
plot(f,abs(fftshift(fft(frame_channel))),'g');
title('过信道包络谱');
subplot(4,4,6);
plot(f,abs(fftshift(fft(frame_nonechannel))),'g');
title('不过信道包络谱');
subplot(4,4,10);
plot(f,abs(fftshift(fft(frame_channel.^2))),'g');
title('过信道平方谱');
subplot(4,4,14);
plot(f,abs(fftshift(fft(frame_nonechannel.^2))),'g');
title('不过信道平方谱');
%第3列
subplot(4,4,3);
plot(f,abs(fftshift(fft(frame_channel.^4))),'r');
title('过信道四次谱');
subplot(4,4,7);
plot(f,abs(fftshift(fft(frame_nonechannel.^4))),'r');
title('不过信道四次谱');
subplot(4,4,11);
plot(f,abs(fftshift(fft(frame_channel.^8))),'r');
title('过信道八次谱');
subplot(4,4,15);
plot(f,abs(fftshift(fft(frame_nonechannel.^8))),'r');
title('不过信道八次谱');
%第4列
% subplot(4,4,4);
% plot(abs(fftshift(fft(frame_channel_xcorr))),'c');
% title('过信道循环谱');
% subplot(4,4,8);
% plot(abs(fftshift(fft(frame_nonechannel_xcorr))),'c');
% title('不过信道循环谱');
% subplot(4,4,12);
% plot(abs(fftshift(fft(frame_channel))),'c');
% title('未去噪频谱');
% subplot(4,4,16);
% plot(abs(fftshift(fft(s2))),'c');
% title('去噪频谱');

titlename=[modulationTypes+" ClockOffset="+MaximumClockOffset+" SNR="+SNR];
sgtitle(titlename) 