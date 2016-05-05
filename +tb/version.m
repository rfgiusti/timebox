function ver = version
%TB.VERSION     Return the version of TimeBox
%   Release dates:
%
%   0.11.9 - Planned
%   0.11.8 - Apr-21-2016
%   0.10.7 - Mar-18-2016
%   0.10.6 - Mar-04-2016
%   0.9.5  - Nov-30-2015
%   0.8.4  - Sep-14-2015
%   0.8.3  - Sep-09-2015
%   0.7.2  - May-19-2015
%   0.6.1  - Apr-27-2015

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.1
ver = struct;
ver.major = 0;                               % major version
ver.minor = 11;                              % minor version
ver.release = 9;                             % release number: deprecated since v0.11.9
ver.releasedatenum = datenum(2016, 04, 21);  % date number value for the date of the last stable release
ver.special = 'alpha';                       % set flags for particular versions
end
