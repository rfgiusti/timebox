function value = get(set, name, default)
%OPTS.GET   Return a value associated with a key in the OPTS object, or a
%default value if no key exists.
%   OPTS.GET(options,k) returns the value associated with they key "k" in
%   the OPTS object "options". If the key is not present in the OPTS
%   object, returns zero.
%
%   OPTS.GET(options,K,default) does the same, but returns "default" if the
%   key is not present in the OPTS object.
if ~exist('default', 'var')
    default = 0;
end

if isequal(class(set), 'containers.Map') && set.isKey(name)
    value = set(name);
else
    value = default;
end
end