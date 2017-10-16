function [imCounts, pixelCounts, channelCounts] = getImageCount(imagePath,useScanimageHeader)
% [imCounts, pixelCounts, channelCounts] = getImageCount(imagePath,useScanimageHeader)
%
% return count of images in a single image path, or a list of image counts
% for multiple paths provided in a cell array
% e.g. getImageCount('/the/path/image.tif')
%      getImageCount({'/the/path/image.tif','/another/path/image.tif'})
% returns a vector giving the number of images in each file
% second argument is to use scanimage header, only set to true if the file
% is known to be generated by scanimage

% if only one provided, make into a cell array of strings
if ~iscell(imagePath); imagePath = {imagePath}; end

% be sure the arguments are all strings
assert(iscellstr(imagePath))

% by default don't assume file has scan image header
if~ exist('useScanimageHeader','var')
    useScanimageHeader = false;
end

% get number of images
imCounts = [];
% cycle through each image path
for ii=1:length(imagePath)
    
    % give error if file doesn't exist
    if ~exist(imagePath{ii},'file')
        error('File not found: %s',imagePath{ii})
    end

    
    if ~useScanimageHeader % look in each file to get image count -- slow
        
        % try fast method that can only handle up to 65536 images
        
        % open Tiff
        t=Tiff(imagePath{ii},'r');
        % set to astronomically high directory
        try, t.setDirectory(65536); end
        % it will automatically go to the last valid directory
        nImages = t.currentDirectory;
        % get size of a single frame
        nPix = t.getTag('ImageWidth')*t.getTag('ImageLength');
        % assume only 1 channel
        nChan = 1;
        % close stuff
        t.close
        clear t
        
        
        % if it returns 0 images, try slower method that can handle any size
        if nImages == 0
            
            imInfo = imfinfo(imagePath{ii});
            
            % extract parameters
            nImages = length(imInfo);
            nPix = length(imInfo)*imInfo(1).Width*imInfo(1).Height;
            nChan = 1;
            
        end
        
        
        
    else % get scanimage header -- fast, but fails when scan image doesn't know image count
        
        desc = getScanImageHeader(imagePath{ii},0);
        
        % extract parameters
        nImages = desc.state.acq.numberOfFrames;
        nChan =  desc.state.acq.savingChannel1 + ...
            desc.state.acq.savingChannel2 + ...
            desc.state.acq.savingChannel3 + ...
            desc.state.acq.savingChannel4;
        nPix = desc.state.acq.linesPerFrame * desc.state.acq.pixelsPerLine;
    end
    
    % sum from each image file
    imCounts(ii) = nImages;
    pixelCounts(ii) = nPix;
    channelCounts(ii) = nChan;
end





% 
% function answer = hasDirectory(t,dirNum)
% 
% answer = true;
% try
%     t.setDirectory(dirNum)
% catch
%     answer = false;
% end
%     
% 
% switch 4
%     case 1 % use tiff library, cycle through all images until reaching the last one
%         
%         t=Tiff(imagePath{ii},'r');
%         while ~t.lastDirectory; t.nextDirectory; end
%         nImages = t.currentDirectory;
%         nPix = t.getTag('ImageWidth')*t.getTag('ImageLength');
%         nChan = 1;
%         t.close
%         clear t
%         
%         
%     case 2 % use imfinfo
%         
%         imInfo = imfinfo(imagePath{ii});
%         
%         % extract parameters
%         nImages = length(imInfo);
%         nPix = length(imInfo)*imInfo(1).Width*imInfo(1).Height;
%         nChan = 1;
%         
%     case 3 % guess & check method (doesn't work)
%         
%         desc = getScanImageHeader(imagePath{ii},0);
%         nImGuess = desc.state.acq.numberOfFrames;
%         maxGuess = nImGuess;
%         
%         t=Tiff(imagePath{ii},'r');
%         while ~t.lastDirectory;
%             if ~hasDirectory(t,nImGuess)
%                 nImGuess = ceil(maxGuess - (maxGuess-nImGuess)/2);
%             else
%                 nImGuess = nImGuess + 1000;
%                 maxGuess = max(maxGuess,nImGuess);
%             end
%         end
%         nImages = t.currentDirectory;
%         nPix = t.getTag('ImageWidth')*t.getTag('ImageLength');
%         nChan = 1;
%         t.close
%         clear t
%         
%     case 4 % use tiff library, bizarre strategy that is fast
%         
%         % open Tiff
%         t=Tiff(imagePath{ii},'r');
%         % set to astronomically high directory
%         try, t.setDirectory(65536); end
%         % it will automatically go to the last valid directory
%         nImages = t.currentDirectory;
%         % get size of a single frame
%         nPix = t.getTag('ImageWidth')*t.getTag('ImageLength');
%         % assume only 1 channel
%         nChan = 1;
%         % close stuff
%         t.close
%         clear t
%         
% end
    