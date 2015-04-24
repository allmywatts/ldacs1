function [ l_tiles, r_tiles ] = deFramer( rx_fd_samples )
%DEFRAMER Summary of this function goes here
%   Detailed explanation goes here

% Allocate space for left and right tiles
l_tiles = zeros(480,25);
r_tiles = zeros(480,25);

% Remove AGC and Sync symbols from DC frame
% max 160 data tiles remain
rx_fd_samples = rx_fd_samples(7:end,:);

% remove zero padding from left and right;
rx_fd_samples = rx_fd_samples(:,8:58);

% remove dc carrier
rx_fd_samples = [ rx_fd_samples(:,1:25) rx_fd_samples(:,27:51) ];

l_tiles = rx_fd_samples(:,1:25);
r_tiles = rx_fd_samples(:,26:50);

end % endfun

