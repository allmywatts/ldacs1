function [ rx_fd_samples ] = demodulator( rx_td_samples, DFT )
%DEMODULATOR Summary of this function goes here
%   Detailed explanation goes here

% Remove cyclic prefix & last 2 samples which belong to the next symbol
rx_td_samples = rx_td_samples(:,12:end-2);

% Perform DFT
rx_fd_samples = (DFT * rx_td_samples')';

end

