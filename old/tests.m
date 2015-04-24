% Tests

close all;

figure;
imagesc(abs(ofdm_symbols_AS1(1:48,:)));

figure;
imagesc(abs(ofdm_symbols_AS2(1:48,:)));

figure;
imagesc(abs(ofdm_symbols_AS1(1:12,:) + ofdm_symbols_AS2(1:12,:)) );

figure;
imagesc(abs(rx_symbols(1:12,:)));

figure;
hold on;
plot(real(tx_signal_AS1(1,:)));
plot(real(tx_signal_AS2(1,:)),'g:');
plot(real(tx_signal_AS1(1,:) + tx_signal_AS2(1,:) ) ,'b-');
plot(real(rxSignal(1,:)),'r:');

figure;
subplot 121
imagesc(abs(equalized_data([1:6],:)))
subplot 122
imagesc(abs(equalized_data([7:12],:)))

figure;
idx = (1:6);
idx = kron(idx,[1:2:29])
mesh( abs([chanEst(idx,:) chanEst(idx+6,:)]) )
set(gca,'ZScale','log');


% Constellations
tmp = [0 0; 0 1; 1 0; 1 1];
qam2bin = [kron(tmp,[1;1;1;1]) repmat(tmp,4,1) ];
qam2bin = reshape(qam2bin',[],1);
qam16 = mapper(qam2bin);
+libs.fig('width', 8, 'height', 8, 'fontsize', 10 );
hold on;
idx = (1:750);
scatter(real(symStream(idx)),imag(symStream(idx)),'r');
scatter(real(qam16),imag(qam16),'b','filled');
axis([-1.5 1.5 -1.5 1.5]);
set(gca,'XTick',-1:1);
set(gca,'YTick',-1:1);

xlabel('x2');
ylabel('x3');
%scatter(real(tx_symbols_AS1(idx)),imag(tx_symbols_AS1(idx)),'b')
%scatter(real(tx_symbols_AS2(idx)),imag(tx_symbols_AS2(idx)),'g')

% Channel estimate
figure;
mesh(abs(chanEst(1:500,:)));
xlim([1 64]);
figure;
mesh(abs(H2(7:506,:)));
xlim([1 64]);

