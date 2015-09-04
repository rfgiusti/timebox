function ver = version
%TB.VERSION     Return the version of TimeBox
%   Release history:
%
%   0.8.3 - currently not released
%   0.7.2 - May-19-2015
%   0.6.1 - Apr-27-2015
ver = struct;
ver.major = 0;                               % major version; increase with big changes. Currently unreleased
ver.minor = 8;                               % minor version; increase with new bug fixes "small" new functionalities
ver.release = 2;                             % release number; always increases
ver.releasedate = 'May-19-2015';             % MM-DD-YYYY date of last stable release
ver.releasedatenum = datenum(2015, 05, 19);  % date number value for the date of last stable release
ver.special = 'alpha unreleased';            % set flags for particular versions
end
