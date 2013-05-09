% Doing assignment B.

[data, fT] = wavread('Q1_K2013_44814P.wav');
% find out the frequency bands of the signal.
% octave uses specgram.
figure(1); clf;
specgram(data, 1024, fT, 512, 256);
colorbar;

printf("Sampling frequency: %d\n", fT);

print('q1_spectrogram.pdf', '-dpdf');
