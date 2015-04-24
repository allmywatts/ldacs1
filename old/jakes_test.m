function  [] =  jakes_test() 
% plot_Jakes_model.m
clear all, close all
% Parameters
fd=926; Ts=1e-5; % Doppler frequency and Sampling time
M=2^12; t=[0:M-1]*Ts; f=[-M/2:M/2-1]/(M*Ts*fd);
Ns=50000; t_state=0;
% Channel generation
[h,t_state]=Jakes_Flat(fd,Ts,Ns,t_state,1,0);
subplot(311), plot([1:Ns]*Ts,10*log10(abs(h))),
title(['Jakes Model, f_d=',num2str(fd),'Hz, T_s=',num2str(Ts),'s']);
axis([0 0.05 -20 10]), xlabel('time[s]'), ylabel('Magnitude[dB]')
subplot(323), hist(abs(h),50);
title(['Jakes Model, f_d=',num2str(fd),'Hz, T_s=',num2str(Ts),'s']);
xlabel('Magnitude'), ylabel('Occasions')
subplot(324), hist(angle(h),50);
title(['Jakes Model, f_d=',num2str(fd),'Hz, T_s=',num2str(Ts),'s']);
xlabel('Phase[rad]'), ylabel('Occasions')
% Autocorrelation of channel
temp=zeros(2,Ns);
for i=1:Ns
j=i:Ns;
temp1(1:2,j-i+1)=temp(1:2,j-i+1)+[h(i)'*h(j); ones(1,Ns-i+1)];
end
for k=1:M
Simulated_corr(k)=real(temp(1,k))/temp(2,k);
end
Classical_corr=besselj(0,2*pi*fd*t);
% Fourier transform of autocorrelation
Classical_Y=fftshift(fft(Classical_corr));
Simulated_Y=fftshift(fft(Simulated_corr));
subplot(325), hold on;
plot(t,abs(Classical_corr),'b-.',t,abs(Simulated_corr),'r')
title(['Autocorrelation, f_d=',num2str(fd),'Hz'])
grid on, xlabel('delay \tau [s]'), ylabel('Correlation')
legend('Classical','Simulation')
subplot(326)
hold on;
plot(f,abs(Classical_Y),'b-.')
plot(f,abs(Simulated_Y),'r')
title(['Doppler Spectrum,f_d=',num2str(fd),'Hz'])
axis([-1 1 0 600]), xlabel('f/f_d'), ylabel('Magnitude')
legend('Classical','Simulation')


end


function [h,tf]=Jakes_Flat(fd,Ts,Ns,t0,E0,phi_N)
% Inputs:
% fd,Ts,Ns : Doppler frequency, sampling time, number of samples
% t0, E0 : initial time, channel power
% phi_N : inital phase of the maximum Doppler frequency sinusoid

% Outputs:
% h, tf : complex fading vector, current time
if nargin<6,
phi_N=0;
end

if nargin<5,
E0=1;
end

if nargin<4,
t0=0;
end

N0 = 8;
% As suggested by Jakes
N = 4*N0+2;
% an accurate approximation
wd = 2*pi*fd;
% Maximum Doppler frequency[rad]
t = t0+[0:Ns-1]*Ts; tf = t(end)+Ts; % Time vector and Final time
coswt=[sqrt(2)*cos(wd*t); 2*cos(wd*cos(2*pi/N*[1:N0]')*t)]; % Eq.(2.26)
h = E0/sqrt(2*N0+1)*exp(j*[phi_N pi/(N0+1)*[1:N0]])*coswt; % Eq.(2.23)


end