function savemeta(dsname, representation, meta)
%TS.SAVEMETA    Store meta information in a data set
%   SAVEMETA(ds, META) stores the variable "META" within the data set
%   "ds". The contents of the meta-information is not specified, but it
%   must be a STRUCT. If the data set "dsname" does not exist, an
%   exception is raised. If the data set already has a variable for
%   meta-information, it will be replaced.
%
%   See also: TS.LOADMETA
%
%   Example:
%       >> meta = struct;
%       >> meta.creator = 'Mrs. Robinson';
%       >> meta.created = now;
%       >> ts.savemeta('Beef', meta);
%
%   SAVEMETA(ds, rep, META) does the same, but for the version of the
%   data set stored in the representation "rep".
%
%   Example (add representation name to an already existing meta field):
%       >> meta = ts.load('GunPoint', 'ps');
%       >> meta.representation = 'Power Spectrum';
%       >> ts.saemeta('GunPoint', 'ps', meta);
if exist('meta', 'var')
    tb.assert(isequal(class(representation), 'char'), ['When called with three arguments, the second must be of ' ...
        'class CHAR and it must be a valid representation name']);
else
    meta = representation;
    representation = 'time';
end
tb.assert(isequal(class(meta), 'struct'), 'The last argument must be a STRUCT');
dspath = ts.getpath(dsname, representation);
tb.assert(exist(dspath, 'file'), ['The data set ' dsname ' with ' representation ' representation is not ' ...
        'stored in the TimeBox repository']);

save(dspath, 'meta', '-mat', '-append');