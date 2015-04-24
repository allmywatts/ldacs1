function [ dataOut, symsQuantized ] = mapper( dataIn, task )
%MAPPER Map/DeMap bits/symbols to symbols/bits
%   When mapping a binary stream to 16QAM symbols, the fuction accepts
%   a vector binary numbers. The length of the vector needs to be a 
%   multiple of 4 to map bits to symbols exactly. The fuction returns
%   a column vector of complex symbols of length(binaryStream)/4
%   The average symbol energy of the 16QAM constellation is normalized to 1
%
%   When demapping complex symbols, the fuction accepts a vector of complex
%   symbols which are mapped to the nearest 16QAM symbols. 
%   The function returns a bistream 4 times the length of the vector.
%

% Check function arguments
if nargin < 1
    error('Not enough input arguments!');
elseif nargin < 2
    task = 'Map'; % default task
end

% decimal index to symbol conversion array
bit2sym = [1,3,-1,-3];

% Choose task ( Map / DeMap )
switch task
    % Mapper
    case 'Map'
        % Check bitstream length is correct for modulation order
        if mod(length(dataIn),4) ~= 0
            error('Bitstream length should be a multiple of 4 for 16QAM!');
        end
        
        % reshape input binary stream into 4-tuples
        bi4tuples = reshape(dataIn,4,[]).';  
        
        % Seperate Q and I parts
        IStream = bi4tuples(:,1:2); % b3b2 for I-component
        QStream = bi4tuples(:,3:4); % b1b0 for Q-component
        
        % convert binary 2-tuples to decimal numbers
        decIStream = bi2de(IStream,'left-msb');    
        decQStream = bi2de(QStream,'left-msb');    
        
        % Map I and Q parts
        symIStream = bit2sym(decIStream+1);
        symQStream = bit2sym(decQStream+1);
        
        % Complex 16QAM symbols
        dataOut = symIStream.' + 1i*symQStream.';
        % Normalized output symbols
        dataOut = 1/sqrt(10) * dataOut;
        
    % Demapper
    case 'DeMap'
        % Input is a row vector of complex symbols of size
        % N_ofdm_symbol * N_symbols_per_tile

        % 16 QAM symbols
        [I,Q] = meshgrid(bit2sym,bit2sym);
        symbols16qam =  1/sqrt(10) * ( I(:) + 1i*Q(:) );
        
        % Binary 4 tuples, in the same order as 16 QAM symbols
        tmp = [0 0; 0 1; 1 0; 1 1];
        qam2bin = [kron(tmp,[1;1;1;1]) repmat(tmp,4,1) ];
        
        % # of symbols to be demapped
        len = length(dataIn);
        
        % construct matrix of symbols to comapre to
        comparison_symbols = repmat(symbols16qam.',len,1);
        
        % Distances to constellation points
        diff = repmat( dataIn,1,16) - comparison_symbols;
        diff_mag = diff .* conj(diff);
        
        % Indices of nearest constellation points
        [~, idx_16qam ] = min(diff_mag,[],2);
        bi4tuples = qam2bin( idx_16qam,:);
        symsQuantized = symbols16qam( idx_16qam,: );
        
        % Reshape binary 4-tuples into a stream
        dataOut = reshape(bi4tuples',[],1);
        
    % Wrong task argument
    otherwise
        error('Invalid task!');
        
end % endswitch

end % endfun
