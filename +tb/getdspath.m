function dspath = getdspath
%TB.GETDSPATH Return the path where data sets should be looked for.
if exist('~/.timebox.dspath', 'file')
    f = fopen('~/.timebox.dspath', 'r');
    tb.assert(f ~= -1, 'Can''t open "~/.timebox.dspath" for reading');
    dspath = fscanf(f, '%s');
    fclose(f);
    tb.assert(exist(dspath, 'dir'), ['Configuration file "~/.timebox.dspath" points to a nonexistent path']);
    if dspath(end) ~= '/'
        dspath(end + 1) = '/';
    end
else
    dspath = '~/timeseries/';
end
end