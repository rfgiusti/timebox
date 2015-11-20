function writecsv(path, header, varargin)
%TB.WRITECSV    Write a comma seaprated value file
%   WRITECSV(p,H,D) writes to the file in `p' the contents of the cell
%   array D, using H as the headers. D must be a n-by-numel(H) cell
%   where each element is either CHAR or DOUBLE.
%
%   WRITECSV(p,H,D1,D2,...,Dm) does the same, but considers that the
%   data to be saved is spread acrss the cell arrays D1,D2,...,Dm. Each
%   Di cell array must have the same number of rows and the sum of
%   number of cols must equal numel(H). The data is written in the order
%   of the arguments.
numcols = 0;
for i = 1:numel(varargin)
    numcols = numcols + size(varargin{i}, 2);
end
tb.assert(numcols == numel(header), 'Total number of columns does not match number of elements in the header');

for i = 1:numel(varargin)
    tb.assert(size(varargin{i}, 1) == size(varargin{1}, 1), ['Cell array #%d has different number of rows than ' ...
        'cell array #1']);
end