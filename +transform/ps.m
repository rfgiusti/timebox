function [train_ps, test_ps] = ps(train, test, ~)
%TRANSFORM.PS Power spectrum of partitioned dataset
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
%
%   This function has been deprecated since TimeBox 0.12 and will be
%   removed in a future release.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.2.0
warnobsolete('transform:ps');

train_ps = [train(:, 1), abs(fft(train(:, 2:end), [], 2))];
if exist('test', 'var')
    test_ps = [test(:, 1), abs(fft(test(:, 2:end), [], 2))];
end