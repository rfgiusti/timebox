function checkversion(version)
%TB.CHECKVERSION   Check if TimeBox is compatible with the specified
%version. Raises an exception if not.
%   CHECKVERSION('1.0.0') will throw an exception if the current TimeBox
%   version is older than '1.0.0'.
%
%   CHECKVERSION(struct('major', 1, 'minor', 0, 'patch', 0)) is the same as
%   the above.
%
%   CHECKVERSION(TB.VERSION) will always run silently.
%
%   CHECKVERSION('1.0') treats the ommitted patch number as '.0'.
%
%   If the current version is not backwards-compatible with the expected
%   version, an exception will be thrown.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 2.0
if isequal(class(version), 'char')
    [reqmajor, reqminor, reqpatch] = string2mmp(version);
else
    [reqmajor, reqminor, reqpatch] = struct2mmp(version);
end
[curmajor, curminor, curpatch] = struct2mmp(tb.version);

if reqmajor == curmajor
    if reqminor == curminor
        diff = reqpatch - curpatch;
    else
        diff = reqminor - curminor;
    end
else
    diff = reqmajor - curmajor;
end

if diff > 0
    error('TimeBox:VersionError', 'Required TimeBox %d.%d.%d or newer (currently running TimeBox %d.%d.%d)', ...
        reqmajor, reqminor, reqpatch, curmajor, curminor, curpatch);
end

% % If there is ever a backwards-compatibility break in TimeBox, uncomment
% % the verification below
% % Version x.y breaks compatibility of XX.YYY. If TimeBox was expected
% % to be of any version prior to x.y, then it was expected to provide
% % funcionalities that are potentially not supported. An exception should be
% % raised.
% breaksafter = struct('major', x, 'minor', y);
% if versioncmp(specifiedversion, breaksafter) < 0
%     error(['The current TimeBox version ' version2string(tb.version) ' is not compatible with the expected version ' ...
%         version '. Backwards-compatibility was broken in TimeBox %d.%d. Please visit ' ...
%         'http://github.com/rfgiusti/timebox for an older version of TimeBox.'], breaksafter.major, breaksafter.minor);
% end
end


function [major, minor, patch] = string2mmp(vstring)
separator = min([strfind(vstring, '-'), strfind(vstring, '+')]);
if ~isempty(separator)
    % Meta tags such as 1.0.0-beta or 1.0.0+beta may be used, but they are
    % currently ignored
    vstring = vstring(1:separator-1);
end

% The only thing allowed in the version number are numbers and points
assert(~isempty(regexp(vstring, '^[0-9.]+$', 'once')), 'Invalid version number: %s', vstring);

numpoints = numel(strfind(vstring, '.'));
if numpoints == 1
    version = sscanf(vstring, '%d.%d');
    major = version(1);
    minor = version(2);
    patch = 0;
elseif numpoints == 2
    version = sscanf(vstring, '%d.%d.%d');
    major = version(1);
    minor = version(2);
    patch = version(3);    
else
    error('Invalid version number: %s', vstring);
end
end


function [major, minor, patch] = struct2mmp(vstruct)
major = vstruct.major;
minor = vstruct.minor;
if isfield(vstruct, 'patch')
    patch = vstruct.patch;
else
    patch = 0;
end
end