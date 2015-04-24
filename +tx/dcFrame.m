function [ dc_frame ] = dcFrame( dataIn, tileAssigns, isVisual )
%DCPREAMBLE Generate AGC and syncronisation OFDM symbols for DC segment
%   First OFDM symbol is used for AGC, followed by five ODFM synchoronization
%   symbol opportunities and 2 data tiles for the 2 AS in the cell

if nargin < 3
    isVisual = false;
end

if nargin < 1
    dataIn = linspace(3,4,268); % dummy data for debugging
    isVisual = true;
end

% Allocate space for frame
dc_frame = zeros(12,64);

if length(dataIn) ~= 268
    error('Wrong number of data symbols!')
end

% AGC is not used in this implementation but lets include it in the frame
dc_frame(1,:) = tx.agcOfdmSymbol();

% Syncronisation sequences for DC frame
dc_frame(2:6,:) = tx.syncOfdmSymbols('dc');

% Data
dc_frame(7:12,:) = tx.dataOfdmSymbols( dataIn, tileAssigns, 0 );


% Visualize DC frame
if isVisual
    visualize( dc_frame );
end % endif

end % endfun

function [] = visualize( dc_frame )

    fig = +libs.fig( 'width', 14, 'height', 3, 'fontsize', 10 );
    imagesc( abs(dc_frame) );
    title('Structure of the DC Frame');
    grid on;
    
    hndl = gca;
    set(hndl,'XTick',0.5:64.5);
    set(hndl,'YTick',0.5:12.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');

end

