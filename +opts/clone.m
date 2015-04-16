function out = clone(in)
%OPTS.CLONE     Create a new object that is a copy of the input object.
%Warning: if the options object contains other objects, both the input
%and the output will reference the same object.
tb.assert(opts.isa(in), 'Input argument must be an options set object.');
out = opts.empty;
keys = in.keys;
for i = 1:numel(keys)
    out(keys{i}) = in(keys{i});
end
end
