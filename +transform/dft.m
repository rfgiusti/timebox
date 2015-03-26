function [traindft, testdft] = dft(train, test, ~)
%TRANSFORM.DFT Discrete Fourier Transform on partitioned data set.
%
%   TRAINDFT = DFT(TRAIN) will convert the TRAIN data set to Fourier
%   coefficients using the Fast Fourier Transform.
%
%   [TRAINDFT,TESTDFT] = DFT(TRAIN, TEST) will convert both the TRAIN and
%   the TEST data sets to Fourier coefficiente using the Fast Fourier
%   Transform.
%
%   In both cases, coefficients are calculated as
%
%        XDFT = FFT(X);
%
%   This function takes no optional arguments.
%
%   The output will be in the complex domain.
traindft = [train(:, 1), fft(train(:, 2:end), [], 2)];
if exist('test', 'var')
    testdft = [test(:, 1), fft(test(:, 2:end), [], 2)];
end