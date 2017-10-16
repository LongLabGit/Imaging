function results = selectROIs(obj,varargin)
% extract time courses from user-selected ROIs
% 
% the mean image is plotted, the user selects regions of interest in the image series,
% and the time course of each ROI is computed.
%
%
% output is a single struct with all results:
%
% T = # time points in the image stack
% R = # ROIs selected
%
% results.F           T x R matrix, time course of each ROi
%        .Fc          same as F, but corrected (baseline-subtracted)
%        .colors      color of each ROI as drawn in the plot
%        .masks       R x Y x X matrix of the ROIs that were selected
%        .imageMean   mean of the images
%
%
% optional arguments: 
% 
%   channel     which channel to extract time course from
%   image       image to use to select ROIs
%   plotSpec    figure in which to draw the ROIs
%

p = inputParser;
p.addParamValue('channel',1); % channel to use
p.addParamValue('image',[]);
p.addParamValue('plotSpec',0);
parse(p,varargin{:});

% set up plot axes
plotAxes = parsePlotSpec(p.Results.plotSpec);


% dependent parameters
nImages = size(obj.images,4); % number of timepoints




% compute mean image
imageMean = squeeze(double(sum(obj.images(:,:,p.Results.channel,:),4))/nImages);


% create reference image on which to select ROIs

% if an image was specified
if ~isempty(p.Results.image)
    % use it as the reference image for tracing
    selectionImage = p.Results.image;
else
    % otherwise compute the sum of all images
    selectionImage = imageMean;
    % normalize range to [0 1] and take it to the 1/3 power
    selectionImage = normalizeToZeroOne(selectionImage).^(1/3);
    % replicate in all color channels
    selectionImage = repmat(selectionImage,[1 1 3]);
end


% plot image
cla(plotAxes);
image(selectionImage,'parent',plotAxes)

% set up
[xx,yy]=meshgrid(1:size(selectionImage,2),1:size(selectionImage,1));
set(gcf,'DefaultTextColor','blue')
set(gcf,'DefaultTextFontSize',18);

% initialize mask number to 0
mm=1;
% a new color will be added when each mask is generated
colors=[];

% loop through new masks the user draws a 2-point mask
while 1
    
    % wiat for user to draw a mask
    [masks(mm,:,:),xi,yi]=roipoly;
    
    % if it is a 2-point mask...
    if(length(xi)==3)
        % stop asking for new masks
        break
    end
    
    % choose a color for this mask
    colors=addRandomColor(colors,.4);
    
    % draw the mask on the image
    for pp=1:length(xi)-1
        L1=line([xi(pp) xi(pp+1)],[yi(pp) yi(pp+1)]);
        set(L1,'Color',colors(:,mm));
        set(L1,'LineWidth',2);
    end
    
    % write the number of the mask on the image
    thismask=find(squeeze(masks(mm,:,:))==1);
    H=text(median(xx(thismask)),median(yy(thismask)),sprintf('%d',mm));
    set(H,'HorizontalAlignment','center');
    
    % increment mask count
    mm=mm+1;
end

% remove the last mask (which was just a 2-point line)
masks=masks(1:mm-1,:,:);

% note number of masks
nMasks=size(masks,1);



tStart = now;

fprintf('%d cells selected, extracting time courses... ',nMasks)


% Extract mean fluorescence trace from the pixels in each mask

% reshape images so each row is an image
imsMatrix = reshape(permute(obj.images(:,:,p.Results.channel,:),[4 1 2 3]),nImages,[]);

switch 2
    case 1
        
        % reshape masks so each column is a mask
        maskMatrix = permute(reshape(masks,nMasks,[]),[2 1]);
        
        % compute sum of pixels in each mask
        pixelSum = single(imsMatrix) * maskMatrix;
        
        % divide by the number of pixels to get the mean
        pixelCount = sum(maskMatrix,1);
        F = pixelSum./repmat(pixelCount,[nImages 1]);
        
    case 2
        
        maskMatrix = reshape(uint16(masks),nMasks,[]);
        
        % initialize storage of time courses
        F = zeros(nImages,nMasks);
        
        for mm = 1:nMasks
            theMask = maskMatrix(mm,:);
            F(:,mm) = sum(repmat(theMask,[nImages 1]).*imsMatrix,2)/sum(theMask);
        end
end





fprintf('subtracting baseline... ')


%baseline subtract F files to create Fc files

% F     mean fluorescence of pixels in the mask
% Fc    F divided by baseline (baseline = 8th percentile of a moving window)


% set the window size
windowSize = 500;

% initialize Fc
Fc=zeros(size(F));

% cycle through each cell
for cc=1:size(F,2)
    
    % apply divisive normalization to remove this cell's baseline.
    % the baseline is estimated by taking the 8th percentile value
    % of a moving window of size windowSize
    
    % extract cell time course
    cellTimeCourse = F(:,cc);
    
    % initialize baseline
    baseline = zeros(nImages,1);
    
    % loop through all images
    for ii = 1:nImages
        
        % choose the bounds of this window
        windowBoundMin = max(1,ii-windowSize);
        windowBoundMax = min(nImages,ii+windowSize);
        
        % extract the time course of this window
        windowTimeCourse = cellTimeCourse(windowBoundMin:windowBoundMax);
        
        % choose the 8th percentile as the baseline
        baseline(ii) = prctile(windowTimeCourse,8);
    end
    
    % divide the time course by the baseline (i.e. delta F over F)
    timeCourseCorrected = (cellTimeCourse./baseline);
    
    % identify the maximum value
    tcMax = max(timeCourseCorrected);
    
    % subtract the median
    tc = timeCourseCorrected-median(timeCourseCorrected);
    
    % scale the time course to keep its original maximum value
    Fc(:,cc) = tc * tcMax/max(tc);
    
    
    
    % DEBUG: plot cell fluorescence trace and baseline
    if 0
        figure(23);clf;
        subplot(311);
        plot(baseline);
        subplot(312);
        plot(Fc(:,cc))
        subplot(313);
        plot(baseline,'b');hold on
        plot(F(:,cc),'r')
        linkaxes(get(gcf,'child'),'x')
        title(num2str(cc))
        pause
    end
    
end





% SAVE RESULT



fprintf('completed in %0.1f min\n',(now-tStart)*24*60)



results.F = F;
results.Fc = Fc;
results.colors = colors;
results.masks = masks;
results.imageMean = imageMean;






function colors=addRandomColor(colors,thresh)
% generate a distinct color from the current set of colors

N=size(colors,2);
mindist=0;
tries=0;
while and(mindist<thresh,tries<100)
    tries=tries+1;
    newcolor=rand(3,1);
    while sum(newcolor)>1.5
        newcolor=rand(3,1);
    end
    mindist=2*thresh;
    for i=1:N
        dist=newcolor(:,1)-colors(:,i);
        dist=sqrt(sum(dist.^2));
        if dist<mindist
            mindist=dist;
        end
    end
end
colors(:,N+1)=newcolor;




