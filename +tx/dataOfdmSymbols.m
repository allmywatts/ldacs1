function [ ofdm_data_symbols ] = dataOfdmSymbols( dataIn, tileAssigns, isVisual )
%DATAOFDMSYMBOLS Summary of this function goes here
%   Detailed explanation goes here

% For BER measurements, DC and DATA frames contain maximum amount of data 
% So data can be processes in chunks of 268 symbols for left and right data
% tiles to construct 7 ofdm symbols at a time

if nargin < 3
    isVisual = false;
end

if nargin < 1
    dataIn = linspace(-4,-2,268);
    tileAssigns = [1 0; 1 0];
    isVisual = true;
end

if length(dataIn) ~= 268
    error('Wrong number of input symbols; has to be 268');
end


% Allocate space for tiles
l_tile  = zeros(6,25);   % left tiles
r_tile  = zeros(6,25);   % right tiles

% PAPR symbol positions

l_tile_papr_positions = (2:5) + 6;
r_tile_papr_positions = (2:5) + 6*22;

% Pilot symbols are mapped in frequency direction
% Positions given as linear indices

% { 1, 25, 55, 85, 115, 145, 6, 30, 60, 90, 120, 150}
l_tile_pilot_positions = [1 25:30:145 6 30:30:150];

% { 1, 31, 61, 91, 121, 145, 6, 36, 66, 96, 126, 150 }
r_tile_pilot_positions = [1:30:121 145 6:30:126 150]; 
                           
% Calculate pilot sequences

P_left  = [2, 40, 10, 2, 56, 4, 2, 40, 10, 2, 56, 4];
P_right = [4, 56, 2, 10, 40, 2, 4, 56, 2, 10, 40, 2];

S_left  = exp( 1i*2*pi/64 * P_left  );
S_right = exp( 1i*2*pi/64 * P_right );

l_tile( l_tile_pilot_positions ) = S_left;
r_tile( r_tile_pilot_positions ) = S_right;

% Data symbols are mapped in time direction, so use linear indexing
idx = 1:150;

% Remove pilot and PAPR symbol positions from the indexes
l_tile_data_positions = ...
    idx( ~ismember(idx, [l_tile_pilot_positions l_tile_papr_positions] ) );
r_tile_data_positions = ...
    idx( ~ismember(idx, [r_tile_pilot_positions r_tile_papr_positions] ) );

% Map data to tiles, PAPR symbols not known yet\
% Last minute hack to fix a bug in construction of data tiles
% We want to leave them empty instead of filling with (0000) symbols
if tileAssigns(1)
l_tile( l_tile_data_positions ) = dataIn(1:134);
end

if tileAssigns(2)
r_tile( r_tile_data_positions ) = dataIn(135:268);
end

% Calculate PAPR symbols for the tiles
papr_symbols = calc_papr_symbol( l_tile, r_tile );

% Map PAPR symbols to tiles
l_tile( l_tile_papr_positions )   = papr_symbols(:,1);
r_tile( r_tile_papr_positions )   = papr_symbols(:,2);

% Actually leave tiles empty if AS is not assigned the tile
if ~tileAssigns(1)
    l_tile = zeros(6,25);
end

if ~tileAssigns(2)
    r_tile = zeros(6,25);
end

% Construct OFDM data symbols
ofdm_data_symbols = [ zeros(6,7) l_tile zeros(6,1) r_tile zeros(6,6) ];

if isVisual
    visualize( l_tile, r_tile, ofdm_data_symbols )
end % endif

end % endfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ papr_symbol ] = calc_papr_symbol( l_tile, r_tile )

papr_symbol_set = [1,1i,-1,-1i];
[tmp_1, tmp_2] = meshgrid(papr_symbol_set,papr_symbol_set);
% 4x4 = 16 possible combinations of PAPR symbols for 1 OFDM symbol
papr_symbol_combinations = [tmp_1(:) tmp_2(:)];

% need OFDM symbols n = {2,3,4,5}
l_tile = l_tile(2:5,:);
r_tile = r_tile(2:5,:);

% 4 ofdm_symbols without PAPR symbols
ofdm_symbol = [ zeros(4,7) l_tile zeros(4,1) r_tile zeros(4,6) ];
papr_symbol = zeros(4,2);
for idx = 1:4 % maybe vectorize it later
    current_symbol = ofdm_symbol(idx,:);
    current_symbol_combinations = repmat(current_symbol,16,1);
    current_symbol_combinations(:,9) = papr_symbol_combinations(:,1);
    current_symbol_combinations(:,56) = papr_symbol_combinations(:,2);
    
    % IFFT
    time_symbols = ifft( current_symbol_combinations,[],2);
    % Pick the combination that minimizes PAPR
    symbol_square_norm = time_symbols .* conj( time_symbols );
    
    papr_num = max( symbol_square_norm ,[],2);  %numerator term
    papr_den = sum( symbol_square_norm,2) /64;  %denominator term
    ofdm_papr = papr_num ./ papr_den;
    [~,combination_index] = min(ofdm_papr);
    
    papr_symbol(idx,:) = papr_symbol_combinations(combination_index,:);
    
end % endfor

end % endfun

function [] = visualize( l_tile, r_tile, ofdm_data_symbols )
    

    +libs.fig( 'width', 14, 'height', 2, 'fontsize', 10 );
    
    subplot(1,2,1);
    imagesc( angle(l_tile) );
    grid on;
    hndl(1) = gca;
    title('Left Tile Structure');
    
    subplot(1,2,2);
    imagesc( angle(r_tile) );
    grid on;
    hndl(2) = gca;
    title('Right Tile Structure');
    
    set(hndl,'XTick',0.5:25.5);
    set(hndl,'YTick',0.5:6.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');
    
    +libs.fig( 'width', 14, 'height', 2, 'fontsize', 10 );
    ofdm_visual = abs(ofdm_data_symbols) .* ...
        ( 2*(ofdm_data_symbols >= -1) - (ofdm_data_symbols < -1));
    imagesc( ofdm_visual );
    title('Structure of OFDM data symbols');
    grid on;
    hndl = gca;
    set(hndl,'XTick',0.5:64.5);
    set(hndl,'YTick',0.5:6.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');
    
end % endfun