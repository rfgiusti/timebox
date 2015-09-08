function ensuredir(dirpath)
%TB.ENSUREDIR   Ensure that the specified absolute path is an existent
%directory. Works only with *NIX file systems starting on / (this may
%change in the future)
%   ENSUREDIR(S) verifies if the directories in the tree of S exists and
%   attempts to create each required parent directory so that the final
%   path is valid. It assumes the path is absolute.
tb.assert(~isempty(dirpath) && dirpath(1) ==    '/', 'Path must be absolute *NIX identifier (begins with /)');
if ~exist(dirpath, 'file')
    dirparts = tb.splitstring(dirpath, '/');
    
    nextdir = '';
    for i = 2:numel(dirparts)
        if ~isequal(dirparts{i}, '/')
            nextdir = [nextdir '/' dirparts{i}]; %#ok<AGROW>
            if ~exist(nextdir, 'file')
                try
                    mkdir(nextdir);
                catch e
                    err = MException('TimeBox:EnsureDir', 'Error creating part %s of path %s: %s\n', nextdir, ...
                        dirpath, e.message);
                    throw(err);
                end;
            end
        end
    end
end
end