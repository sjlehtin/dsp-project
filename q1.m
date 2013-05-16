% Jarno Alanko <jarno.alanko@aalto.fi>
% Jani Kettunen <tsiki@cc.hut.fi>
% Sami J. Lehtinen <sjl@iki.fi>

% Doing assignment B.

[data, fT] = wavread('Q1_K2013_44814P.wav');
%%
soundsc(data, fT);

%%
% find out the frequency bands of the signal.
% octave uses specgram.
figure(1); clf;
%specgram(data, 1024, fT, 512, 256);
spectrogram(data, 512, 256, 512, fT, 'yaxis');
colorbar;
title('Original sample')

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

xlabel('frequency in Hz');
ylabel('magnitude');
hold on;
aH = abs(H);
plot((W/pi)*(fT/2), 20*log10(aH/max(aH)));

print('q1_iir_filter_specification.png', '-dpng');

%%
filtered = filter(B, A, data);
figure(3); clf;
%specgram(filtered, 1024, fT, 512, 256);
spectrogram(filtered, 512, 256, 512, fT, 'yaxis');
colorbar;
title('Filtered sample')

print('q1_filtered_spectrogram.png', '-dpng');

%%
soundsc(filtered, fT);

%% demodulation.  Idea taken from Matlab round 5.

% frequency found by iterating a few times.
fc = 11195;
x_demod = filtered .* cos(2*pi*fc/fT*[1:length(filtered)]');

figure(4); clf;
spectrogram(x_demod, 512, 256, 512, fT, 'yaxis');
colorbar;
title('Demodulated sample')

print('q1_demodulated_spectrogram.png', '-dpng');

%%
soundsc(x_demod, fT);
%%

fir_passband_end = 15000;
fir_stopband_start = 15500;
pass_ripple = 0.01;
stop_ripple = 0.1;

figure(5); clf;

speksitFIR([fir_passband_end, ...
    fir_stopband_start], [1 0], [pass_ripple stop_ripple], fT);

[lowpass_order, fo, mo, w] = firpmord([fir_passband_end, ...
    fir_stopband_start], [1 0], [pass_ripple stop_ripple], fT);
low_B = firpm(lowpass_order, fo, mo, w);

[H, W] = freqz(low_B, 1);
xlabel('frequency in Hz');
ylabel('magnitude');
hold on;
aH = abs(H);
plot((W/pi)*(fT/2), aH/max(aH));

print('q1_fir_filter_specification.png', '-dpng');

display(sprintf('Implementing Parks-McClellan FIR filter of order %d.\n', ...
		lowpass_order));

demod_filtered = filter(low_B, 1, x_demod);

figure(6); clf;
spectrogram(demod_filtered, 512, 256, 512, fT, 'yaxis');
colorbar;
title('Demodulated sample after applying lowpass filter')

print('q1_demodulated_filtered_spectrogram.png', '-dpng');

%%
soundsc(demod_filtered, fT);

%% song lyrics.
flipped = flipud(demod_filtered);
soundsc(flipped, fT);
