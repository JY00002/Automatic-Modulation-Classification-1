clc;clear;close all;
%定义信号种类
% modulationTypes = categorical(["BPSK", "QPSK", "8PSK","16PSK","32PSK",...
%   "OQPSK" ,"DBPSK", "DQPSK"，"D8PSK"...
%   "16QAM", "32QAM","64QAM","128QAM","256QAM" "PAM4","PAM8" ,"2ASK","4ASK"...
%   "16APSK"，"32APSK"...
%   "GFSK", "2FSK", "4FSK" ,"MSK","GMSK",...
%   "B-FM", "DSB-AM", "SSB-AM"]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%选择需要的信号种类%%%%%%%%%%%%%%%%%%%%%%%%%%%
modulationTypes = categorical(["BPSK", "QPSK", "8PSK", "16QAM", "2FSK", "MSK", "B-FM", "DSB-AM", "2ASK", "4FSK", "OQPSK"]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%定义参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numFrames = 100000;                             % 产生总测试数目(可设置)
sps = [4 8 16 32];                              % 每个符号的采样点（可设置，会影响码率）
spf = 1024;                                     % 单个样本长度-帧长度（可设置）
fs = 200e3;                                     % 采样率（可设置）
first=5;                                        % 起始信噪比（可设置）                   
last=10;                                        % 截止信噪比（可设置）
maxOffset = 5;                                  % 最大偏移因子（可设置）
numModulationTypes = length(modulationTypes);   % 获取信号种类数目
numsps = length(sps);                           % 获取每符号采样点种类数目                             
q=1;                                            % 循环计数
%%%%%%%%%%创建一个在x方向无限维的数据,块大小为[1 2 spf],使用9级压缩%%%%%%%%%%
data_name=["test_base_data"];                                             %数据集名称（需要设定）
file_name=["D:\data\"];                                                   %文件夹路径（需要设定）
new_folder=[file_name+data_name];                                         %文件绝对路径
mkdir(new_folder);                                                        %创建目标文件夹
filename=[new_folder+"\"+data_name+".h5"];                                %H5文件保存路径
%创建无限维H5文件
h5create(filename,'/X',[Inf 2 spf],'Datatype','single', ...
           'ChunkSize',[1 2 spf],'Deflate',9)
h5create(filename,'/Y',[Inf numModulationTypes],'Datatype','int8', ...
           'ChunkSize',[1 numModulationTypes],'Deflate',9)
h5create(filename,'/Z',[Inf],'Datatype','int8', ...
           'ChunkSize',[1],'Deflate',9)
%生成信道，包含莱斯多径衰落信道，时钟偏移，中心频率偏移，采样率偏移，高斯噪声因素
multipathChannel = comm.RicianChannel(...
  'SampleRate', fs, ...
  'PathDelays', [0 0.9 1.7] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 6);
% multipathChannel = comm.RicianChannel(...
%   'SampleRate', fs, ...
%   'PathDelays', [0 0.9 1.7] / fs, ...
%   'AveragePathGains', [0 10*log(0.8) 10*log(0.3)], ...
%   'KFactor', 4, ...
%   'MaximumDopplerShift', 1);
% 计算偏移因子C
clockOffset = (rand() * 2*maxOffset) - maxOffset;
C = 1 + clockOffset / 1e6;
% 计算采样率偏移
t = (0:(2*spf-1))' / fs;
newFs = fs * C;
tp = (0:(2*spf-1))' / newFs; 
transDelay = 50;
while q<=numFrames
    %随机调制方式
    modType=randi([1,numModulationTypes],1,1);
    %随机信噪比
    SNR=randi([first,last],1,1);
    %随机码元速率
    sps1=sps(randi([1,numsps],1,1));
    %随机载波频率
%     fc=70e6+(100e6-70e6)*rand(); 
    %随机化延迟和通道增益
    release(multipathChannel);
    delay1=0.1+(2.5-0.1)*rand();    
    delay2=2.5+(5-2.5)*rand();      
    gain1=randi([-5,-1],1,1);
    gain2=randi([-12,-6],1,1);
    multipathChannel.PathDelays=[0 delay1 delay2] / fs;
    multipathChannel.AveragePathGains=[0 gain1 gain2];
    %产生个数相同的数字符号
    dataSrc = get_Source(modulationTypes(modType), 4, 2*spf, fs);
    %产生调制器
    modulator = get_Modulator(modulationTypes(modType), sps1, fs);
    % 生成随机信号
    x = dataSrc();
    % 调制
    y = modulator(x);
    y=y(1:2*spf);
    %通过莱斯信道
    outMultipathChan = multipathChannel(y);
    %中心频率偏移
    outTimeDrift = interp1(t, outMultipathChan, tp);
    %加噪声
    rxSamples = awgn(outTimeDrift,SNR,0);
    % 归一化
    frame = normalize(rxSamples, spf, spf, transDelay, sps1);
    %提取IQ路并进行数据类型转换
    frame = frame';
    Idata=single(real(frame));
    Qdata=single(imag(frame));
    data=[Idata;Qdata];
    final=reshape(data,[1 2 spf]);
    %设置XYZ写入的起始位置和写入大小
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


