function [train, test] = unif(~, arg2, arg3)
%This function is a stub and has not been implemented yet.
warnobsolete('transform:sax:unif')
if exist('arg3', 'var')
    option = arg3;
elseif exist('arg2', 'var') && opts.isa(arg2)
    option = arg2;
    clear arg2;
else
    option = opts.empty();
end
has_test = exist('arg2', 'var');


alpha_size = opts.get(option, 'sax::alphabet size', 4);

throw(MException('MethErr:NotImplemented', 'reps.sax_unif - not implemented'));

train = cutp;
if has_test
    test = cutp;
end
end

