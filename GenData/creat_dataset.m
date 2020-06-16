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
numFramesPerModType = 1;                       % ÿ�ֵ��Ʒ�ʽ��ÿ��������µ���������(������)
sps = 8;                                        % ÿ�����ŵĲ����㣨�����ã���Ӱ�����ʣ�
spf = 128;                                      % ������������-֡���ȣ������ã�
fs = 200e3;                                     % �����ʣ������ã�
fc = 902e6;                                     % ����Ƶ�ʣ������ã�
first=-20;                                      % ��ʼ����ȣ������ã�                   
last=20;                                        % ��ֹ����ȣ������ã�
foot=1;                                         % ����ȿ�ȣ������ã�
mode=1;                                         % 0ԭʼ�źţ�1AWGN��2��˹+AWGN��3��˹+CFO+AWGN��4��˹+CFO+SFO+AWGN
numModulationTypes = length(modulationTypes);   % ��ȡ�ź�������Ŀ
snr_num=(last-first)/foot+1;                    % ���������
SNR=30;
symbolsPerFrame = spf / sps;                    % ÿһ֡�ķ�����
q=1;                                            % ѭ������
%%%%%%%%%%����һ����x��������ά������,���СΪ[1 2 spf],ʹ��9��ѹ��%%%%%%%%%%
data_name=["data146"];                                                     %���ݼ����ƣ���Ҫ�趨��
file_name=["D:\data\"];                                                   %�ļ���·������Ҫ�趨��
new_folder=[file_name+data_name];                                         %�ļ�����·��
mkdir(new_folder);                                                        %����Ŀ���ļ���
val_file=[new_folder+"\"+data_name+"_para.txt"];                          %��ز�������·��
filename=[new_folder+"\"+data_name+".h5"];                                %H5�ļ�����·��
fid=fopen(val_file,"w");
%����ز���д��txt�ļ�
fprintf(fid,"%s%d%s","�ź����ͣ���",numModulationTypes,"�֣�= ");
for i=1:numModulationTypes
    fprintf(fid,"%s ",modulationTypes(i));
end
fprintf(fid,"\n%s%d\n","ÿ�ֵ��Ʒ�ʽ��ÿ��������µ��������� = ",numFramesPerModType);
fprintf(fid,"%s%d\n","ÿ�����ŵĲ�������Ŀ = ",sps);
fprintf(fid,"%s%d\n","�����������ȣ�֡���ȣ� = ",spf);
fprintf(fid,"%s%s\n","����ȷ�Χ  = ",num2str(linspace(first,last,snr_num)));
fprintf(fid,"%s%d\n","������  = ",fs);
fprintf(fid,"%s%s\n","����Ƶ��  = ",num2str(fc));
fclose(fid);
%��������άH5�ļ�
h5create(filename,'/X',[Inf 2 spf],'Datatype','single', ...
           'ChunkSize',[1 2 spf],'Deflate',9)
h5create(filename,'/Y',[Inf numModulationTypes],'Datatype','int8', ...
           'ChunkSize',[1 numModulationTypes],'Deflate',9)
h5create(filename,'/Z',[Inf],'Datatype','int8', ...
           'ChunkSize',[1],'Deflate',9)
%�����ŵ���������˹�ྶ˥���ŵ���ʱ��ƫ�ƣ�����Ƶ��ƫ�ƣ�������ƫ�ƣ���˹��������
channel = helperModClassTestChannel (...
  'SampleRate', fs, ...
  'SNR', SNR, ...
  'PathDelays', [0 1.8 3.4] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4, ...
  'MaximumClockOffset', 5, ...
  'CenterFrequency', 902e6);
%���浱ǰʱ��
tic; 
transDelay = 50;
for modType = 1:numModulationTypes
    %�����ǰ�ź����ɵ���Ϣ,����ʱ�䣬������֡
    fprintf('%s - Generating %s frames\n', ...
      datestr(toc/86400,'HH:MM:SS'), modulationTypes(modType))
    %�źű�ǩ
    label = modulationTypes(modType);
    %����������ͬ�����ַ���
    dataSrc = get_Source(modulationTypes(modType), sps, 2*spf, fs);
    %����������
    modulator = get_Modulator(modulationTypes(modType), sps, fs);
    for snr=int8(linspace(first,last,snr_num))
        channel.SNR=snr;
    %��ʼ�����ź�
        for p=1:numFramesPerModType
          % ��������ź�
          x = dataSrc();
          % ����
          y = modulator(x);
          % ͨ���ŵ�    
          rxSamples = channel(y);
          % ��һ��
          frame = normalize(rxSamples, spf, spf, transDelay, sps);
          %��ȡIQ·��������������ת��
          frame = frame';
          Idata=real(frame);
          Qdata=imag(frame);
          Idata=single(Idata);
          Qdata=single(Qdata);
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
          h5write(filename,'/X',final,startx,countx);
          h5write(filename,'/Y',hotcode,starty,county);
          h5write(filename,'/Z',snr,startz,countz);
          q=q+1;
        end
    end
end


