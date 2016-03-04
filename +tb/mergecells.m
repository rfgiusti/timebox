function merged = mergecells(varargin)
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
numcolumns = 0;
maxrows = size(varargin{1}, 1);
for i = 1:numel(varargin)
    tb.assert(size(varargin{i}, 1) == maxrows, 'All cells must have the same number of rows');
    numcolumns = numcolumns + size(varargin{i}, 2);
end

effectiverows = 0;
merged = cell(maxrows, numcolumns);

for row = 1:maxrows
    rowdata = getrow(row, numcolumns, varargin{:});
    if ~isempty(rowdata)
        effectiverows = effectiverows + 1;
        merged(effectiverows,:) = rowdata;
    end
end

% Remove empty rows
merged(effectiverows+1:end,:) = [];
end


function rowdata = getrow(row, numcolumns, varargin)
% Gather the row data for all cells, only if they are all non-empty
rowdata = cell(1, numcolumns);
nextcol = 1;
for i = 1:numel(varargin)
    for j = 1:size(varargin{i}, 2)
        if isempty(varargin{i}{row, j})
            rowdata = [];
            return
        end
        rowdata{nextcol} = varargin{i}{row,j};
        nextcol = nextcol + 1;
    end
end
end