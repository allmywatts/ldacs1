function [ txSignal ] = modulator( super_frame, IDFT )
%TXSIGNAL Produce continous time signal from SF
%   Detailed explanation goes here
%   Input super frame contains a total of 486 * 4 = 1944 ofdm symbols

N_CP = 11; % cyclic prefix length

txSignal = (IDFT * super_frame')';

% Add cyclic prefix

txSignal = [ txSignal(:,end-N_CP+1:end) txSignal ];


end

