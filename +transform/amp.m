function [train, test] = amp(train, test, ~)
%TRANSFORM.AMP   Two-side amplitude spectrum
%   A=AMP(D) returns the two-side amplitude spectrum of the time series in D.
%
%   [At,As]=AMP(Dt,Ds) transforms both data sets Dt and Ds.
%
%   The two-side amplitude spectrum of a time series X is given by
%   ABS(FFT(X))
%
%   Class values are expected in the first column of the dataset.
%
%   This function takes no optional arguments.
%
%   Example:
%
%       % In timebox/assets/wav there is a WAVE file containing 1 second of
%       % the note "middle-C" (C4). The following example reads that file,
%       % makes an artificial data set containing a single example and uses
%       % TRANSFORM.AMP to generate an off-scale 1-sided amplitude
%       % spectrum. There will be a peak at approximately 261.6 Hz
%       [y, Fs] = wavread('assets/wav/c4.wav');
%       ds = [1, y(:)'];
%       Y = transform.amp(ds);
%       Y(1) = [];
%       Y = 10 * log10(Y(1:end/2 + 1));
%       freq = 0:Fs/numel(y):Fs/2;
%       plot(freq, Y);

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.1
train = [train(:, 1), abs(fft(train(:, 2:end), [], 2))];
if exist('test', 'var')
    test = [test(:, 1), abs(fft(test(:, 2:end), [], 2))];
end