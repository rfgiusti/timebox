function [traindft, testdft] = dft(train, test, ~)
%TRANSFORM.DFT Discrete Fourier Transform on partitioned dataset
%   DSDFT = DFT(DS) returns the Fourier coefficients for the dat set using
%   the Fast Fourier Transform.
%
%   [TRAINDFT, TESTDFT] = DFT(TRAIN, TEST) applies the DFT transform to
%   both training and test data set.
%
%   In both cases, Fourier coefficients are calculated as
%
%        F = FFT(X);
%
%   Notice that each Fourier coefficient is a complex number that encodes
%   magnitude and phase of a Fourier component.
%
%   This function takes no options
traindft = [train(:, 1), fft(train(:, 2:end), [], 2)];
if exist('test', 'var')
    testdft = [test(:, 1), fft(test(:, 2:end), [], 2)];
end

