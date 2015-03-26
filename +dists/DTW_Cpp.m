function d = DTW_Cpp(ts1, ts2, r)
% r: size of (Sakeo-Chiba) band
    ts1=ts1(:)';
    ts2=ts2(:)';    
    n = length(ts1);
    m = length(ts2);
    
    if (~exist('r','var')), r=ceil( min(n,m)*0.1); end
    d = dists.DTW_mex(ts1,ts2,r);    
end