function [ super_frame ] = superFrame( dataIn, tileAssigns, IDFT, isVisual )
%SUPERFRAME Summary of this function goes here
%   Detailed explanation goes here

N_SYMS_PER_MF = 21440;

idx_1 = 1: N_SYMS_PER_MF;
idx_2 = (1+N_SYMS_PER_MF):(2*N_SYMS_PER_MF);
idx_3 = (1+2*N_SYMS_PER_MF): (3*N_SYMS_PER_MF);
idx_4 = (1+3*N_SYMS_PER_MF):(4*N_SYMS_PER_MF);

super_frame = [ ...
    tx.multiFrame( dataIn( idx_1 ), tileAssigns(1:160), IDFT, 0 ); ...
    tx.multiFrame( dataIn( idx_2 ), tileAssigns(161:320), IDFT, 0 ); ...
    tx.multiFrame( dataIn( idx_3 ), tileAssigns(321:480), IDFT, 0 ); ...
    tx.multiFrame( dataIn( idx_4 ), tileAssigns(481:640), IDFT, 0 ) ];

if isVisual % but not all of it
    visualize( super_frame(1:48,:) );
end % endif

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = visualize( super_frame )
 
    fig = +libs.fig('width', 14, 'height', 10, 'fontsize', 10 );
    
    imagesc( abs(super_frame) );
    hold on;
    grid on;
    
    hndl = gca;
    title('Structure of the Super-Frame');
    
    set(hndl,'XTick',[0.5 64.5]);
    set(hndl,'YTick',0.5:6:size(super_frame,1)+0.5);
    set(hndl,'XTicklabel',[]);
    set(hndl,'YTicklabel',[]);
    set(hndl,'GridLineStyle','-');
    
end