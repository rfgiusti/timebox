function d = DTW_Cpp(ts1, ts2, r)
%DISTS.DTW_Cpp   Calculate the DTW distance between two time series using
%Sakoe-Chiba band and an auxiliary MEX function.
%   DTW_Cpp(S,Z) returns the DTW distance between the time series S and Z
%   using a Sakoe-Chiba band with length equal to 10% of the shortest
%   series between S and Z.
%
%   DTW_Cpp(S,Z,r) returns the DTW distance between S and Z using r
%   observations as the length of the Sakoe-Chiba window.
%
%   Notice: this function requires that the file +dists/DTW_mex.cpp be
%   compiled into a MEX binary.

%   Revision 0.1
    ts1=ts1(:)';
    ts2=ts2(:)';    
    n = length(ts1);
    m = length(ts2);
    
    if (~exist('r','var')), r=ceil( min(n,m)*0.1); end
    d = dists.DTW_mex(ts1,ts2,r);    
end