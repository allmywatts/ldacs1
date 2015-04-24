function [ sync_ofdm_symbols ] = syncOfdmSymbols( frame_type, isVisual )
%SYNCOFDMSYMBOLS Summary of this function goes here
%   Detailed explanation goes here

% Syncronisation sequences for DC  and RA frames
% See D3 Section 4.3.5.3.1 Synchronisation Symbols for AS TX Spectrum Measurements
% and Section 4.3.5.3.2 Synchronisation Symbols for BER measurements

if nargin < 2
    isVisual = false;
end

if nargin < 1 % for easy testing, can run function from editor window
    if  exist('inputdlg') == 2
        frame_type = inputdlg('Choose frame type (ra,dc or dc_ber)');
    else % if inputdlg is not available on host pc, set frame_type manually
        frame_type = ra;
    end
    isVisual = true;
end

N_SY = [12 24]; 

sync_ofdm_symbols = zeros(2,64);

% -24, -20, -16, -12, -8, -4, 4, 8, 12, 16, 20, 24
sync_symbol_positions_1 = [-24:4:-4 4:4:24] + 33;
% -24, -22, -20, -18, -16, -14, -12, -10, -8, -6, -4, -2 
% 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24
sync_symbol_positions_2 = [ -24:2:-2 2:2:24 ] + 33;

% Calculate sync. symbols
S_sy_1 = sqrt(4) * exp( i*pi * [0:N_SY(1)-1] / N_SY(1) );
S_sy_2 = sqrt(2) * exp( i*pi * [0:N_SY(2)-1] / N_SY(2) );

% Place sync. symbols
sync_ofdm_symbols( 1,sync_symbol_positions_1 ) = S_sy_1;
sync_ofdm_symbols( 2,sync_symbol_positions_2 ) = S_sy_2;
    
if strcmp(frame_type,'ra')
    % do nothing
    
elseif strcmp(frame_type,'dc')
    % Replicate 2nd OFDM sync. symbol 5 times
    sync_ofdm_symbols = repmat( sync_ofdm_symbols(2,:), 5, 1 );
    
elseif strcmp(frame_type,'dc_ber')
    % Leave first 3 sync. symbols empty
    % Syncronisation symbols only in 4th and 5th opportunity?
    sync_ofdm_symbols = [ zeros(3,64) ; sync_ofdm_symbols] ;

else
    % matlab doesn't make it easy to put single quotes (') into a string
    error(['Wrong frame type; use ''','ra''', ' or ''','dc''', ...
        ' or ''', 'dc_ber''', '!']);

end % endif

if isVisual
    visualize( sync_ofdm_symbols, frame_type );
end % endif

end % endfun

function [] = visualize( sync_ofdm_symbols, frame_type )

    fig_height = size( sync_ofdm_symbols,1);
    fig = +libs.fig( 'width', 14, 'height', fig_height, 'fontsize', 10 );
    imagesc( abs(sync_ofdm_symbols) );
    title('Synchronisation OFDM symbols');
    grid on;
    
    hndl = gca;
    set(hndl,'XTick',0.5:64.5);
    set(hndl,'YTick',0.5:fig_height+0.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');

end