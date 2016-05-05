function [wins, ties, losses] = wtl(x, y)
%TB.WTL     Compare the number of wins, ties, and losses of method 'x'
%versus method 'y'
%   [w,t,l] = WTL(X,Y) returns the number of wins, ties, and losses of the
%   method X against the method Y. Each X and Y must be a cell array where
%   each element is a single DOUBLE. X{i} wins over Y{i} if X{i}>Y{i}.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1.1
merged = tb.mergecells(x,y);

wins = 0;
ties = 0;
losses = 0;
for i = 1:size(merged, 1)
    diff = merged{i, 1} - merged{i, 2};
    if abs(diff) < eps
        ties = ties + 1;
    elseif diff > 0
        wins = wins + 1;
    else
        losses = losses + 1;
    end
end