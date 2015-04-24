%
%   ODFM Seminar Project 2013/2014
%   L-DACS1 PHY Layer RL Implementation
%   Tuna Tandogan
%

clc
clear
close all

% Parameters
EbN0dB = [0:10:50];
EsN0dB = EbN0dB - 10*log10(4) + 10*log10(50/64);
N_0 = 10.^( -EsN0dB / 10); % noise power
t_stamp = 0; % time stamp for Jakes' model

BER_FLAT = []; BER_AWGN = []; BER_TDL = [];
for ii= 1:length(N_0) 
    BER_TDL(ii) = ldacs1( N_0(ii), 'TDL', t_stamp );
    %BER_FLAT(ii) = ldacs1( N_0(ii), 'Rayleigh', t_stamp );
    BER_AWGN(ii) = ldacs1( N_0(ii), 'AWGN', t_stamp );
end


+libs.fig('width', 15, 'height', 15, 'fontsize', 10 );
semilogy(EbN0dB,[BER_TDL; BER_FLAT; BER_AWGN]')
legend('TDL','Rayleigh','AWGN');
xlabel('x1') % for psfrag
ylabel('x2')
