% Doing assignment B.

[data, fT] = wavread('Q1_K2013_44814P.wav');
soundsc(data, fT);

%%
% find out the frequency bands of the signal.
% octave uses specgram.
figure(1); clf;
%specgram(data, 1024, fT, 512, 256);
spectrogram(data, 512, 256, 512, fT, 'yaxis');
colorbar;

display(sprintf('Sampling frequency: %d\n', fT));

print('q1_spectrogram.png', '-dpng');

passband_start = 5000;
passband_stop = 12500;
transition_band_width = 500;
Rp = 2;
Rs = 30; % 30 dB drop in stopband.

Ws1 = (passband_start - transition_band_width)/(fT/2);
Wp1 = passband_start/(fT/2);
Wp2 = passband_stop/(fT/2);
Ws2 = (passband_stop + transition_band_width)/(fT/2);

figure(2); clf;

speksitIIR([Wp1, Wp2], [Ws1, Ws2], Rp, Rs, '', fT);

% chebyshev type II IIR filter.

[filter_ord, Wc] = cheb2ord([Wp1, Wp2], [Ws1, Ws2], Rp, Rs);
display(sprintf('Implementing Chebyshev type II filter of order %d.\n', ...
               filter_ord));
[B, A] = cheby2(filter_ord, Rs, Wc);
[H, W] = freqz(B, A);

hold on;
aH = abs(H);
plot((W/pi)*(fT/2), 10*log(aH/max(aH)));

print('q1_filter_specification.png', '-dpng');

% XXX for some reason the filter specification seems to broken in the
% high end of the passband.  Why is this so?

filtered = filter(B, A, data);
figure(3); clf;
%specgram(filtered, 1024, fT, 512, 256);
spectrogram(filtered, 512, 256, 512, fT, 'yaxis');
colorbar;

print('q1_filtered_spectrogram.png', '-dpng');

%%
soundsc(filtered, fT);

%% demodulation.  Idea taken from Matlab round 5.

% frequency found by iterating a few times.
fc = 11195;
x_demod = filtered .* cos(2*pi*fc/fT*[1:length(filtered)]');
soundsc(x_demod, fT);

%% song lyrics.
flipped = flipud(x_demod);
soundsc(flipped, fT);

