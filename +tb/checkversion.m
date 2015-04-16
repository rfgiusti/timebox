function checkversion(version)
%TB.CHECKVERSION    Check if TimeBox is compatible with the specified
%version. Raises an exception if not.
%   CHECKVERSION('1.0') will throw an exception if the current TimeBox
%   version is older than '1.0'.
%
%   CHECKVERSION('1.0+stable') will throw an exception if the current
%   TimeBox version is older than '1.0' or if the current TimeBox
%   version is specified as unstable.
%
%   If the current version is not backwards-compatible with the expected
%   version, an exception will be thrown.
current = breakversion(tb.version);
specified = breakversion(version);
if versioncmp(current, specified) < 0
    error(['Required TimeBox version ' version ' or later (currently running TimeBox version ' tb.version ')']);
end

if current.stable == -1 && specified.stable == 1
    error(['You are currently running an alpha (unstable) version of TimeBox. Please get stable version %d.%d or ' ...
        'compatible at http://github.com/rfgiusti/timebox'], specified.major, specified.minor);
end

% If there is ever a backwards-compatibility break in TimeBox, uncomment
% the verification below
% % Version x.y breaks compatibility of TS.LOAD. If TimeBox was expected
% % to be of version 0.x or inferior, raises a non-backwards compatibility
% % exception
% breaksafter = struct('major', x, 'minor', y);
% if versioncmp(specified, breaksafter) < 0
%     error(['The current TimeBox version ' tb.version ' is not compatible with the expected version ' version '. ' ...
%         'Backwards-compatibility was broken in version %d.%d. Please visit http://github.com/rfgiusti/timebox for ' ...
%         'an older version of TimeBox.', breaksafter.major, breaksafter.minor]);
% end
end


function vstruct = breakversion(vstring)
tmpcell = regexp(vstring, '^(\d+)\.(\d+)(+stable|+unstable)?$', 'tokens');
tokens = tmpcell{1};
major = sscanf(tokens{1}, '%d');
minor = sscanf(tokens{2}, '%d');
if isempty(tokens{3})
    stable = 0;
elseif isequal(tokens{3}, '+stable')
    stable = 1;
elseif isequal(tokens{3}, '+unstable')
    stable = -1;
else
    error(['Version string "' vstring '" is invalid']);
end
vstruct = struct('major', major, 'minor', minor, 'stable', stable);
end


function d = versioncmp(a, b)
if a.major == b.major
    d = a.minor - b.minor;
else
    d = a.major - b.major;
end
end