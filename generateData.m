function [ binaryStreams, tileAssignments ] = generateData( n_tiles )
%GENERATEDATA Randomly generate binary streams for AS1 and AS2
%   Detailed explanation goes here

% Data tiles in RA subframes are not considered since they are not used
% for BER measurement
% As a result, there are 2 (DC) + 158 (Data) = 160 data tiles in multiframe
% 640 tiles in a super frame
% There are 134 data symbols per tile

% For two AS, tile 1 of DC frame will be assigned to AS1 and tile 2 will
% be assigned to AS2

if nargin < 1
    n_tiles = 160;
end

N_DATA_SYMBOLS_IN_TILE = 134;
BI2SYM = 4;

if n_tiles < 2
    error('Need at least 2 data tiles');
end

% if n_tiles > 160
%     error(['Can not generate data for more than 1 MF; '...
%         'number of tiles has to be less than or equal to 160']); 
% end % endif

% Allocate space for AS binary streams,
binaryStreams = zeros( BI2SYM * N_DATA_SYMBOLS_IN_TILE * n_tiles, 2 );

% Randomly assign tiles to AS1 and AS2

[ tiles_as1, tiles_as2 ] = assignTiles( n_tiles );

% Generate data to fill the assigned tiles

binary_data_as1 = randi([0 1], BI2SYM * N_DATA_SYMBOLS_IN_TILE * sum(tiles_as1), 1);
binary_data_as2 = randi([0 1], BI2SYM * N_DATA_SYMBOLS_IN_TILE * sum(tiles_as2), 1);

% Assign data to correct positions in the stream
% 1 tile corresponds to 536 bits

TILE_SKIP_LENGTH = 536;
TILE_TO_BIT = ones( TILE_SKIP_LENGTH, 1);

isBitUsedAs1 = kron( tiles_as1, TILE_TO_BIT );
isBitUsedAs2 = kron( tiles_as2, TILE_TO_BIT );

idxUsedBitAs1 = (1:BI2SYM * N_DATA_SYMBOLS_IN_TILE * n_tiles).' .* isBitUsedAs1;
idxUsedBitAs2 = (1:BI2SYM * N_DATA_SYMBOLS_IN_TILE * n_tiles).' .* isBitUsedAs2;

% remove 0s
idxUsedBitAs1 = idxUsedBitAs1( find( idxUsedBitAs1 ) );
idxUsedBitAs2 = idxUsedBitAs2( find( idxUsedBitAs2 ) );

binaryStreams( idxUsedBitAs1, 1) = binary_data_as1;
binaryStreams( idxUsedBitAs2, 2) = binary_data_as2;

tileAssignments = [ tiles_as1 tiles_as2 ];

end % endfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ isAssignedAs1, isAssignedAs2 ] = assignTiles ( n_tiles )
%ASSIGNTILES Assign tiles to AS1 and AS2
%   This function assigns tiles to AS1 and AS2 while making sure to 
%   data tile 1 of a DC frame at the beginning of a MF is always assigned
%   to AS 1, and similarly tile 2 is always assigned to AS 2

isAssignedAs1 = [];
isAssignedAs2 = [];

% How many MF are required for the data tiles
number_of_mf = ceil( n_tiles / 160 );
current_mf = 0;

while number_of_mf > 0
    
    current_mf = current_mf + 1;
    
    if number_of_mf > 1
        tiles_in_mf = 160;
    else
        tiles_in_mf = n_tiles - (current_mf-1) * 160;
    end % endif
    
    % only tiles in the Data frame are randomly assigned
    randAssign = randi([0 1],1,tiles_in_mf-2);
    isAssignedAs1 = [ isAssignedAs1 1 0  randAssign ];
    isAssignedAs2 = [ isAssignedAs2 0 1 ~randAssign ];
    
    number_of_mf = number_of_mf - 1;

end % endwhile

    % Return column vectors
    isAssignedAs1 = isAssignedAs1';
    isAssignedAs2 = isAssignedAs2';

end % endfun