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

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.0
train = [train(:, 1), abs(fft(train(:, 2:end), [], 2))];
if exist('test', 'var')
    test = [test(:, 1), abs(fft(test(:, 2:end), [], 2))];
end