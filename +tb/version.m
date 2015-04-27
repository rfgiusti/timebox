function ver = version
%TB.VERSION     Return the version of TimeBox
ver = struct;
ver.major = 0;                    % major version; increase with big changes. Currently unreleased
ver.minor = 6;                    % minor version; increase with new bug fixes "small" new functionalities
ver.release = 1;                  % release number; always increases. Currently unreleased
ver.releasedate = 'Apr-27-2015';  % MM-DD-YYYY date of last stable release
ver.special = '';                 % set flags for particular versions
end
