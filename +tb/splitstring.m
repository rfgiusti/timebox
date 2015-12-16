function parts = splitstring(string, delimiter)
%TB.SPLITSTRING     Split a string into various pieces separated by a
%delimiter.
%   SPLITSTRING(S,D) returns the components of the string S when D is
%   used as a single-character delimiter. The components are returned as
%   a column cell of CHAR.
tb.assert(length(delimiter) == 1, 'Delimiter should be one single character');

occurences = strfind(string, delimiter);
if isempty(occurences)
    parts = {string};
    return
end

parts = cell(numel(occurences) + 1, 1);

% The positions where each substring ends. Adds a sentinel to the last
% character in the string.
endpoints = [occurences length(string) + 1];

left = 1;
nextpart = 1;
nextend = 1;
while left <= length(string)
    right = endpoints(nextend) - 1;
    if left > right
        parts{nextpart} = '';
    else
        parts{nextpart} = string(left:right);
    end
    
    left = endpoints(nextend) + length(delimiter);
    nextpart = nextpart + 1;
    nextend = nextend + 1;
end

% If the last delimiter ends at the last character, an empty string
% should be added to the list
if occurences(end) + length(delimiter) > length(string)
    parts{end} = '';
end
end