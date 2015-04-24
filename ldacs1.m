function [ BER ] = ldacs1( N_0, channel_type, t_stamp )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RA Frame
[ra_opportunity_AS1, ra_opportunity_AS2, offsets] = tx.raFrame( false );

% Modulate AS 1 and AS 2 transmit signals
tx_ra_AS1 =  64/sqrt(50)* ifft( ra_opportunity_AS1,[],2 );
tx_ra_AS2 =  64/sqrt(50)* ifft( ra_opportunity_AS2,[],2 );

% Cyclic prefix
tx_ra_AS1 = [ tx_ra_AS1(:,54:64) tx_ra_AS1 ];
tx_ra_AS2 = [ tx_ra_AS2(:,54:64) tx_ra_AS2 ];


for ii = 1:3 % 3 attempts to syncronize, then give up

    %Transmit RA opportunities
    % AS 1
    rx_ra_AS1 = channel.aptChannel( tx_ra_AS1, N_0, t_stamp, channel_type );
    % Advance time stamp by the duration of 1 RA opportunity
    t_stamp = t_stamp + (28 * 75 * 1.6 * 10^-6);
    % AS 2
    rx_ra_AS2 = channel.aptChannel( tx_ra_AS2, N_0, t_stamp, channel_type );
    % Advance time stamp by the duration of 1 RA opporunity
    t_stamp = t_stamp + (28 * 75 * 1.6 * 10^-6);
    
    % Search for sync sequences
    isSynchronized(1) = rx.schmidlcox( rx_ra_AS1, offsets(1) );
    isSynchronized(2) = rx.schmidlcox( rx_ra_AS2, offsets(2) );
    
    if (isSynchronized(1) && isSynchronized(2))
        break;
    else
        t_stamp = t_stamp + (2000 * 75 * 1.6 * 10^-6); % try again at next SF
    end

end % endif


% continue anyway?
% if ~(isSynchronized(1) && isSynchronized(2))
%    BER = NaN
%    return
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue with transmission if synchronization was succesfull
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BER = 0;
Bits = 0;

for ii = 1:4 % 4 MFs

% Generate binary data for the mapper, enough for 1 MF
[ dataBiIn, tileAssigns ] = generateData( 160 );

% Map binary data to 16QAM symbols
tx_symbols_AS1 = mapper( dataBiIn(:,1) );
tx_symbols_AS2 = mapper( dataBiIn(:,2) );

% Generate ofdm symbols in super frame structure from 16 QAM symbols
ofdm_symbols_AS1 = tx.multiFrame( tx_symbols_AS1, tileAssigns(:,1), 0);
ofdm_symbols_AS2 = tx.multiFrame( tx_symbols_AS2, tileAssigns(:,2), 0);

% Modulate AS 1 and AS 2 transmit signals
tx_signal_AS1 =  64/sqrt(50)* ifft(ofdm_symbols_AS1,[],2);
tx_signal_AS2 =  64/sqrt(50)* ifft(ofdm_symbols_AS2,[],2);

% Add cyclic prefix
tx_signal_AS1 = [ tx_signal_AS1(:, 54:64) tx_signal_AS1 ];
tx_signal_AS2 = [ tx_signal_AS2(:, 54:64) tx_signal_AS2 ];

% RX signal is a superposition of TX AS 1 and TX AS 2 signals
rxSignal =  channel.aptChannel( tx_signal_AS1, N_0, t_stamp, channel_type ) + ...
            channel.aptChannel( tx_signal_AS2, N_0, t_stamp, channel_type );
% Advance time stamp by the duration of 1 MF
t_stamp = t_stamp + (486 * 75 * 1.6 * 10^-6);
        
% Discard cyclic prefix
rxSignal = rxSignal(:,12:75);

% Demodulate the received signal
rx_symbols = sqrt(50)/64 * fft(rxSignal,[],2);

% Remove DC frame AGC and sync symbols
rx_data_symbols = rx_symbols(7:end,:);

% Estimate channel from pilot symbols and interpolate inbetween
[ chanEst, tile_data_pos ] = rx.channelEstimator( rx_data_symbols );

% Equalization
[symbols_in_tiles, equalized_data] = rx.equalization( chanEst, rx_data_symbols, tile_data_pos );

% Reshape symbols_in_tiles into a vector
symStream = reshape(symbols_in_tiles.',[],1);
[dataBiOut, symsQuantized] = mapper( symStream, 'DeMap');


% BER computation
Bit_errors = sum( dataBiOut ~= sum(dataBiIn,2) );
Bits = Bits + size(dataBiOut,1);

end % endfor

BER = Bit_errors / Bits;

end % endfun
