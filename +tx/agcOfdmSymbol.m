function [ agc_ofdm_symbol ] = agcOfdmSymbol( isVisual )
%AGCOFDMSYMBOL Construct OFDM symbol for AGC
%   Detailed explanation goes here

if nargin < 1
    isVisual = false;
elseif nargin > 1
    error('Too many input arguments');
end

if ~islogical(isVisual)
    error('Function input has to be a logical variable');
end

agc_ofdm_symbol = zeros(1,64);

% AGC is not used in this implementation but lets include it in the frame
% See D3 Section 4.3.5.4 AGC Preamble
P_AGC = [29 8 35 53 30 17 21 16 7 37 23 35 40 41 8 46 32 47 8 36 26 53 12 26 ... 
    33 4 31 42 0 6 48 18 60 24 2 15 16 58 48 37 61 22 38 52 23 3 63 36 49 42];

S_AGC = exp( 2*pi*i/64 *P_AGC );

agc_symbol_positions = [-25:-1 1:25] + 33;


agc_ofdm_symbol(agc_symbol_positions) = S_AGC; 

if isVisual
    visualize( agc_ofdm_symbol );
end

end

function [] = visualize( agc_ofdm_symbol )

    fig = +libs.fig( 'width', 14, 'height', 1, 'fontsize', 10 );
    imagesc( angle(agc_ofdm_symbol) );
    title('AGC OFDM symbol');
    grid on;
    
    hndl = gca;
    set(hndl,'XTick',0.5:64.5);
    set(hndl,'YTick',0.5:1.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');

end
