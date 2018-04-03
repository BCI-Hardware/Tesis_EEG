close all
clear all
delete(instrfindall)
%s = serial('/dev/tty.wchusbserial1410','BaudRate',38400);
%s = serial('/dev/ttyUSB0','BaudRate',115200);

s = serial('COM6','BaudRate',115200); % S = serial('PORT','P1',V1,'P2',V2,...) constructs a serial port object associated with port, PORT,
                     % In order to communicate with the device, the object must be connected to the serial port with the FOPEN function.
flp=lowpass();
fhp=highpass();

b=[1.0, -2.0, 1.0];
a=[1.0, -1.9749029659, 0.9765156251];

fopen(s)
pause(6)
flushinput(s) %Remove data from input buffer.
flushoutput(s) %Remove data from output buffer.
pause(1)
fwrite(s,'1'); % fwrite Write binary data to file.
pause(1)
c1=[];c2=[];
c1=zeros(1,2000);
c2=zeros(1,2000);
scrsz = get(0,'ScreenSize');
figure('Position',[1 3*scrsz(4)/4 scrsz(3) 3*scrsz(4)/4]);hold on
while(1)
    c = fread(s,100); % A = fread(FID,SIZE) reads the number of elements specified 
    if(length(c)<100)
        length(c)
        break;
    end
    cint=c(1:2:end)+256*c(2:2:end);
    c1aux=cint(1:2:end)';
    c2aux=cint(2:2:end)';
    c1=[c1(26:end) c1aux];
    c2=[c2(26:end) c2aux];
    c1hp=filter(b,a,c1);
    c2hp=filter(b,a,c2);
    wo=50/(250/2);bw=wo/5;
    [bn,an]=iirnotch(wo,bw);
    c1filt=smooth(c1hp,5);%  filter(fhp,c1notch);
    c2filt=smooth(c2hp,5);%filter(fhp,c2notch);
%     c1filt=filter(fhp,c1filt);
%     c2filt=filter(fhp,c2filt);    
    subplot(2,1,1)
    plot(c1filt)
    ylim([-100 100])
    xlim([500 2000])
    subplot(2,1,2)
    plot(c2filt)
    ylim([-100 100])
    xlim([500 2000])
    pause(0.0001)
end
fclose(s)
delete(instrfindall)


