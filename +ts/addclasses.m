function ds = addclasses(cls, obs)
%TS.ADDCLASSES Add classes back into dataset.
%   DS = ADDCLASSES(CLS, OBS) adds the classes array CLS together with the
%   observations matrix OBS.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
ds = [cls, obs];
end