function [trainps, testps] = ps(train, test, ~)
%TRANSFORM.PS Power spectrum of partitioned data set
%  TRAINPS = PS(TRAIN) will convert the TRAIN data set to the power
%  spectrum representation.
%
%  [TRAINPS,TESTPS] = PS(TRAIN, TEST) will convert bothe the TRAIN and the
%  TEST data set to the power spectrum representation.
%
%  In both cases, the power spectrum of a time series X is calculated as
%
%        XPS = ABS(FFT(X));
%
%   This function takes no optional arguments.
trainps = [train(:, 1), abs(fft(train(:, 2:end), [], 2))];
if exist('test', 'var')
    testps = [test(:, 1), abs(fft(test(:, 2:end), [], 2))];
end