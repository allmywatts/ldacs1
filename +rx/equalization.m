function [ symbols, eqData ] = ...
    equalization( channel_estimate, data, tile_data_pos )
%EQUALIZATION Perform 1-tap equalization
%   Equalize received data by dividing them with the channel estimate
%   Extract the complex symbols from tiles and stack them in a matrix

l_tile_data_pos = tile_data_pos(1,:); 
r_tile_data_pos = tile_data_pos(2,:);

n_tile_pairs = size(data,1)/6;

% Remove zero padding and DC subcarrier
data = [data(:,8:32) data(:,34:58) ]  ;
channel_estimate = [channel_estimate(:,8:32) channel_estimate(:,34:58)];

% 1-tap equalization ( X = Y/H )
eqData = data ./ channel_estimate;

% Allocate space
symbols = zeros(2*n_tile_pairs,134);

% Extract data from tiles
% process left and right tiles in pairs
for idx = 1:n_tile_pairs 
    
    % left tile
    current_tile = eqData( (1:6) + (idx-1)*6,1:25);
    symbols_l_tile =  current_tile( l_tile_data_pos );
    
    % right tile
    current_tile = eqData( (1:6) + (idx-1)*6,26:50);
    symbols_r_tile = current_tile( r_tile_data_pos );
    
    symbols( 2*idx-1:2*idx, : ) = [ symbols_l_tile; symbols_r_tile ];
    
end % endfor


end % endfun

