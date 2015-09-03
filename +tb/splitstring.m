function parts = splitstring(string, delimiter)
%TB.SPLITSTRING     Split a string into various pieces separated by a
%delimiter.
%   SPLITSTRING(S,D) returns the components of the string S when D is
%   used as a delimiter. The components are returned as a column cell of
%   CHAR.
%
%   If the delimiter is longer that the text, SPLITSTRING returns an
%   empty cell.
if length(delimiter) > length(string)
    parts = {};
    return
end

occurences = strfind(string, delimiter);
if isempty(occurences)
    parts = {string};
    return
end

parts = cell(numel(occurences) + 1, 1);

% The positions where each substring ends. Adds a sentinel to the last
% character in the string.
endpoints = [occurences length(string) + 1];

pos = 1;
nextpart = 1;
nextend = 1;
while pos < length(string)
    ends = endpoints(nextend) - 1;
    if ends <= pos
        parts{nextpart} = '';
    else
        parts{nextpart} = string(pos:ends);
    end
    
    pos = endpoints(nextend) + length(delimiter);
    nextpart = nextpart + 1;
    nextend = nextend + 1;
end

% If the last delimiter ends at the last character, an empty string
% should be added to the list
if occurences(end) + length(delimiter) > length(string)
    parts{end} = '';
end
end