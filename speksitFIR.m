function lines = speksitFIR(F, A, DEV, Fs)
% SPEKSITFIR piirtää aktiiviseen ikkunaan annetut speksit.
% SPEKSITFIR draws the specifications in the axis
%   lines = speksitFIR(F, A, DEV, Fs)
%
%   Soveltuu FIR-suunnittelun spekseille. 
%   Suotimen maksimi tulee olla skaalattuna 1:een.
%
%   Only for FIR filter specifications.
%   The maximum has to be scaled to 1.
%
%   The input variables F, A, DEV and Fs as explained
%   in "help firpmord".
%
%   F      .
%   A      .
%   DEV    .
%   Fs     Näytteenottotaajuus / Sampling frequency, default==2
%
%   lines  kahvat viivoihin / handles to line objects
%
% EXAMPLE: Lowpass
%
%   fT  = 8000        % Fs -- sampling frequency
%   fp  = 1500        % passband 0..1500
%   fs  = 2000        % stopband 2000..fT/2
%   A   = [1 0]       % amplitude values at band #1 and band #2
%   DEV = [0.01 0.1]  % +- deviations at band #1 and band #2
%   [n,fo,mo,w] = firpmord([fp fs], A, DEV, fT);
%   b           = firpm(n,fo,mo,w);
%   [H, wa]     = freqz(b, 1, 512, fT);
%   plot(wa, abs(H));
%   grid on;
%   xlabel('frequency (Hz)'); ylabel('|H(e^{j \omega})|');
%   lines       = speksitFIR([fp fs], A, DEV, fT);
%
%
% EXAMPLE: multiple cut-offs
%   Fs  = 10000;
%   F   = [1500 2000 3500 4000];
%   A   = [1        0      0.8];
%   DEV = [0.01    0.1    0.02];
%   [n,fo,mo,w] = firpmord(F, A, DEV, Fs);
%   b           = firpm(n,fo,mo,w);
%   [H, wa]     = freqz(b, 1, 512, Fs);
%   plot(wa, abs(H));
%   grid on; 
%   xlabel('frequency (Hz)'); ylabel('|H(e^{j \omega})|');
%   lines       = speksitFIR(F, A, DEV, Fs);
%      % specs not met --> read CAUTION in 'help firpmord' 
%       
% 
% See also: firpmord, firpm

% Jukka Parviainen, parvi@hut.fi, 7.4.2008 

% number of cut-offs NC
NC  = length(F);

% number of bands NB
%  NB = (NC+2)/2
NB  = (NC + 2)/2;

NA  = length(A);
ND  = length(DEV);

if (NA ~= ND)
  exit('Vectors A and DEV must be of equal length');
end;

if (NA ~= NB)
  exit('Length of F must be 2*length(A)-2');
end;


if ((size(F,2)) > (size(F,1)))
  F = F';
end;
if ((size(A,1)) > (size(A,2)))
  A = A';
end;
if ((size(DEV,1)) > (size(DEV,2)))
  DEV = DEV';
end;

% vectors needed for plotting
FC  = reshape([0; F; Fs/2], 2, NB);
ACY = repmat(A+DEV, 2, 1);
ACA = repmat(A-DEV, 2, 1);


hold on;
p1 = line(FC, ACY);
p2 = line(FC, ACA);
hold off;

set(p1, 'Color',[0 0 0],'LineWidth',2);
set(p2, 'Color',[0 0 0],'LineWidth',2);

lines = [p1 p2];

axis([0 Fs/2 0 1.2*max(A+DEV)]);

