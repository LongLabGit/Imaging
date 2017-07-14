function [xRange, yRange] = identifyCorrelatedEdges(obj,varargin)
% identify which part of an image stack is suitable for motion correction
% i.e. skip the flyback line and exclude regions with mirroring on the left and right sides

p = inputParser;
p.addParamValue('plot',-1); % plotSpec
parse(p,varargin{:});


% get image mean
mn = mean(obj.images,4);

% identify correlations between neighboring columns
corrShift = circshift(corr(mn),[1 0]);
nbrCorr = diag(corrShift);
nbrCorr = nbrCorr(2:end);

% set threshold for correlation
highCutoff = prctile(nbrCorr,95);
highBands = bwlabel(nbrCorr>highCutoff);
midCutoff = prctile(nbrCorr,90);
midBands = bwlabel(nbrCorr>midCutoff);

% get points in high bands
leftBand = highBands == 1;
rightBand = highBands == max(highBands);

% find which mid band intersects the edgemost high band
leftMidBandID = unique(midBands(leftBand));
rightMidBandID = unique(midBands(rightBand));

% use the maximum extent of that and for the x range
xMin = find(midBands == leftMidBandID,1,'last');
xMax = find(midBands == rightMidBandID,1,'first');

xRange = [xMin xMax];

% use all lines except the bottom
yRange = [1 size(mn,2)-1];


% plot
if p.Results.plot >=0
    % make figure
    [~,plotFig] = parsePlotSpec(p.Results.plot);
    clf(plotFig)
    % plot image with bounds
    subplot(211)
    imagesc(mn.^0.5)
    pbaspect([obj.description.state.acq.scanAngleMultiplierFast... 
        obj.description.state.acq.scanAngleMultiplierSlow 1])
    hold on;plot([1 1]*xMin,ylim,'r',[1 1]*xMax,ylim,'r')
    colormap gray
    
    % plot analysis of bands
    subplot(212)
    plot(nbrCorr); hold on
    highCol = find(nbrCorr>highCutoff);
    midCol = find(nbrCorr>midCutoff);
    plot(highCol,nbrCorr(highCol),'r.')
    plot(midCol,nbrCorr(midCol),'go')
    plot(find(leftBand),1,'k');plot(find(rightBand),1,'k')
    
    drawnow
end


