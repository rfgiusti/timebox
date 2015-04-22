function ver = version
%TB.VERSION     Return the version of TimeBox
ver = struct;
ver.major = 0;          % major version; increase with big changes. Currently unreleased
ver.minor = 5;          % minor version; increase with new bug fixes "small" new functionalities
ver.release = 0;        % release number; always increases. Currently unreleased
ver.special = '';       % set flags for particular versions
end