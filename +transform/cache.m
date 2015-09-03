function cache(train, test, dsname, repname, meta) %#ok<INUSL>
%TRANSFORM.CACHE    Cache a data set for a given representation domain.
%   CACHE(TRAIN,TEST,DS,REPNAME) will cache the training data set in
%   TRAIN and the test data set in TEST for the data set name DS in the
%   representation named REPNAME. This function merely saves the data in
%   the appropriate location with the appropriate variable names so they
%   can be loaded by TimeBox. The data must have been previously
%   calculated.
%
%   Cached data sets may be loaded with TS.LOAD(DS,REPNAME).
%
%   CACHE(TRAIN,TEST,DS,REPNAME,META) may be used to specify a
%   meta-information structure to be saved in the cache file. If META is
%   not supplied, then TRANSFORM.CACHE will create a structure with the
%   fields "created" (creation time with the return value of NOW) and
%   "repname" (as in the REPNAME argument). If the META structure is
%   supplied without these fields, TRANSFORM.CACHE attempts to adds them.
%   If META is supplied as anything other than a STRUCT, TRANSFORM.CACHE
%   will just save the supplied value into the cache.
%
%   Example:
%
%       [train, test] = ts.load('Coffee');
%       [trainp, testp] = transform.ps(train, test);
%       meta = struct('author', 'John Doe');
%       % Save the transformed data set. Adds the meta information "author"
%       % with the value "John Doe". TRANSFORM.CACHE will add the fields
%       % "created" with value NOW (current timestamp) and "repname" with
%       %the value 'ps'
%       transform.cache(train, test, 'Cofee', 'ps', meta);
%
%   The representation name cannot be 'time'. The time-domain data is
%   saved as the original data sets.
%
%   If the data has been previously cached, they are replaced with the
%   new values.
assert(~isequal(lower(repname), 'time'), 'Can not cache original data as transformed data.');
path = transform.cachepath(dsname, repname);

if exist('meta', 'var')
    if isequal(class(meta), 'struct')
        if ~isfield(meta, 'created')
            meta.created = now;
        end
        if ~isfield(meta, 'repname')
            meta.repname = repname;
        end
    end
else
    meta = struct('created', now, 'repname', repname); %#ok<NASGU>
end

ts.ensuredir(path);
save(path, 'train', 'test', 'meta', '-mat');
end