# **Automatic-Modulation-Classification**

## 使用matlab生成数据集

参考https://ww2.mathworks.cn/help/comm/examples/modulation-classification-with-deep-learning.html

1. 仿真方式

MATLAB（版本2019b以上）

2. 调制种类

28种，数字调制（25种）: "BPSK", "QPSK", "8PSK","16PSK","32PSK",."OQPSK" ,"DBPSK", "DQPSK"，"D8PSK"，"16QAM", "32QAM","64QAM","128QAM","256QAM" "PAM4","PAM8" ,"2ASK","4ASK"，"16APSK"，"32APSK"，"GFSK", "2FSK", "4FSK" ,"MSK","GMSK",；模拟调制（3种）："B-FM", "DSB-AM", "SSB-AM"

3. 信号产生步骤

![img](file:///C:/Users/XuQiang/AppData/Local/Temp/msohtmlclip1/01/clip_image002.png)

（1）生成M进制随机序列（dataSrc函数）

首先设置单个帧的采样点长度spf（默认为1024）和单个符号采样点sps（默认为8），得到每一帧的符号数symbolsPerFrame = spf / sps（默认为128），调用dataSrc函数生成symbolsPerFrame长度的M进制随机序列，此时输出为实数。

（2）基带调制（modulator函数）

对symbolsPerFrame长度的M进制随机序列根据相应的调制方式进行基带映射，产生symbolsPerFrame长度的复数序列syms，再进行滤波成型（rcosdesign函数），滚降系数设置为0.35，这里其实包含两个步骤

① 上采样

首先对复数序列syms进行sps倍的上采样，其本质就是在每个符号后插入sps-1个0，输出为长度=symbolsPerFrame*sps的复数序列

② 成型滤波

将上采样后的复数序列通过低通滤波器，限制带宽，输出仍为长度=symbolsPerFrame*sps的复数序列

（3）过信道

信道主要由莱斯多径信道，中心频率偏移，采样率偏移，高斯白噪声组成。

① 莱斯多径信道

假设延迟分布为[0 1.8 3.4]样本，平均路径增益为[0 -2 -10]dB。k因子为4，最大多普勒频移为4hz，相当于902 MHz时的行走速度。

② 计算时钟偏移

时钟偏移是由于收发机的内部时钟不同而造成的，会导致载频和采样率的偏移，其中 是时钟漂移，它是按照百万分之一来计量的，它的范围是 ，通过MaximumClockOffset设定，这里引入一个时钟偏移因子C。

③ 载频偏移

根据时钟偏移因子C进行载频偏移，使用comm.PhaseFrequencyOffset实现。

④ 采样率偏移

根据时钟偏移因子C进行采样率偏移，使用 进行重采样

⑤ 高斯噪声

使用awgn加上噪声

（4）归一化数据

4. 可调参数

- 每次需要产生的的调制样式（可包含多类）
- 每种调制方式在每种信噪比下的样本个数：任意
- 每个符号的采样点（只能2的幂）：2，4，8……
- 单个样本长度
- 脉冲成型滤波器类型（模拟信号无）：默认是升余弦滤波器
- 脉冲成型滤波器滚降系数（模拟信号为调制系数）
- 载波频率（MHz）：只对中心频率偏移产生影响，将频偏=载波频率✖偏移系数
- 采样率（MHz）
- 信噪比（dB）
- 信道参数：如多径的延迟，增益，最大多普勒频移，偏移系数

5. 信道考虑因素

莱斯多径，中心频率偏移，采样率偏移，高斯白噪声

6. 文件打包存储格式

数据集格式为.h5，数据X类型为float32,独热码Y类型为int8，信噪比Z类型为int8，组成方式为XYZ三个group

7. 读取方式

import h5py   

import numpy as np

filename = 'dataset.hdf5'

f = h5py.File(filename , 'r')

X_data = f['X']

Y_data = f['Y']

Z_data = f['Z']

