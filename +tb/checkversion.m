function checkversion(version)
%TB.CHECKVERSION    Check if TimeBox is compatible with the specified
%version. Raises an exception if not.
%   CHECKVERSION('1.0') will throw an exception if the current TimeBox
%   version is older than '1.0'.
%
%   CHECKVERSION(struct('major', 1, 'minor', 0)) is the same as the above.
%
%   CHECKVERSION(TB.VERSION) will always run silently.
%
%   CHECKVERSION('1.0.5') is the same as CHECKVERSION('1.0'). The extra
%   digit is treated as the release number, which is ignored.
%
%   CHECKVERSION('1.0+stable') will throw an exception if the current
%   TimeBox version is older than 1.0 or if the current TimeBox version
%   does not have the flag 'stable'.
%
%   CHECKVERSION('1.0-stable') will throw an exception if the current
%   TimeBox version is older than 1.0 or if the current TimeBox has the
%   flag 'stable'.
%
%   If the current version is not backwards-compatible with the expected
%   version, an exception will be thrown.
if isequal(class(version), 'char')
    specifiedversion = string2version(version);
else
    specifiedversion = version;
end

if versioncmp(tb.version, specifiedversion) < 0
    error(['Required TimeBox version ' version ' or later (currently running TimeBox version ' ...
        version2string(tb.version) ')']);
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


function vstruct = string2version(vstring)
S = regexp(vstring, '^(\d+)\.(\d+)', 'tokens');
tokens = S{1};
if numel(tokens) ~= 2
    error('tb:checkversion', ['Version string "' vstring '" is invalid']);
end
major = sscanf(tokens{1}, '%d');
minor = sscanf(tokens{2}, '%d');
vstruct = struct('major', major, 'minor', minor);
end


function vstring = version2string(vstruct)
vstring = sprintf('%d.%d', vstruct.major, vstruct.minor);
end


function d = versioncmp(a, b)
if a.major == b.major
    d = a.minor - b.minor;
else
    d = a.major - b.major;
end
end