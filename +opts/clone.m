function out = clone(in)
%OPTS.CLONE     Attempt to clone an OPTS object. This function will FAIL
%if the original OPTS object contains references: the resulting clone will
%reference the same objects as the original.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
tb.assert(opts.isa(in), 'Input argument must be an options set object.');
out = opts.empty;
keys = in.keys;
for i = 1:numel(keys)
    out(keys{i}) = in(keys{i});
end
end
