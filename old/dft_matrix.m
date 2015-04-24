function [DFT, IDFT] = dft_matrix(N_FFT, plot_flag)
%DFT_MATRIX Summary of this function goes here
%   Detailed explanation goes here
%   Create N_FFT point DFT and IDFT matrices

if nargin < 2
    plot_flag = 0;
end

if nargin < 1
    N_FFT = 64;
    plot_flag = 1;
end

if mod(N_FFT,2) ~= 0
    error('Odd number of DFT points')
end

k = 0:N_FFT-1;

[tmp_1,tmp_2]=ndgrid(k,k);
M = (tmp_1*tmp_2)/ N_FFT;


DFT     = sqrt(50)/sqrt(N_FFT) .* exp( -2*pi*i/ N_FFT * M );
IDFT    = sqrt(50)/sqrt(N_FFT) .* exp(  2*pi*i/ N_FFT * M );

if plot_flag
    
    fig = +libs.fig('width', 14, 'height', 10, 'fontsize', 10 )
    
    imagesc(abs(DFT))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis square
    
    res = 1;
    tmp = mod(M(1:res:end,1:res:end),N_FFT);
    textStrings = num2str(tmp(:),'%d');  %# Create strings from the matrix values
    textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
    
    [x,y] = meshgrid(1:res:N_FFT);   %# Create x and y coordinates for the strings
    hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
        'HorizontalAlignment','center');
end

end