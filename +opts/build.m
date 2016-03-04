function options = build(varargin)
%OPTS.BUILD     Create an OPTS object from one or more options
%   BUILD(key1,value1,key2,value2,...) constructs an OPTS object where each
%   key is associated to a value. This is similar to the following function
%   calls:
%
%       options = OPTS.EMPTY;
%       options = OPTS.SET(options, key1, value1);
%       options = OPTS.SET(options, key2, value2);
%       .
%       .
%       .
nargs = size(varargin, 2);
i = 1;

options = opts.empty;

prefix = '';

while i < nargs
    if ~ischar(varargin{i})
        err = MException('Argument %d is not char type', i);
        throw(err);
    end
    
    if regexp(varargin{i}, '^[a-zA-Z ]+::$')
        prefix = varargin{i};
        i = i + 1;
    else
        options = opts.set(options, [prefix varargin{i}], varargin{i + 1});
        i = i + 2;
    end
end
end

