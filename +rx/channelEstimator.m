function [ channel_estimate, tile_data_pos ] = channelEstimator( rx_symbols )
%CHANNELESTIMATOR Estimate channel from pilot symbols and interpolate
%   Detailed explanation goes here
%   rx_symbols is a n_ofdm_symbols-by-64 matrix
%   Each row vector corresponds to FD samples of one OFDM symbol

n_tile_pairs = size(rx_symbols,1)/6;

% PAPR symbol positions
l_tile_papr_positions = (2:5) + 6;
r_tile_papr_positions = (2:5) + 6*22;

% Pilot symbol positions
l_tile_pilot_positions = [1 25:30:145 6 30:30:150];
r_tile_pilot_positions = [1:30:121 145 6:30:126 150];

% Pilot sequences
P_left  = [2, 40, 10, 2, 56, 4, 2, 40, 10, 2, 56, 4];
P_right = [4, 56, 2, 10, 40, 2, 4, 56, 2, 10, 40, 2];
S_left  = exp( 1i*2*pi/64 * P_left  );
S_right = exp( 1i*2*pi/64 * P_right );

S = [ S_left(1:6) S_right(1:6); S_left(7:12) S_right(7:12) ];

% Data symbol positions
idx = 1:150;
l_tile_data_positions = ...
    idx( ~ismember(idx, [l_tile_pilot_positions l_tile_papr_positions] ) );
r_tile_data_positions = ...
    idx( ~ismember(idx, [r_tile_pilot_positions r_tile_papr_positions] ) );

tile_data_pos = [ l_tile_data_positions; r_tile_data_positions ];

% LS channel estimation & linear interpolation
channel_estimate = zeros(n_tile_pairs*6,64);

for idx = 1:n_tile_pairs
        
    % Estimate channel for 6 ofdm symbols
    ofdm_symbols = rx_symbols( [1,6] + (idx-1)*6, : );
    % Spline Interpolation on grid
    channel_estimate([1:6] + (idx-1)*6, :) = interpolate( ofdm_symbols, S );
end

end

function [ chanEst ] = interpolate( ofdm_symbols, pilot_symbols )

pilot_positions = [ -25, -21, -16, -11, -6, -1, 1, 6, 11, 16, 21, 25 ] + 33;
pilotEst = ofdm_symbols(:,pilot_positions) ./ pilot_symbols;

xi = pilot_positions;
yi = [1 6];

[Xi, Yi] = meshgrid(xi,yi);
[Xj, Yj] = meshgrid((1:64),(1:6));

chanEst= interp2(Xi,Yi,pilotEst,Xj,Yj,'spline');


% Eliminate noise outside max. excess delay
h_est = ifft(fftshift(chanEst),[],2);
h_est(:,4:end) = 0;
chanEst = fftshift(fft(h_est,[],2));

% figure;mesh(abs(chanEst)); hold on;
% figure;plot(abs(chanEst(6,:))); hold on;
% stem(pilot_positions,abs(pilotEst(2,:)),'r');
% plot(abs(H2(12,:)),'m-.');

end

function [ chanEst ] = interpolate_f( ofdm_symbols, pilot_symbols )
%INTERPOLATE_F Interpolate in f direction
N = 64;

pilot_positions = [ -25, -21, -16, -11, -6, -1, 1, 6, 11, 16, 21, 25 ] + 33;
pilotEst = ofdm_symbols(:,pilot_positions) ./ pilot_symbols;

h_est = ifft(ifftshift(pilotEst),[],2);     % convert to TD
h_est = [h_est(:,1:6) zeros(2,N-size(h_est,2)) h_est(:,7:12)];   % zero padding -> FD interpolation

chanEst = fftshift(fft(h_est,[],2));
chanEst = circshift(chanEst,[0 2]); % this is necessary; why?


end

function [ chanEst ] = interpolate_t( chanEst_f)
%INTERPOLATE_T Interpolate in t direction

chanEst = zeros(6,64);
chanEst([1 6],:) = chanEst_f;

xi = (1:64);
yi = [1 6];
yj = (2:5);

[Xi, Yi] = meshgrid(xi,yi);
[Xj, Yj] = meshgrid(xi,yj);

chanEst(2:5,:) = interp2(Xi,Yi,chanEst_f,Xj,Yj,'spline');

end

