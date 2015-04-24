function [ signalOut ] = aptChannel( signalIn, noise_power, t_stamp, type )
%APTCHANNEL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    type = 'TDL'; % default
end

if nargin < 3
    t_stamp = 0;
end

if nargin < 2;
    error('Not enough input arguments.');
end

N_ofdm_length = 75;
N_ofdm_symbols = size( signalIn, 1);

% Channel parameters
n_taps = 3;     % channel taps
N_0 = noise_power;
E0 = 1;             % Channel power
fd = 413;           % Max. Doppler frequency in Hz
Ts = 1.6 * 10^-6;   % Sampling time
tau_max = 3.2 * 10^-6; % Max excess delay, rounded to the nearest n*Ts 
Ns = N_ofdm_length * N_ofdm_symbols;  % Number of channel samples

% Rayleigh fading channel; jakesModel( Ts, fd, Ns, E0 );
fadingChan = jakesModel( Ts*N_ofdm_length, fd/2, N_ofdm_symbols, E0, t_stamp );

% Exponential PDP
P = exp( -(0:n_taps-1)*Ts/tau_max );
% normalize sum tap powers to 1
P = P / norm(P);

for idx = 1:N_ofdm_symbols
    
    idxChan = (1:N_ofdm_length) + 75*(idx-1);
    
    if strcmp(type,'TDL')
        % Assume same channel realization on each tap
        signalOut(idx,:) = conv( sqrt(P)*(fadingChan(idx)), signalIn(idx,:) );
    elseif strcmp(type,'Rayleigh')
        n_taps = 1;
        signalOut(idx,:) = conv( fadingChan(idx), signalIn(idx,:) );
    else % AWGN
        n_taps = 1;
        signalOut(idx,:) = signalIn(idx,:);
    end
    
    % add noise; prefactor sqrt(N_0/2/N_AS)
    signalOut(idx,:) = signalOut(idx,:) + sqrt(N_0/2/2) *...
                        ( randn(1,75+n_taps-1) + 1i*randn(1,75+n_taps-1) );
    
end % endfor

end % endfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ channel ] = jakesModel( Ts, fd, Ns, E0, t_stamp  )
%JAKESMODEL Generate Rayleigh fading channael with Jakes spectrum
%   Ts : sampling time in seconds
%   fd : Max. Doppler frequency in Hz
%   Ns : Number of samples

wd = 2*pi*fd;   % Max. Doppler frequency in rads
N0 = 16;
N = 2*(2*N0+1);

% Initial phases
phi_initial = 0;
phi_n = pi* (1:N0) / (N0+1);

% Angles of arrival
theta_n = 2*pi*(1:N0) / N0;
% Oscillator freqencies
wn = wd * cos( theta_n);

% Time vector
t = t_stamp + (0:Ns-1) * Ts;

h_I = 2 * ( cos(phi_n)* cos(wn.'*t) )  + ...
    sqrt(2) * cos( phi_initial) * cos( wd * t );
h_Q = 2 * ( sin(phi_n)* cos(wn.'*t) )  + ...
    sqrt(2) * sin( phi_initial) * cos( wd * t ); 

channel =  E0 / sqrt(2*N0+1) * ( h_I + 1i*h_Q );

end