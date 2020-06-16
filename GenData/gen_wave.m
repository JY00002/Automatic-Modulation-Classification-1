%���ɵ����źŲ��鿴��ʱ��Ƶ������
clc;
clear;
close all;
%�����ź�����
modulationTypes = ["8PSK"];        %ѡ��Ҫ�鿴���ź����ͣ������ã�
% modulationTypes = categorical(["2ASK", "2FSK", "4FSK" ,"MSK","BPSK", "QPSK", "8PSK","16QAM", "OQPSK","B-FM", "DSB-AM"]);
% modulationTypes = categorical(["BPSK", "QPSK", "8PSK","16PSK"��"32PSK",...
%   "OQPSK" ,"DBPSK", "DQPSK"��"D8PSK"...
%   "16QAM", "32QAM","64QAM","128QAM","256QAM" "PAM4","PAM8" ,"2ASK","4ASK"...
%   "16APSK"��"32APSK"...
%   "GFSK", "2FSK", "4FSK" ,"MSK","GMSK",...
%   "B-FM", "DSB-AM", "SSB-AM"]);
%�������
sps = 8;                           % ÿ�����ŵĲ�����(������)
spf = 128;                        % �����������ȡ���֡���ȣ������ã�
fs = 200e3;                        % �����ʣ������ã�
fc = [902e6 100e6];                % ����Ƶ�ʣ������ã�[���ֵ�������Ƶ�� ģ���������Ƶ��]��
SNR=5;                            % ����ȣ������ã�
MaximumClockOffset=5;              % ���ʱ��ƫ�ƣ������ã�
symbolsPerFrame = spf / sps;       % ÿһ֡�ķ�����
%�����ŵ���������˹�ྶ˥���ŵ���ʱ��ƫ�ƣ�����Ƶ��ƫ�ƣ�������ƫ�ƣ���˹��������
channel = helperModClassTestChannel(...
  'SampleRate', fs, ...
  'SNR', SNR, ...
  'PathDelays', [0 1.8 3.4] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4, ...
  'MaximumClockOffset', MaximumClockOffset, ...
  'CenterFrequency', fc(1))
%���浱ǰʱ��
tic  
%����ŵ������Ϣ
channelInfo = info(channel);
transDelay = 50;
%�����ǰ�ź����ɵ���Ϣ,����ʱ�䣬������֡
fprintf('%s - Generating %s frames\n', ...
  datestr(toc/86400,'HH:MM:SS'), modulationTypes)
%����2*spf��M��������
dataSrc = get_Source(modulationTypes, sps, 2*spf, fs);
%����������
modulator = get_Modulator(modulationTypes, sps, fs);
%��������Ƶ�ʣ������źź�ģ���źŲ�ͬ
if contains(char(modulationTypes), {'B-FM','DSB-AM','SSB-AM'})
  % ģ���ź�����Ƶ��Ϊ100MHz
  channel.CenterFrequency = 100e6;
else
  % �����ź�����Ƶ��Ϊ902MHz
  channel.CenterFrequency = 902e6;
end
% ����M�����������
x = dataSrc();
% ����
y = modulator(x);
% ͨ���ŵ�
rxSamples_channel = channel(y);
frame_channel = normalize(rxSamples_channel, spf, spf, transDelay, sps);
%�����ŵ�
rxSamplesc_nonechannel = y;
frame_nonechannel = normalize(rxSamplesc_nonechannel, spf, spf, transDelay, sps);
%��һ��
figure(1);
n=length(frame_nonechannel);
f = (-n/2:n/2-1)*(fs/n);   % frequency range  
subplot(4,4,1);
plot(y,'o');
title('ԭʼ�ź�ɢ��ͼ');
subplot(4,4,5);
plot(abs(fftshift(fft(y))));
title('ԭʼ�ź�Ƶ��ͼ');
subplot(4,4,9);
plot(frame_channel,'o');
title('���ŵ�ɢ��ͼ');
subplot(4,4,13);
plot(frame_nonechannel,'o');
title('�����ŵ�ɢ��ͼ');
%��2��
subplot(4,4,2);
plot(f,abs(fftshift(fft(frame_channel))),'g');
title('���ŵ�������');
subplot(4,4,6);
plot(f,abs(fftshift(fft(frame_nonechannel))),'g');
title('�����ŵ�������');
subplot(4,4,10);
plot(f,abs(fftshift(fft(frame_channel.^2))),'g');
title('���ŵ�ƽ����');
subplot(4,4,14);
plot(f,abs(fftshift(fft(frame_nonechannel.^2))),'g');
title('�����ŵ�ƽ����');
%��3��
subplot(4,4,3);
plot(f,abs(fftshift(fft(frame_channel.^4))),'r');
title('���ŵ��Ĵ���');
subplot(4,4,7);
plot(f,abs(fftshift(fft(frame_nonechannel.^4))),'r');
title('�����ŵ��Ĵ���');
subplot(4,4,11);
plot(f,abs(fftshift(fft(frame_channel.^8))),'r');
title('���ŵ��˴���');
subplot(4,4,15);
plot(f,abs(fftshift(fft(frame_nonechannel.^8))),'r');
title('�����ŵ��˴���');
%��4��
% subplot(4,4,4);
% plot(abs(fftshift(fft(frame_channel_xcorr))),'c');
% title('���ŵ�ѭ����');
% subplot(4,4,8);
% plot(abs(fftshift(fft(frame_nonechannel_xcorr))),'c');
% title('�����ŵ�ѭ����');
% subplot(4,4,12);
% plot(abs(fftshift(fft(frame_channel))),'c');
% title('δȥ��Ƶ��');
% subplot(4,4,16);
% plot(abs(fftshift(fft(s2))),'c');
% title('ȥ��Ƶ��');

titlename=[modulationTypes+" ClockOffset="+MaximumClockOffset+" SNR="+SNR];
sgtitle(titlename) 