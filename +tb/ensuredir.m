function ensuredir(path)
%TB.ENSUREDIR   Ensure that the specified absolute path is an existent
%directory. Works only with *NIX file systems starting on / (this may
%change in the future)
%   ENSUREDIR(S) verifies if the directories in the tree of S exists and
%   attempts to create each required parent directory so that the final
%   path is valid. It assumes the path is absolute.
%
%   If the path points to a file or if any of the parent directories are
%   files, nothing is done. If any directory is created and an error
%   happens before the last directory is created, the partially created
%   path will remain in the file system.
slashes = strfind(path, '/');
tb.assert(~isempty(slashes) && slashes(1) == 1, 'Path must be absolute *NIX identifier (begins with /)');
if ~exist(path, 'file')
    dirparts = {};
    
end
end