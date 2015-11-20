function writecsv(savepath, header, varargin)
%TB.WRITECSV    Write a comma seaprated value file
%   WRITECSV(p,H,D) writes to the file in `p' the contents of the cell
%   array D, using H as the headers. D must be a n-by-numel(H) cell
%   where each element is either CHAR or DOUBLE.
%
%   WRITECSV(p,H,D1,D2,...,Dm) does the same, but considers that the
%   data to be saved is spread across the cell arrays D1,D2,...,Dm. Each
%   Di must have the same number of rows and the sum of numbers of cols
%   must equal numel(H). The data is written in the order of the
%   arguments.
%
%       Example:
%
%       d1 = {'a1' 'b1'; 'a2' 'b2'; 'a3' 'b3'};
%       d2 = {'c1'; 'c2'; 'c3'};
%       tb.writecsv('/tmp/test.csv', {'a','b','c'}, d1, d2);
%
numcols = 0;
for i = 1:numel(varargin)
    numcols = numcols + size(varargin{i}, 2);
end
tb.assert(numcols == numel(header), 'Total number of columns does not match number of elements in the header');

for i = 1:numel(varargin)
    tb.assert(size(varargin{i}, 1) == size(varargin{1}, 1), ['Cell array #%d has different number of rows than ' ...
        'cell array #1']);
end

f = fopen(savepath, 'w');
tb.assert(f > 0, ['Error opening file ''' savepath ''' for write']);

fprintf(f, '%s', header{1});
for i = 2:numel(header)
    fprintf(f, ',%s', header{i});
end
fprintf(f, '\n');

for row = 1:size(varargin{1}, 1)
    first = 1;
    for arg = 1:numel(varargin)
        for i = 1:size(varargin{arg}, 2)
            if ~first
                fprintf(f, ',');
            end
            
            value = varargin{arg}{row,i};
            if isequal(class(value), 'char')
                fprintf(f, '%s', value);
            else
                fprintf(f, '%f', value);
            end
            
            first = 0;
        end
    end
    fprintf(f, '\n');
end

fclose(f);