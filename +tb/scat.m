function scat(vdata, hdata, varargin)
%TB.SCAT    Produce a scatter plot to compare two sets of experimental
%results
%   SCAT(vdata,hdata) produces a scatter plot comparing the results in
%   `vdata' against the results in `hdata'. Each set of results must be
%   a cell array where each cell element is either a double or the empty
%   matrix []. When the i-th cell of one set is empty, the correspondent
%   cell of the second set is ignored. The function TB.LOADFILES will
%   load a cell array in a format that is suitable to be used by
%   TB.SCAT.
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
%       -nofigure       does not create a new figure object; overrides
%                       -invisible
%       -nooverwrite    only valid if -writepdf is also supplied; does
%                       not overwrite the write path
%       -noshadow       does not include a shadowed area under the upper
%                       method (try this option if MATLAB is crashing)
%       -writepdf       the following argument must be of type CHAR; the
%                       plot will be saved as a PDF in the given path

tb.assert(isequal(class(vdata), 'cell'), 'vdata must be of type CELL');
tb.assert(isequal(class(hdata), 'cell'), 'hdata must be of type CELL');
tb.assert(numel(vdata) == numel(hdata), 'vdata and hdata must have equal number of elements');

vlabel = [];
hlabel = [];
invisible = 0;
savepath = [];
nooverwrite = 0;
nofigure = 0;
makeshadow = 1;

% If the first two variadic arguments exist and do not start with '-',
% it is assumed that they are the labels for the vertical and horizontal
% labels
if numel(varargin) >= 2
    v1 = varargin{1};
    v2 = varargin{2};
    if isequal(class(v1), 'char') && isequal(class(v2), 'char') && v1(1) ~= '-' && v2(1) ~= '-'
        vlabel = v1;
        hlabel = v2;
    end
    next = 3;
else
    next = 1;
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
            tb.assert(isequal(class(savepath), 'char'), 'Usage: -labels, writepath');
            next = next + 2;
        case '-noshadow'
            makeshadow = 0;
            next = next + 1;
        otherwise
            if isequal(class(varargin{next}), 'char')
                error('splot:InputError', 'Unknown parameter "%s"', varargin{next});
            else
                error('splot:InputError', 'Parameter #%d of class %s is unexpected', next, class(varargin{next}));
            end
    end 
end

% Get the non-empty data
numpoints = 0;
pointsy = zeros(numel(vdata), 1);
pointsx = zeros(numel(hdata), 1);
for i = 1:numel(vdata)
    if ~isempty(vdata{i}) &&  ~isempty(hdata{i})
        numpoints = numpoints + 1;
        pointsy(numpoints) = vdata{i};
        pointsx(numpoints) = hdata{i};
    end
end
if numpoints == 0
    return
end
pointsy(numpoints+1:end) = [];
pointsx(numpoints+1:end) = [];

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

% Plot the scatter and add a shadow in the left upper side
scatter(pointsx, pointsy, 'k', 'filled');
if makeshadow
    py = patch([0 0 1], [0 1 1], 'y');
    pr = patch([0 0 1], [0 1 1], 'r');
    alpha(py, .2);
    alpha(pr, .1);
end
    
% Add labels, if names have been supplied
if ~isempty(vlabel)
    ylabel(strrep(vlabel, '_', '\_'), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(strrep(hlabel, '_', '\_'), 'FontSize', 12, 'FontWeight', 'bold');
end

% Add the diagonal line separating the methods and make the graph
% square-sized
hold on;
plot([0 1], [0 1]);
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
