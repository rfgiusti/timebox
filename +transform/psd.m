function [trainp, testp] = psd(train, test, options)
%TRANSFORM.PSD   Estimate the power spectral density of time series.
%   Dp=PSD(D,...) treats the time series in D as discretized signals and
%   returns in Dp a data set that represents the original time series
%   transformed into power spectral density representation.
%
%   The semantics of D and Dp vary depending on whether a sampling rate is
%   specified. In either case, for time series of length L, the PSD is be
%   calculated from the n-point FFT of each time series considering N=L
%   observations, if L is even, and N=L+1 observations if L is odd. If
%   necessary, the series are padded with zeros.
%
%   The output Dp is be a matrix with size(D,1) rows and N/2+2 columns. The
%   first column of Dp contains the classes of the time series in D. The
%   remaining columns contain the power of the spectral bands.
%
%   For a single example D(i,:), the semantics of the output Dp(i,2:end)
%   will vary according to the two following cases.
%
%   1- when no sampling rate is specified, time series are treated as
%      signals sampled at Fs=2*pi. Each Dp(i,j+2) corresponds to the power
%      of the component at frequency 2*j*pi/N rad/sample. The power is
%      given in dB/rad/sample.
%
%   2- when a sampling rate Fs is specified, time series are treated as
%      signals of duration N/Fs seconds. Each Dp(i,j+2) corresponds to the
%      power of the component at frequency j*Fs/N Hz. The power is given in
%      dB/Hz.
%
%   Dp=PSD(D) finds the normalized-frequency PSD without specifying a
%   sampling rate.
%
%   Dp=PSD(D,O) where O is an OPTS object specifying the option "psd::fs"
%   finds the PSD in Hz considering the specified sampling rate.
%
%   In both cases, if the signal is undersampled, there will be aliasing.
%
%   [Dp,Tp]=PSD(D,T,...) treats T as a test data set and finds the PSD of
%   both the series in D and in T. It is equivalent to invoking this
%   function twice for D and T.
%
%   Example: the following example makes a synthetic data set with a single
%            time series from a sample WAVE file in "timebox/assets/wav".
%            This sample WAVE file contains one-second worth of an
%            artificially generated middle-C note. The PSD of this signal
%            should show a single peak at 261.6 Hz with a magnitude of -10
%            dB/Hz.
%
%       [y, Fs] = wavread('assets/wav/c4.wav');
%       ds = [1, y(:)'];
%       P = transform.psd(ds, opts.set('psd::fs', Fs));
%       p = P(2:end);
%       freq = 0:Fs/numel(y):Fs/2;
%       plot(freq, p);

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.0.1
   
switch nargin
    case 1
        Fs = 2 * pi;
        test = [];
    case 2
        if opts.isa(test)
            Fs = opts.get(test, 'psd::fs', 2 * pi);
            test = [];
        else
            Fs = 2 * pi;
        end
    case 3
        Fs = opts.get(options, 'psd::fs', 2 * pi);
end

trainp = do1(train, Fs);
if ~isempty(test)
    testp = do1(test, Fs);
end
end


function psd = do1(ds, Fs)
len = size(ds, 2) - 1;
N = len + mod(len, 2);
power = fft(ds(:, 2:end), [], 2);
power = (1/(Fs*N)) * abs(power(:, 1:N/2+1)).^2;
power(:, 2:end-1) = 2 * power(:, 2:end-1);
psd = [ds(:, 1), 10 * log10(power)];
end