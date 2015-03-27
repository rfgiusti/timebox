function [train_ps, test_ps] = ps(train, test, ~)
% PS Power spectrum of partitioned dataset
%
%   TRAIN_PS = ps(TRAIN) will convert the TRAIN dataset to the power
%   spectrum representation.
%
%   [TRAIN_PS, TEST_PS] = ps(TRAIN, TEST) will convert bothe the TRAIN and
%   the TEST dataset to the power spectrum representation.
%
%   In both cases, the power spectrum of a time series X is calculated as
%
%        X_PS = ABS(FFT(X));
%
%   Class values are expected in the first column of the dataset.
%
%   This function takes no optional arguments.
train_ps = [train(:, 1), abs(fft(train(:, 2:end), [], 2))];
if exist('test', 'var')
    test_ps = [test(:, 1), abs(fft(test(:, 2:end), [], 2))];
end