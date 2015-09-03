function y = iscached(dsname, varargin)
%TRANSFORM.ISCACHED     Verify if data set is cached for a given
%representation domain.
%   ISCACHED(DS,REP) returns 1 if the data set named DS has already been
%   cached in the representation named REP. If ommitted, REP defaults to
%   'time'.
path = transform.cachepath(dsname, varargin{:});
y = exist(path, 'file') == 2;
end