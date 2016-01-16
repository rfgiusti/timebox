function sharpshoot(Xa, Ya, Xe, Ye, varargin)
%TB.SHARPSHOOT  Produce a sharpshoot of the actual gain of X over Y
%versus the expected gain of X over Y, according to (Batista et al.,
%2011). See detailed help for reference.
%   SHARPSHOOT(Xa,Ya,Xe,Ye) produces a sharpshoot plot for the actual
%   gain Xa/Ya versus the expected gain Xe/Ye. Each Xa, Ya, Xe, and Ye
%   must be a cell array where each cell element is either a double or
%   the  empty matrix [].
%
%   Each Xa{i} stands for the actual value of X on the i-th experiment
%   or population. Eacg Xe{i} stands for the expected value of X on the
%   i-th experiment or population. Similar logic applies to Ya and Ye.
%
%   If the i-th row is the empty matrix [] for either Xa, Ya, Xe, or Ye,
%   the corresponding rows is ignored for the remaining variables. The
%   values are assumed to be in the interval [0,1].
%
%   The sharpshoot plot is introduced in the following paper: 
%       Batista, GEAPA; Wang, X; and Keogh, EJ. "A Complexity-Invariant
%       Measure for Time Series". Published in SIAM International
%       Conference on Data Mining (2011).
%
%   In the original paper, the authors compared their proposed method
%   (CID) against the baseline (Euclidean distance). The relation of
%   that with this implementation is as follows:
%       Xa: accuracy of the proposed method on the test data
%       Ya: accuracy of the baseline on the test data
%       Xe: accuracy of the proposed method on the training data
%       Ye: accuracy of the baseline on the training data
%
%   Example:
%
%       % Sharpshoot the actual gain of the Manhattan distance over the
%       % Euclidean distance against the expected gain with at most 5
%       % data sets
%       numdatasets = min(5, numel(ts.getnames));
%       
%
%       
%
%   SCAT(vdata,hdata,vlabel,hlabel) uses `vlabel' and `hlabel' as labels
%   for the horizontal and vertical methods. Both values must be of type
%   CHAR and the first character cannot be '-'.
%
%   SCAT(vdata,hdata,...) takes optional arguments. Each argument must
%   be of type CHAR and the first character must be '-'. If the argument
%   takes additional parameters, the parameters must follow the
%   arguments. The acceptable arguments are the following:
%
%       -invisible      does not show the scatter plot
%       -labels         the following argument is a cell which must
%                       contain two elements of type CHAR: the first is
%                       the label for the vertical method, and the
%                       second is the label for the horizontal method
%       -nooverwrite    only valid if -writepdf is also supplied; does
%                       not overwrite the write path
%       -noshadow       does not include a shadowed area under the upper
%                       method (try this option if MATLAB is crashing)
%       -writepdf       the following argument must be of type CHAR; the
%                       plot will be saved as a PDF in the given path
tb.assert(isequal(class(Ya), 'cell'), 'Ya must be of type CELL');
tb.assert(isequal(class(Xa), 'cell'), 'Xa must be of type CELL');
tb.assert(isequal(class(Ye), 'cell'), 'Ye must be of type CELL');
tb.assert(isequal(class(Xe), 'cell'), 'Xe must be of type CELL');
tb.assert(numel(Ya) == numel(Xa), 'Xa, Ya, Xe, and Ye must have equal number of elements');
tb.assert(numel(Ye) == numel(Xa), 'Xa, Ya, Xe, and Ye must have equal number of elements');
tb.assert(numel(Xe) == numel(Xa), 'Xa, Ya, Xe, and Ye must have equal number of elements');

% Get the non-empty data, calculate the gains
numpoints = 0;
gainA = zeros(numel(Xa), 1);
gainX = zeros(numel(Xa), 1);
for i = 1:numel(Xa)
    if ~isempty(Xa{i}) &&  ~isempty(Ya{i}) && ~isempty(Xe{i}) && ~isempty(Ye{i})
        numpoints = numpoints + 1;
        gainA(numpoints) = Xa{i} / Ya{i};
        gainX(numpoints) = Xe{i} / Ye{i};
    end
end
if numpoints == 0
    return
end
gainA(numpoints+1:end) = [];
gainX(numpoints+1:end) = [];

% Plot the data
scatter(gainX, gainA, 'r', 'filled');
hold on;
% if makeshadow
%     py = patch([0 0 1], [0 1 1], 'y');
%     pr = patch([0 0 1], [0 1 1], 'r');
%     alpha(py, .2);
%     alpha(pr, .1);
% end

% Make the grid. Add a small margin for visibility
plot([min(0.99, min(gainX)-0.01) max(1.05, max(gainX)+0.01)], [1 1], 'k');
plot([1 1], [min(0.99, min(gainA)-0.01) max(1.01, max(gainA)+0.01)], 'k');
axis('square');

end