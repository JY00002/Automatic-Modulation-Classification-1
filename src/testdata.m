clc;clear;
testdatax=h5read('D:\data\data12\data12.h5','/X');
testdatay=h5read('D:\data\data12\data12.h5','/Y');
testdataz=h5read('D:\data\data12\data12.h5','/Z');
spf=128;
index=1;
Idata=reshape(testdatax(index,1,:),[1 spf]);
Idata=Idata';
Qdata=reshape(testdatax(index,2,:),[1 spf]);
Qdata=Qdata';
mydata=Idata+Qdata*i;
testdatay(index,:)
testdataz(index)
figure();
subplot(221);
plot(mydata);
subplot(222);
plot(abs(fftshift(fft(mydata))),'g');
subplot(223);
plot(Idata,'b');
subplot(224);
plot(Qdata,'r');