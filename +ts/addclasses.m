function ds = addclasses(cls, obs)
%TS.ADDCLASSES Add classes back into dataset.
%   DS = ADDCLASSES(CLS, OBS) adds the classes array CLS together with the
%   observations matrix OBS.
ds = [cls, obs];
end