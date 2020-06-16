%���ɵ����źŲ��鿴��ʱ��Ƶ������
clc;
clear;
close all;
%�����ź�����
modulationTypes = ["QPSK"];        %ѡ��Ҫ�鿴���ź����ͣ������ã�
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
fc = 70e6;                        % ����Ƶ�ʣ������ã�[���ֵ�������Ƶ�� ģ���������Ƶ��]��
SNR=5;                             % ����ȣ������ã�
maxOffset=5;              % ���ʱ��ƫ�ƣ������ã�
symbolsPerFrame = spf / sps;       % ÿһ֡�ķ�����
%�����ŵ���������˹�ྶ˥���ŵ�������Ƶ��ƫ�ƣ�������ƫ�ƣ���˹��������
multipathChannel = comm.RicianChannel(...
  'SampleRate', fs, ...
  'PathDelays', [0 1.8 3.4] / 200e3, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4);
% ����ƫ������C
clockOffset = (rand() * 2*maxOffset) - maxOffset;
C = 1 + clockOffset / 1e6;
% �����ز�Ƶ��ƫ��
frequencyShifter = comm.PhaseFrequencyOffset(...
  'SampleRate', fs);
frequencyShifter.FrequencyOffset = -(C-1)*fc;
% ���������ƫ��
t = (0:(2*spf-1))' / fs;
newFs = fs * C;
tp = (0:(2*spf-1))' / newFs;
true = newFs*1/C;
tt = (0:(2*spf-1))' / true;
%���浱ǰʱ��
tic  
%����ŵ������Ϣ
transDelay = 50;
%�����ǰ�ź����ɵ���Ϣ,����ʱ�䣬������֡
fprintf('%s - Generating %s frames\n', ...
  datestr(toc/86400,'HH:MM:SS'), modulationTypes)
%����2*spf��M��������
dataSrc = get_Source(modulationTypes, sps, 2*spf, fs);
%����������
modulator = get_Modulator(modulationTypes, sps, fs);
% ����M�����������
x = dataSrc();
% ����
y = modulator(x);
rx1 = awgn(y,SNR,0);
frame_channel1 = normalize(rx1, spf, spf, transDelay, sps);
% ����˹�ྶ˥��
outMultipathChan = multipathChannel(y);
rx2 = awgn(outMultipathChan,SNR,0);
frame_channel2 = normalize(rx2, spf, spf, transDelay, sps);
% ������Ƶ��ƫ��
outFreqShifter = frequencyShifter(outMultipathChan);
rx3= awgn(outFreqShifter,SNR,0);
frame_channel3 = normalize(rx3, spf, spf, transDelay, sps);
% �Ӳ�����ƫ��
outTimeDrift = interp1(t, outFreqShifter, tp);
rx4 = awgn(outTimeDrift,SNR,0);
frame_channel4= normalize(rx4, spf, spf, transDelay, sps);

%��һ��
figure(1);
n=length(frame_channel1);
f = (-n/2:n/2-1)*(fs/n);   % frequency range  
subplot(4,4,1);
plot(f,abs(fftshift(fft(frame_channel1))));
title('ԭʼ������');
subplot(4,4,5);
plot(f,abs(fftshift(fft(frame_channel1.^2))));
title('ԭʼ���η���');
subplot(4,4,9);
plot(f,abs(fftshift(fft(frame_channel1.^4))));
title('ԭʼ4����');
subplot(4,4,13);
plot(f,abs(fftshift(fft(frame_channel1.^8))));
title('ԭʼ8����');
%��2��
subplot(4,4,2);
plot(f,abs(fftshift(fft(frame_channel2))));
title('��˹������');
subplot(4,4,6);
plot(f,abs(fftshift(fft(frame_channel2.^2))));
title('��˹2����');
subplot(4,4,10);
plot(f,abs(fftshift(fft(frame_channel2.^4))));
title('��˹4����');
subplot(4,4,14);
plot(f,abs(fftshift(fft(frame_channel2.^8))));
title('��˹8����');
%��3��
subplot(4,4,3);
plot(f,abs(fftshift(fft(frame_channel3))));
title('��˹+CFO������');
subplot(4,4,7);
plot(f,abs(fftshift(fft(frame_channel3.^2))));
title('��˹+CFO2����');
subplot(4,4,11);
plot(f,abs(fftshift(fft(frame_channel3.^4))));
title('��˹+CFO4����');
subplot(4,4,15);
plot(f,abs(fftshift(fft(frame_channel3.^8))));
title('��˹+CFO8����');
%��4��
subplot(4,4,4);
plot(f,abs(fftshift(fft(frame_channel4))));
title('��˹+CFO+SFO������');
subplot(4,4,8);
plot(f,abs(fftshift(fft(frame_channel4.^2))));
title('��˹+CFO+SFO2����');
subplot(4,4,12);
plot(f,abs(fftshift(fft(frame_channel4.^4))));
title('��˹+CFO+SFO4����');
subplot(4,4,16);
plot(f,abs(fftshift(fft(frame_channel4.^8))));
title('��˹+CFO+SFO8����');
% 
titlename=[modulationTypes+" ClockOffset="+maxOffset+" SNR="+SNR];
sgtitle(titlename) 