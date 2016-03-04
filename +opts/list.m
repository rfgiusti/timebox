function x = list
%OPTS.LIST Call HELP OPTS.LIST to see the list of valid options accepted by
%TimeBox. This list is prone to being outdated and will be removed.
%   Some functions in TimeBox accept options. Instead of using variadic
%   arguments, though, TimeBox uses a containers.Map object. This approach
%   is taken because this makes the options easier to save into a .MAT
%   file, thus registering all options for some experiment, and also
%   because it's easier to make polymorphic functions.
%
%   Most options are in the form NAMESPACE::KEY, but some are not contained
%   in any namespace. Every option takes a single value, which is usually a
%   scalar, but may be some composite object.
%
%   Every function will document the options it accepts, as well as the
%   default values it assumes. The meaning of each option will be listed
%   here.
%
%   Assume all options are of boolean type unless context indicates
%   otherwise or a different type is explicitly stated.
%
%   Generic options for all packages:
%       epsilon             For comparing doubles. Two doubles s, r are
%                           different if abs(s - r) > epsilon
%
%   Options for time series an data sets:
%       None
%
%   Options for transformation/representation/features of time series
%       bmp::level          Level of detail for the time series bitmap
%                           representation
%       bmp::real bmp       Return data set composed of bitmap matrices
%                           instead of arrays of doubles. Note that TimeBox
%                           functions are not compatible with this format
%       bmp::use paa        ?
%       bmp::window width   ?
%       haar::approximated  Return only the approximation coefficients
%       haar::extend        If the series length is not in the form 2^n and
%                           harr::extend is true, interpolate the
%                           observations to the nearest larger power of two
%       haar::level         Level of detail for the Haar transform
%       haar::normalize     ?
%       paa::num segments   The number of intervals to aggregate the
%                           observations. When supplied, paa::segment size
%                           is estimated from the length of the series.
%                           This option overrides paa::segment size
%       paa::segment size   The size of the intervals to aggregate the
%                           observations. If paa::num segment is not
%                           supplied, it is estimated from the size of the
%                           intervals.
%       pca::cut            ?
%       pca::zero cols      ?
%       sax::cut function   Must be function handle. The function specified
%                           by this options returns an array of doubles
%                           that specifies percentiles for the distribution
%                           of the observations of time series
%       sax::alphabet size  The number of symbols to be used when encoding
%                           a series as a SAX string
%       sax::segmenting function    Must be a function handle. ?
%
%   Options for distance/similarity functions and functionalities:
%       dists::arg          If present, the value of this options will be
%                           supplied as a third argument to a distance
%                           function
%       dists::reflexive    Specifies if a distance function is reflexive
%       dists::similarity   If true, distance function is treated as a
%                           similarity function
%       dists::symmetric    Specifies if a distance function is symmetric
%
%   Options for classification models:
%       nn::tie break       A char. Valid values are 'first', 'random', and
%                           'none'. If there are several nearest neighbors
%                           at the same distance of the needle, this
%                           options specifies which should be chosen by the
%                           k-NN. 'first' and 'random' are intuitive.
%                           'none' causes the function to return an array
%                           for the indices of all nearest neighbors.
%                           Caution when handling this output: it might be
%                           an array or a scalar
%
%   Options for evaluation strategies/experiment execution:
%       runs::model         A function handle. Specifies the classification
%                           model to be invoked when testing a data set.
%                           Currently TimeBox works only with k-NN. A
%                           mechanism for classifiers that require the
%                           model to be training is not implemented as of
%                           yet
x = 'Try calling "help OPTS.LIST" from the Matlab shell';
end

