function [wins, ties, losses] = wtl(x, y)
%TB.WTL     Compare the number of wins, ties, and losses of method 'x'
%versus method 'y'
merged = tb.mergecells(x,y);

wins = 0;
ties = 0;
losses = 0;
for i = 1:size(merged, 1)
    if abs(x{i} - y{i}) < 1e-10
        ties = ties + 1;
    elseif x{i} > y{i}
        wins = wins + 1;
    else
        losses = losses + 1;
    end
end