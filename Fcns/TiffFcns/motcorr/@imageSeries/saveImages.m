function saveImages(obj,varargin)

% obj.saveImages
% obj.saveImages('/path/to/images.tif')
% obj.saveImages('savePath','/some/default/path')
% obj.saveImages('fileName','someDefaultName')

p = inputParser;
p.addOptional('saveString',[],@ischar)
p.addParamValue('savePath',[],@ischar)
p.addParamValue('fileName',[],@ischar)
p.addParamValue('verbose',true);
p.addParamValue('whichImages',[],@(x)all(x>0)&&all(x==round(x))); % ensure all positive integers
p.addParamValue('overwrite',false);
parse(p,varargin{:});


% CHOOSE DESTINATION

% use saveString if provided
if ~isempty(p.Results.saveString)
    saveLocation = p.Results.saveString;
    
else % otherwise...
    
    % if either path or name is unspecified, prompt for both
    if isempty(p.Results.savePath) || isempty(p.Results.fileName)
        [filename, pathname] = uiputfile({'.tif','TIF'},...
            'Choose location to save images',p.Results.fileName);
    else
        % if both were specified, use them
        filename = p.Results.fileName;
        pathname = p.Results.savePath;
    end
    
    % throw error if something didn't work
    if isempty(filename) || isempty (pathname)
        error('Must specify path and file name');end
    
    % put file and path name into saveLocation
    saveLocation = [pathname filename];
end


% remove .tif extension from file name (if there is one)
saveLocation = strrep(saveLocation, '.tif','');


% don't overwrite existing file
if exist([saveLocation '.tif'],'file') && ~p.Results.overwrite
    fprintf('File %s already exists, saving as %s\n',saveLocation,[saveLocation '_'])
    saveLocation = [saveLocation '_'];
end



% SAVE IMAGES

% convert to uint16
ims=uint16(obj.images);

% choose which images to save
if isempty(p.Results.whichImages)
    whichImages = 1:size(ims,4);
else
    whichImages = intersect(1:size(ims,4),p.Results.whichImages);
end

% display save path
if p.Results.verbose
    fprintf('Saving to %s.tif\n     ',saveLocation)
end

% write first image
imwrite(ims(:,:,:,whichImages(1)),[saveLocation '.tif'],'TIF','compression', 'none')

% write subsequent images
for ii=2:length(whichImages)
    imwrite(ims(:,:,:,whichImages(ii)),[saveLocation '.tif'],...
        'TIF','WriteMode','append','compression','none');
    
    % update progress indicator
    if p.Results.verbose && mod(ii,floor(length(whichImages)/10))==0;
        fprintf('%d, ',ii); end
end
% update progress indicator
if p.Results.verbose, fprintf('saved %d images\n',ii); end


% unneeded code

% change to proper size
% ims_size=size(ims);
% if length(ims_size)==3;
%     ims = permute(ims,[1 2 4 3]);
%     ims_size=size(ims);
% end
