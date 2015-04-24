function [ multi_frame ] = multiFrame( dataIn, tileAssigns, isVisual )
%MULTIFRAME Summary of this function goes here
%   Detailed explanation goes here

% DC frame containing 2 PHY-PDUs (data tiles)
% Data frame containing 158 PHY-PDUs ( 79 pairs)
% In total, there are 79*6 (data) + 12 (dc) ofdm symbols in a multi-frame
% resulting in a transmit duration of 486* 0.12 ms = 58.32 ms

if nargin < 1
    [dataIn tileAssigns ] = generateData(10);
    dataIn = mapper(dataIn(:,1)); tileAssigns = tileAssigns(:,1);
    isVisual = true;
end

% Allocate space for multi-frame
n_tile_pairs = size(tileAssigns,1)/2;
multi_frame = zeros( (n_tile_pairs+1)*6,64);

multi_frame(1:12,:) = tx.dcFrame( dataIn(1:268), tileAssigns(1:2), 0 );
multi_frame(13:end,:) = tx.dataFrame( dataIn(269:end), tileAssigns(3:end), 0 );

if isVisual 
    visualize( multi_frame );
end % endif

end % endfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = visualize( multi_frame )
 
    fig = +libs.fig('width', 14, 'height', 10, 'fontsize', 10 );
    
    imagesc( abs(multi_frame) );
    hold on;
    grid on;
    
    hndl = gca;
    title('Structure of the Multi-Frame');
    
    set(hndl,'XTick',[0.5 64.5]);
    set(hndl,'YTick',0.5:6:size(multi_frame,1)+0.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');
    
end