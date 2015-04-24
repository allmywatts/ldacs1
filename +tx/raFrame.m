function [ RA_opportunity_1, RA_opportunity_2, offsets ] = raFrame( isVisual )
%FRAME Generate RA frame
%   Detailed explanation goes here

% See D3 4.3.2.3 Framing Specifics for Prototype AS TX Implementation

% RA Frame
% 1 RA subframe has 134 data symbols
% 2 RA subframes are transmitted in RA frame, 134*2 total data symbols

if nargin < 1
    isVisual = true;
end

% Random data to fill data tiles
data = generateData(2);
syms(:,1) = mapper( data(1:end/2,1) );
syms(:,2) = mapper( data(end/2+1:end,2) );

% Allocate space for RA subframes
ra_subframe_1 = zeros(7,64);
ra_subframe_2 = zeros(7,64);

% Construct AGC OFDM symbols for RA Subframe 1 & 2
ra_subframe_1(1,:) = tx.agcOfdmSymbol();
ra_subframe_2(1,:) = tx.agcOfdmSymbol();

% Syncronisation sequences
ra_subframe_1(2:3,:) = tx.syncOfdmSymbols('ra');
ra_subframe_2(2:3,:) = tx.syncOfdmSymbols('ra');

% Pilot Sequences
P_RA = [58, 48, 53, 1, 60, 34, 13, 56, 15, 39, 41, 16, 3, 59, 25, 49, 60, ...
    49, 6, 33, 6, 11, 58, 48, 53, 1, 60, 34, 13, 56, 15, 39, 41, 16];
S_RA = exp(1i*2*pi/64* P_RA );

%  Pilot positions
n_47 = [-21, -17, -13, -9, -5, -1, 1, 5, 9, 13, 17, 21] + 33;
n_5 = [-17, -9, 9, 17] + 33;
n_6 = [-21, -13, -5, 5, 13, 21] + 33;
tmp = zeros(4,64);
tmp([1 4],n_47) = 1; tmp(2,n_5) = 1; tmp(3,n_6) = 1;
pilot_positions = find(tmp == 1);
dc_positions = (1+32*4):(4+32*4);
data_positions = (11*4+1:54*4) .* ...
    ~ismember( (11*4+1:54*4),[pilot_positions; dc_positions']);
data_positions = data_positions( data_positions > 0 );

% Assign pilot symbols
tmp(pilot_positions) = S_RA;

% Assign RA subframe 1 data
tmp(data_positions) = syms(:,1);
ra_subframe_1(4:7,:) = tmp;
% Assign RA subframe 2 data
tmp(data_positions) = syms(:,2);
ra_subframe_2(4:7,:) = tmp;

% RA Opportunity 1 & 2

offsets = randi([0 21],1,2);

%RA_opportunity_1 = ra_subframe_1;
%RA_opportunity_2 = ra_subframe_2;

RA_opportunity_1 = [ zeros(offsets(1),64); ra_subframe_1; zeros(21-offsets(1),64)];
RA_opportunity_2 = [ zeros(offsets(2),64); ra_subframe_2; zeros(21-offsets(2),64)];

if isVisual
    visualize(ra_subframe_1,ra_subframe_2);
end % endif
    
end % endfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = visualize( ra_subframe_1,ra_subframe_2 )

    +libs.fig( 'width', 14 ,'height' ,3.5 , 'fontsize', 10 );
    imagesc( angle(ra_subframe_1) );
    title('RA subframe 1 (Angle)');
    grid on;
    hndl(1) = gca;
    
    +libs.fig( 'width', 14 ,'height' ,3.5 , 'fontsize', 10 );
    imagesc( abs(ra_subframe_2) );
    title('RA subframe 2 (Magnitude)');
    grid on;
    hndl(2) = gca;
    
    set(hndl,'XTick',0.5:64.5);
    set(hndl,'YTick',0.5:7.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');

end
