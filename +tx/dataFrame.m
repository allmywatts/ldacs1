function [ ofdm_data_symbols ] = dataFrame ( dataIn, tileAssigns, isVisual )
%TILE Generate data left and right tiles in pairs for OFDM frames
%   Detailed explanation goes here

% See D3 4.3.2.3 Framing Specifics for Prototype AS TX Implementation
%
% In case of BER measurements at the GS RX, AS TX shall send test data in 
% all Data segments of all RL MFs. Since the size of the DC segment is
% minimal, the size of the Data segment becomes maximal for BER measurements
% and contains 158 RL Data PHY-PDUs.

if nargin < 3
    isVisual = false;
end

if nargin < 1
    dataIn = randi([2 3],268*5,2);
    tileAssigns = ones(5,2);
    isVisual = true;
end

% 1 tile contains 134 ofdm symbols
% 158 tiles for BER measurement; data length of 158*134 = 21172 symbols
if mod(length(dataIn),268) ~= 0
    error('Wrong number of data symbols; has to be an even integer multiple of 268');
end

% How many tiles are needed to transmit data?
N_PHY_PDU_PAIRS = length(dataIn) / 268;

ofdm_data_symbols = zeros(6*N_PHY_PDU_PAIRS,64);

for i=1:N_PHY_PDU_PAIRS
    idx_phy_pdu = (1:6) + (i-1)*6;
    idx_data_symbols = (1:268) + (i-1)*268;
    ofdm_data_symbols( idx_phy_pdu, : ) = ...
        tx.dataOfdmSymbols( dataIn( idx_data_symbols ), tileAssigns(2*i-1:2*i), 0 );

end % endfor

if isVisual
    visualize( ofdm_data_symbols );
end % endif

end % endfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = visualize( ofdm_data_symbols )
 
    fig = +libs.fig( 'width', 14, 'height', 10, 'fontsize', 10 )
    
    imagesc( abs(ofdm_data_symbols) );
    hold on;
    grid on;
    
    hndl = gca;
    title('Structure of OFDM Data Frame');
    
    set(hndl,'XTick',[0.5 64.5]);
    set(hndl,'YTick',0.5:6:size(ofdm_data_symbols,1)+0.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');
    
end