function sharpshoot(Xa, Ya, Xe, Ye, varargin)
%TB.SHARPSHOOT  Produce a sharpshoot of the actual gain of X over Y
%versus the expected gain of X over Y, according to (Batista et al.,
%2011). See detailed help for reference.
%   SHARPSHOOT(Xa,Ya,Xe,Ye) produces a sharpshoot plot for the actual
%   gain Xa/Ya versus the expected gain Xe/Ye. Each Xa, Ya, Xe, and Ye
%   must be a cell array where each cell element is either a double or
%   the  empty matrix []. The function TB.LOADFILES loads cell arrays in
%   a format suitable to be used by this function.
%
%   Each Xa{i} stands for the actual value of X on the i-th experiment
%   or population. Each Xe{i} stands for the expected value of X on the
%   i-th experiment or population. Similar logic applies to Ya and Ye. All
%   values are expected to be in the interval [0,1], and the concept of
%   "gain" is defined as the ratio Xa{i}/Ya{i} or Xe{i}/Ye{i}. (NOTICE:
%   this is the original concept of gain proposed by Batista et al., but it
%   will be changed to Xa{i}-Ya{i} and Xe{i}-Ye{i} in the next release of
%   TimeBox)
%
%   If the i-th row is the empty matrix [] for either Xa, Ya, Xe, or Ye,
%   the corresponding row is ignored for the remaining variables.
%
%   The sharpshoot plot was introduced in the following paper: 
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
%       datasets = ts.getnames;
%       numdatasets = min(5, numel(datasets));
%       for i = 1:numdatasets
%           [train, test] = ts.load(datasets{i});
%           euc_exp{i} = runs.leaveoneout(train);
%           euc_act{i} = runs.partitioned(train, test);
%           man_exp{i} = runs.leaveoneout(train, @dists.manhattan);
%           man_act{i} = runs.partitioned(train, test, @dists.manhattan);
%       end
%       tb.sharpshoot(man_act, euc_act, man_exp, euc_exp, ...
%               'Actual Gain', 'Expected Gain');
%       
%       
%   SHARPSHOOT(Xa,Ya,Xb,Yb,vlabel,hlabel) uses `vlabel' and `hlabel' as
%   labels for the horizontal and vertical axes. Both values must be of
%   type CHAR and the first character cannot be a '-'.
%
%   SHARPSHOOT(Xa,Ya,Xb,Yb,...) takes optional arguments. Each argument
%   must be of type CHAR and the first character must be '-'. If the
%   argument takes additional parameters, the parameters must follow the
%   arguments immediately. The acceptable arguments are the following: 
%
%       -invisible      does not show the sharpshoot plot
%       -labels         the next argument must a cell which with two
%                       elements of type CHAR: the first is the label for
%                       the vertical method, and the second is the label
%                       for the horizontal method
%       -nooverwrite    only valid if -writepdf is also supplied; does
%                       not overwrite the PDF filedump
%       -writepdf       the next argument must be of type CHAR; the plot
%                       will be saved as a PDF in the given path 

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.1
tb.assert(isequal(class(Ya), 'cell'), 'Ya must be of type CELL');
tb.assert(isequal(class(Xa), 'cell'), 'Xa must be of type CELL');
tb.assert(isequal(class(Ye), 'cell'), 'Ye must be of type CELL');
tb.assert(isequal(class(Xe), 'cell'), 'Xe must be of type CELL');
tb.assert(numel(Ya) == numel(Xa), 'Xa, Ya, Xe, and Ye must have equal number of elements');
tb.assert(numel(Ye) == numel(Xa), 'Xa, Ya, Xe, and Ye must have equal number of elements');
tb.assert(numel(Xe) == numel(Xa), 'Xa, Ya, Xe, and Ye must have equal number of elements');

% Default options
vlabel = 'Actual gain';
hlabel = 'Expected gain';
invisible = 0;
nofigure = 0;
nooverwrite = 0;
savepath = '';

% If the first two variadic arguments exist and do not start with '-',
% it is assumed that they are the labels for the vertical and horizontal
% labels
next = 1;
if numel(varargin) >= 2
    v1 = varargin{1};
    v2 = varargin{2};
    if isequal(class(v1), 'char') && isequal(class(v2), 'char') && v1(1) ~= '-' && v2(1) ~= '-'
        vlabel = v1;
        hlabel = v2;
        next = 3;
    end
end

% Process the remaining arguments
while next <= numel(varargin)
    switch varargin{next}
        case '-labels'
            tb.assert(numel(varargin) > next, 'Missing value for option -labels');
            labels = varargin{next + 1};
            tb.assert(isequal(class(labels), 'cell') && numel(labels) == 2, 'Usage: -labels, {vlabel, hlabel}');
            vlabel = labels{1};
            hlabel = labels{2};
            next = next + 2;
        case '-invisible'
            invisible = 1;
            next = next + 1;
        case '-nofigure'
            nofigure = 1;
            next = next + 1;
        case '-nooverwrite'
            nooverwrite = 1;
            next = next + 1;
        case '-writepdf'
            tb.assert(numel(varargin) > next, 'Missing value for option -writepdf');
            savepath = varargin{next + 1};
            tb.assert(isequal(class(savepath), 'char'), 'Usage: -writepdf, writepath');
            next = next + 2;
        otherwise
            if isequal(class(varargin{next}), 'char')
                error('sharpshoot:InputError', 'Unknown argument: "%s"', varargin{next});
            else
                error('sharpshoot:InputError', 'Parameter #%d of class %s is unexpected', next, class(varargin{next}));
            end
    end 
end

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

% Set the visibility flag for figure()
if invisible
    visibility = 'off';
else
    visibility = 'on';
end

% Create a new figure
if ~nofigure
    f = figure('Visible', visibility);
end

% Plot the data
scatter(gainX, gainA, 'r', 'filled');
hold on;

% Make the grid. Add a small margin for visibility
plot([min(0.99, min(gainX)-0.01) max(1.05, max(gainX)+0.01)], [1 1], 'k');
plot([1 1], [min(0.99, min(gainA)-0.01) max(1.01, max(gainA)+0.01)], 'k');
ylabel(strrep(vlabel, '_', '\_'), 'FontSize', 12, 'FontWeight', 'bold');
xlabel(strrep(hlabel, '_', '\_'), 'FontSize', 12, 'FontWeight', 'bold');
axis('square');

% Save to PDF, if the -writepdf options has been supplied
set(gcf, 'PaperSize', [5 5]);
set(gcf, 'PaperPosition', [0 0 5 5]);
if ~isempty(savepath) && ~(exist(savepath, 'file') && nooverwrite)
    print(f, '-dpdf', savepath);
end

% Delete the graph resources if the graph is supposed to go invisible
if invisible
    delete(gcf);
end
end