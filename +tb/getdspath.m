function dspath = getdspath
%TB.GETDSPATH Return the path where data sets should be looked for.
%   Currently works only for *NIX systems.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
if exist('~/.timebox.dspath', 'file')
    f = fopen('~/.timebox.dspath', 'r');
    tb.assert(f ~= -1, 'Can''t open "~/.timebox.dspath" for reading');
    dspath = fscanf(f, '%s');
    fclose(f);
    tb.assert(~isempty(dspath) && dspath(1) == '/', ['Path to repository should be specified in full *NIX format ' ...
        '(starting with /)']);
    tb.assert(exist(dspath, 'dir'), 'Configuration file "~/.timebox.dspath" points to a nonexistent path');
    if dspath(end) ~= '/'
        dspath(end + 1) = '/';
    end
else
    homedir = char(java.lang.System.getProperty('user.home'));
    if homedir(end) == '/'
        dspath = [homedir 'timeseries/'];
    else
        dspath = [homedir '/timeseries/'];
    end
end
end