clc;clear;close all;
%�����ź�����
% modulationTypes = categorical(["BPSK", "QPSK", "8PSK","16PSK","32PSK",...
%   "OQPSK" ,"DBPSK", "DQPSK"��"D8PSK"...
%   "16QAM", "32QAM","64QAM","128QAM","256QAM" "PAM4","PAM8" ,"2ASK","4ASK"...
%   "16APSK"��"32APSK"...
%   "GFSK", "2FSK", "4FSK" ,"MSK","GMSK",...
%   "B-FM", "DSB-AM", "SSB-AM"]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ѡ����Ҫ���ź�����%%%%%%%%%%%%%%%%%%%%%%%%%%%
modulationTypes = categorical(["BPSK", "QPSK", "8PSK", "16QAM", "2FSK", "MSK", "B-FM", "DSB-AM", "2ASK", "4FSK", "OQPSK"]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numFrames = 10000;                             % �����ܲ�����Ŀ(������)
sps=8;
% sps = [4 8 16 32];                            % ÿ�����ŵĲ����㣨�����ã���Ӱ�����ʣ�
spf = 1024;                                     % ������������-֡���ȣ������ã�
fs = 200e3;                                     % �����ʣ������ã�
first=5;                                        % ��ʼ����ȣ������ã�                   
last=10;                                        % ��ֹ����ȣ������ã�
numModulationTypes = length(modulationTypes);   % ��ȡ�ź�������Ŀ
numsps = length(sps);                           % ��ȡÿ���Ų�����������Ŀ                             
q=1;                                            % ѭ������
%%%%%%%%%%����һ����x��������ά������,���СΪ[1 2 spf],ʹ��9��ѹ��%%%%%%%%%%
data_name=["test_base_data5"];                                            %���ݼ����ƣ���Ҫ�趨��
file_name=["D:\data\"];                                                   %�ļ���·������Ҫ�趨��
new_folder=[file_name+data_name];                                         %�ļ�����·��
mkdir(new_folder);                                                        %����Ŀ���ļ���
filename=[new_folder+"\"+data_name+".h5"];                                %H5�ļ�����·��
%��������άH5�ļ�
h5create(filename,'/X',[Inf 2 spf],'Datatype','single', ...
           'ChunkSize',[1 2 spf],'Deflate',9)
h5create(filename,'/Y',[Inf numModulationTypes],'Datatype','int8', ...
           'ChunkSize',[1 numModulationTypes],'Deflate',9)
h5create(filename,'/Z',[Inf],'Datatype','int8', ...
           'ChunkSize',[1],'Deflate',9)
%�����ŵ���������˹�ྶ˥���ŵ���ʱ��ƫ�ƣ�����Ƶ��ƫ�ƣ�������ƫ�ƣ���˹��������
multipathChannel = comm.RicianChannel(...
  'SampleRate', fs, ...
  'PathDelays', [0 0.9 1.7] / fs, ...
  'AveragePathGains', [0 10*log(0.8) 10*log(0.3)], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 1);
t = (0:(2*spf-1))' / fs;
frequencyShifter = comm.PhaseFrequencyOffset(...
  'SampleRate', fs);
transDelay = 50;
while q<=numFrames
    % ���������ƫ��
    newFs = fs+[(rand() * 2*50) - 50];
    tp = (0:(2*spf-1))' / newFs; 
    %������Ʒ�ʽ
    modType=randi([1,numModulationTypes],1,1);
    %��������
    SNR=randi([first,last],1,1);
    %�����Ԫ����
    sps1=sps(randi([1,numsps],1,1));
    %����������ͬ�����ַ���
    dataSrc = get_Source(modulationTypes(modType), 4, 2*spf, fs);
    %����������
    modulator = get_Modulator(modulationTypes(modType), sps1, fs);
    % ��������ź�
    x = dataSrc();
    % ����
    y = modulator(x);
    y=y(1:2*spf);
    %ͨ����˹�ŵ�
    outMultipathChan = multipathChannel(y);
    %����Ƶ��ƫ��  
    frequencyShifter.FrequencyOffset = -[(rand() * 2*500) - 500];    %����rml     
    outFreqShifter = frequencyShifter(outMultipathChan);
    %������ƫ��
    outTimeDrift = interp1(t, outFreqShifter, tp);
    %������
    rxSamples = awgn(outTimeDrift,SNR,0);
    % ��һ��
    frame = normalize(rxSamples, spf, spf, transDelay, sps1);
    %��ȡIQ·��������������ת��
    frame = frame';
    Idata=single(real(frame));
    Qdata=single(imag(frame));
    data=[Idata;Qdata];
    final=reshape(data,[1 2 spf]);
    %����XYZд�����ʼλ�ú�д���С
    startx = [q 1 1];
    countx = [1 2 spf];
    starty = [q 1];
    county = [1 numModulationTypes]; 
    startz = [q];
    countz = [1]; 
    hotcode=int8(zeros(1,numModulationTypes));
    hotcode(modType)=1;
    SNR=int8(SNR);
    h5write(filename,'/X',final,startx,countx);
    h5write(filename,'/Y',hotcode,starty,county);
    h5write(filename,'/Z',SNR,startz,countz);
    q=q+1
end


