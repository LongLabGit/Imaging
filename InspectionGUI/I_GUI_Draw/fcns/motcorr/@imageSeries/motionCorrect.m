function [results,params] = motionCorrect(obj,varargin)

p = inputParser;
p.addParamValue('whichChannel',1); % channel for motion correction
p.addParamValue('keepChannels',1); % which channels to keep
p.addParamValue('verbose',true);
p.addParamValue('save',true);
p.addParamValue('xCrop',[]); %19 239
p.addParamValue('yCrop',[]); %1 63
p.addParamValue('minSamples',75);
p.addParamValue('maxShift',8);
p.addParamValue('shifts',[]);
p.addParamValue('plateau',true);
p.addParamValue('correlationThreshold',0.75);
p.addParamValue('referenceFrame',[]);
p.addParamValue('dataClass','double');
p.addParamValue('savePath',[],@ischar);
parse(p,varargin{:});





% set save name
if p.Results.save
    % prompt for name/location if not specified
    if isempty(p.Results.savePath)
        [saveName,savePath] = uiputfile('*.tif','choose save location for motion-corrected images');
        % remove any file extension
        [~,saveName] = fileparts(saveName);
    else
        [savePath,saveName] = fileparts(p.Results.savePath);
    end
    
    % error check
    if ~exist(savePath,'dir')
        error('%s does not exist',savePath)
    end
    
end




% note size
M = size(obj.images,2);
N = size(obj.images,1);
F = size(obj.images,4);


% note start time
tStart = now;




% CROP
% unless specified otherwise, exclude only the bottom line

if isempty(p.Results.xCrop)
    x1 = 1;
    x2 = M;
else
    x1 = p.Results.xCrop(1);
    x2 = p.Results.xCrop(2);
end

if isempty(p.Results.yCrop)
    y1 = 1;
    y2 = N-1;
else
    y1 = p.Results.yCrop(1);
    y2 = p.Results.yCrop(2);
end

xKeep = max(x1,1):min(x2,M);
yKeep = max(y1,1):min(y2,N-1);



% create copy of images containing only the color channel used for motion correction and cropped to the desired x-y size
eval(sprintf('ims = %s(squeeze(obj.images(yKeep,xKeep,p.Results.whichChannel,:)));',p.Results.dataClass))


% set max number of pixels that can be processed at once
maxPixelCount = 64*512*15000/4;


if isempty(p.Results.shifts)
    
    % CHOOSE REFERENCE FRAME
    
    if isempty(p.Results.referenceFrame)
        searchframes=round([(F/2)-F/8 (F/2)+F/8]);
        [~,b]=min(squeeze(mean(mean((abs(diff(ims(:,:,searchframes(1):searchframes(2)),1,3)))))));
        refFrameIndex=searchframes(1)+b-1;
    else
        refFrameIndex = p.Results.referenceFrame;
        if any(refFrameIndex) > F
            fprintf('specified reference frame(s):\n')
            disp(refFrameIndex)
            error('specified reference frame(s) exceeds image count (%d)',F)
        end
        %figure;imagesc(refFrameImage);colormap gray
    end
    
    refFrameImage = mean(ims(:,:,refFrameIndex),3);
    
    if p.Results.verbose, fprintf('Using frame %d as reference frame.\n',refFrameIndex); end
    
    
    % IDENTIFY MOTION IN EACH FRAME
    
    % if movie is sufficiently small, identify motion shifts all at once
    if numel(ims) <= maxPixelCount
        
        %[xshifts,yshifts]=track_subpixel_wholeframe_motion_varythresh(...
        %    ims,refFrameIndex,p.Results.maxShift,p.Results.correlationThreshold,p.Results.minSamples,p.Results.verbose);
        
        [xshifts,yshifts,nSamp,corrThresh]=identifyOptimalShifts(...
            cat(3,refFrameImage,ims),1,p.Results.maxShift,...
            p.Results.correlationThreshold,p.Results.minSamples,p.Results.verbose,p.Results.plateau);
        
        
        % accumulate shifts (ignoring the shift of the prepended reference frame)
        xshifts = xshifts(2:end);
        yshifts = yshifts(2:end);
        nSamp = nSamp(2:end);
        corrThresh = corrThresh(2:end);
        
    else
        % otherwise divide into parts
        
        % divide movie into several parts
        partLength = round(maxPixelCount/numel(ims(:,:,1))/2);
        divEnd = [partLength:partLength:(F-1) F];
        divStart = [1 divEnd(1:end-1)+1];
        
        if p.Results.verbose
            fprintf('Dividing movie into %d chunks\n',length(divEnd))
        end
        
        % initialize storage
        xshifts = [];
        yshifts = [];
        nSamp = [];
        corrThresh = [];
        
        % motion correction on each part
        for pp=1:length(divStart)
            
            
            [xshifts_,yshifts_,nSamp_,corrThresh_]=identifyOptimalShifts(...
                ... put reference frame first, then movie frames for this part
                cat(3,refFrameImage,ims(:,:,divStart(pp):divEnd(pp))),...
                1,p.Results.maxShift,p.Results.correlationThreshold,p.Results.minSamples,...
                p.Results.verbose,p.Results.plateau);
            
            % accumulate shifts (ignoring the shift of the prepended reference frame)
            xshifts = [xshifts xshifts_(2:end)];
            yshifts = [yshifts yshifts_(2:end)];
            nSamp = [nSamp nSamp_(2:end)];
            corrThresh = [corrThresh corrThresh_(2:end)];
            
        end
        
        
    end
    
    
else
    
    fprintf('Using specified shifts to correct motion\n')
    xshifts = p.Results.shifts(1,:);
    yshifts = p.Results.shifts(2,:);
    nSamp = [];
    corrThresh = [];
    refFrameIndex = [];
end

clear ims



% CORRECT OBSERVED MOTION


% if there are too many pixels, divide into chunks for computing new shift
pixelCount = length(yKeep) * length(xKeep) * size(obj.images,3) * size(obj.images,4);
if pixelCount > maxPixelCount
    
    % divide into subparts
    partLength = round(maxPixelCount/(length(yKeep)*length(xKeep))/2);
    divEnd = [partLength:partLength:(F-1) F];
    divStart = [1 divEnd(1:end-1)+1];
    
    % identify shift extrema
    maxXshift = max(xshifts);
    minXshift = min(xshifts);
    maxYshift = max(yshifts);
    minYshift = min(yshifts);
    
    % apply motion correction to each part
    for pp=1:length(divStart)
        
        % get x and y shifts for this part, appending the most extreme
        % shifts for two dummy frames to be sure the movie is the correct size
        xshifts_ = [xshifts(divStart(pp):divEnd(pp)) minXshift maxXshift];
        yshifts_ = [yshifts(divStart(pp):divEnd(pp)) minYshift maxYshift];
        
        for cc = 1:length(p.Results.keepChannels)
            
            %             % compute the corrected movie for this part
            %             corrPart = playback_wholeframe_subpix(...
            %                 ims_cropped(:,:,p.Results.keepChannels(cc),[divStart(pp):divEnd(pp) 1 1]),...
            %                 xshifts_,yshifts_,[],p.Results.verbose,p.Results.dataClass);
            
            % compute the corrected movie for this part
            corrPart = applyFrameShifts(...
                obj.images(yKeep,xKeep,p.Results.keepChannels(cc),[divStart(pp):divEnd(pp) 1 1]),...
                xshifts_,yshifts_,[],p.Results.verbose,p.Results.dataClass);
            
            % save it into the result, removing the shifts that were added
            ims(:,:,cc,divStart(pp):divEnd(pp)) = corrPart(:,:,1:end-2);
            
        end
    end
    
else
    
    % crop x-y, but keep all colors and time points
    ims_cropped = obj.images(yKeep,xKeep,:,:);

    % apply motion correction to each part
    for cc = 1:length(p.Results.keepChannels)
        ims(:,:,cc,:)=applyFrameShifts(...
            ims_cropped(:,:,p.Results.keepChannels(cc),:),xshifts,yshifts,[],p.Results.verbose,p.Results.dataClass);
    end
end




% SAVE RESULT


% return the corrected images
results.imsCorrected = ims;
results.xshifts = xshifts;
results.yshifts = yshifts;
results.nSamp = nSamp;
results.corrThresh = corrThresh;
results.refFrameIndex = refFrameIndex;
% and parameters
params = rmfield(p.Results,{'save','savePath','verbose'});


% write to disk
if p.Results.save
    
    
    % save images
    motCorIms = imageSeries(ims);
    motCorIms.saveImages([savePath filesep saveName],'overwrite',true)
    
    % save parameters
    save([savePath filesep saveName '_params.mat'],'xshifts','yshifts','nSamp','corrThresh','params')
end


if p.Results.verbose, fprintf('Completed in %0.1f minutes.\n',(now-tStart)*24*60); end

