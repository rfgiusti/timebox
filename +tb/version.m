function ver = version
%TB.VERSION     Return the version of TimeBox
%   Release dates:
%
%   0.12    - Nov-25-2016
%   0.11.9  - May-31-2016
%   0.11.8  - Apr-21-2016
%   0.10.7  - Mar-18-2016
%   0.10.6  - Mar-04-2016
%   0.9.5   - Nov-30-2015
%   0.8.4   - Sep-14-2015
%   0.8.3   - Sep-09-2015
%   0.7.2   - May-19-2015
%   0.6.1   - Apr-27-2015

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.1.0
ver = struct;
ver.major = 0;                               % major version
ver.minor = 12;                              % minor version
ver.patch = 0;                               % patch version
ver.release = 0;                             % release number: deprecated since v0.11.9
ver.releasedatenum = datenum(2016, 11, 07);  % date number value for the date of the last release
ver.special = '';                            % set flags for particular versions
end
