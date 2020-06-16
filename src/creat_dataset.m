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
numFramesPerModType = 1;                       % 每种调制方式在每种信噪比下的样本个数(可设置)
sps = 8;                                        % 每个符号的采样点（可设置，会影响码率）
spf = 128;                                      % 单个样本长度-帧长度（可设置）
fs = 200e3;                                     % 采样率（可设置）
fc = 902e6;                                     % 中心频率（可设置）
first=-20;                                      % 起始信噪比（可设置）                   
last=20;                                        % 截止信噪比（可设置）
foot=1;                                         % 信噪比跨度（可设置）
mode=1;                                         % 0原始信号，1AWGN，2莱斯+AWGN，3莱斯+CFO+AWGN，4莱斯+CFO+SFO+AWGN
numModulationTypes = length(modulationTypes);   % 获取信号种类数目
snr_num=(last-first)/foot+1;                    % 信噪比总数
SNR=30;
symbolsPerFrame = spf / sps;                    % 每一帧的符号数
q=1;                                            % 循环计数
%%%%%%%%%%创建一个在x方向无限维的数据,块大小为[1 2 spf],使用9级压缩%%%%%%%%%%
data_name=["data146"];                                                     %数据集名称（需要设定）
file_name=["D:\data\"];                                                   %文件夹路径（需要设定）
new_folder=[file_name+data_name];                                         %文件绝对路径
mkdir(new_folder);                                                        %创建目标文件夹
val_file=[new_folder+"\"+data_name+"_para.txt"];                          %相关参数保存路径
filename=[new_folder+"\"+data_name+".h5"];                                %H5文件保存路径
fid=fopen(val_file,"w");
%将相关参数写入txt文件
fprintf(fid,"%s%d%s","信号类型（共",numModulationTypes,"种）= ");
for i=1:numModulationTypes
    fprintf(fid,"%s ",modulationTypes(i));
end
fprintf(fid,"\n%s%d\n","每种调制方式在每种信噪比下的样本个数 = ",numFramesPerModType);
fprintf(fid,"%s%d\n","每个符号的采样点数目 = ",sps);
fprintf(fid,"%s%d\n","单个样本长度（帧长度） = ",spf);
fprintf(fid,"%s%s\n","信噪比范围  = ",num2str(linspace(first,last,snr_num)));
fprintf(fid,"%s%d\n","采样率  = ",fs);
fprintf(fid,"%s%s\n","中心频率  = ",num2str(fc));
fclose(fid);
%创建无限维H5文件
h5create(filename,'/X',[Inf 2 spf],'Datatype','single', ...
           'ChunkSize',[1 2 spf],'Deflate',9)
h5create(filename,'/Y',[Inf numModulationTypes],'Datatype','int8', ...
           'ChunkSize',[1 numModulationTypes],'Deflate',9)
h5create(filename,'/Z',[Inf],'Datatype','int8', ...
           'ChunkSize',[1],'Deflate',9)
%生成信道，包含莱斯多径衰落信道，时钟偏移，中心频率偏移，采样率偏移，高斯噪声因素
channel = helperModClassTestChannel (...
  'SampleRate', fs, ...
  'SNR', SNR, ...
  'PathDelays', [0 1.8 3.4] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4, ...
  'MaximumClockOffset', 5, ...
  'CenterFrequency', 902e6);
%保存当前时间
tic; 
transDelay = 50;
for modType = 1:numModulationTypes
    %输出当前信号生成的信息,包括时间，产生的帧
    fprintf('%s - Generating %s frames\n', ...
      datestr(toc/86400,'HH:MM:SS'), modulationTypes(modType))
    %信号标签
    label = modulationTypes(modType);
    %产生个数相同的数字符号
    dataSrc = get_Source(modulationTypes(modType), sps, 2*spf, fs);
    %产生调制器
    modulator = get_Modulator(modulationTypes(modType), sps, fs);
    for snr=int8(linspace(first,last,snr_num))
        channel.SNR=snr;
    %开始产生信号
        for p=1:numFramesPerModType
          % 生成随机信号
          x = dataSrc();
          % 调制
          y = modulator(x);
          % 通过信道    
          rxSamples = channel(y);
          % 归一化
          frame = normalize(rxSamples, spf, spf, transDelay, sps);
          %提取IQ路并进行数据类型转换
          frame = frame';
          Idata=real(frame);
          Qdata=imag(frame);
          Idata=single(Idata);
          Qdata=single(Qdata);
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
          h5write(filename,'/X',final,startx,countx);
          h5write(filename,'/Y',hotcode,starty,county);
          h5write(filename,'/Z',snr,startz,countz);
          q=q+1;
        end
    end
end


