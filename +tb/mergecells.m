function [merged, removed] = mergecells(varargin)
%TB.MERGECELLS  Takes several columns cells and concatenate them into a
%single cell, excluding rows where any cell contains empty data
%   MERGECELLS(cell1,cell2) returns the cell [cell1(:) cell2(:)]
%
%   Example:
%
%       cell1 = { 'a1'  'b1'; ...
%                 'a2'  []  ; ...
%                 'a3'  'b3' };
%       cell2 = { 'c1' ; ...
%                 'c2' ; ...
%                 'c3' };
%       MERGECELLS(cell1, cell2)
%
%       ans = 
%
%           'a1'  'b1'  'c1'
%           'a3'  'b3'  'c3'
%
%   In the above example, the second row was excluded because cell1{2,1}
%   was empty.
%
%   [M,R] = MERGECELLS(cell1,cell2,...) returns the merged rows in M and
%   the removed rows in R.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.2
numcolumns = 0;
maxrows = size(varargin{1}, 1);
for i = 1:numel(varargin)
    tb.assert(size(varargin{i}, 1) == maxrows, 'All cells must have the same number of rows');
    numcolumns = numcolumns + size(varargin{i}, 2);
end

merged = cell(maxrows, numcolumns);
removed = cell(maxrows, numcolumns);
mergecount = 0;
removecount = 0;

for row = 1:maxrows
    [rowdata, isfull] = getrow(row, numcolumns, varargin{:});
    if isfull
        mergecount = mergecount + 1;
        merged(mergecount,:) = rowdata;
    else
        removecount = removecount + 1;
        removed(removecount,:) = rowdata;
    end
end

% Remove empty rows
merged(mergecount+1:end,:) = [];
removed(removecount+1:end,:) = [];
end


function [rowdata, isfull] = getrow(row, numcolumns, varargin)
% Join the rows of all cells into a single cell array and check if the are
% all non-empty
isfull = 1;
rowdata = cell(1, numcolumns);
nextcol = 1;
for i = 1:numel(varargin)
    for j = 1:size(varargin{i}, 2)
        if isempty(varargin{i}{row, j})
            isfull = 0;
        end
        rowdata{nextcol} = varargin{i}{row,j};
        nextcol = nextcol + 1;
    end
end
end