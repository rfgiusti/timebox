function options = build(varargin)
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

