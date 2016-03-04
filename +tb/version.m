function ver = version
%TB.VERSION     Return the version of TimeBox
%   Release dates:
%
%   0.11.7 - predicted
%   0.10.6 - Mar-04-2016
%   0.9.5  - Nov-30-2015
%   0.8.4  - Sep-14-2015
%   0.8.3  - Sep-09-2015
%   0.7.2  - May-19-2015
%   0.6.1  - Apr-27-2015
ver = struct;
ver.major = 0;                               % major version: increase with "big" changes
ver.minor = 11;                              % minor version: increase with bug fixes and "small" new functionalities
ver.release = 6;                             % release number: increase at every release
ver.releasedate = 'Mar-04-2016';             % MM-DD-YYYY date of last stable release; DEPRECTATED SINCE v0.8.4
ver.releasedatenum = datenum(2016, 03, 04);  % date number value for the date of release
ver.special = '';                            % set flags for particular versions
end
