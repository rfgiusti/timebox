function ver = version
%TB.VERSION     Return the version of TimeBox
%   Release dates:
%
%   0.8.4 - Sep-14-2015
%   0.8.3 - Sep-09-2015
%   0.7.2 - May-19-2015
%   0.6.1 - Apr-27-2015
ver = struct;
ver.major = 0;                               % major version; increase with big changes. Currently unreleased
ver.minor = 8;                               % minor version; increase with new bug fixes "small" new functionalities
ver.release = 4;                             % release number; always increases
ver.releasedate = 'Sep-14-2015';             % MM-DD-YYYY date of last stable release; DEPRECTATE SINCE 0.8.4
ver.releasedatenum = datenum(2015, 09, 14);  % date number value for the date of release
ver.special = '';                            % set flags for particular versions
end
