% Test channel

clear all;
close all;
t_stamp = 0;
n_test = 56;

rxTestSignal = zeros(56,77);

txTestSignal = [ ones(n_test,1) zeros(n_test,63) ];
txTestSignal = [ txTestSignal(:,54:end) txTestSignal ];

rxTestSignal(1:n_test/2,:)  = +channel.aptChannel( txTestSignal(1:end/2,:), 0, t_stamp, 'TDL' );
t_stamp = t_stamp + (28 * 75 * 1.6 * 10^-6);
rxTestSignal(n_test/2+1:n_test,:) = +channel.aptChannel( txTestSignal(end/2+1:end,:), 0, t_stamp, 'TDL' );

rxTestSignal = rxTestSignal(:,12:75);

% FFT
rxTestSignalFD = fft(rxTestSignal,[],2);
txTestSignalFD = fft(txTestSignal(:,12:end),[],2);

H2 = rxTestSignalFD ./ txTestSignalFD;

+libs.fig('width', 15, 'height', 8, 'fontsize', 10 );
mesh(abs((H2)));

zlim([0.01 10]);
set(gca,'ZScale','log');