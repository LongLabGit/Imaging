function desc = getScanImageHeader(imPath,safeMode)
% return struct of scan image params
% safeMode: if file was not generated in scanimage, returns empty struct rather than crashing

if ~exist('safeMode','var')
    safeMode = true;
end

% initialize struct
desc=struct;


if safeMode
    % imfinfo
    % slow, but doesn't crash
    
    % get image specs and load first image
    info = imfinfo(imPath);
    
    % if the ImageDescription field appears to have been generated by scanimage
    if isfield(info,'ImageDescription') && strfind(info(1).ImageDescription,'state.configName')
        
        % parse lines
        D=textscan(info(1).ImageDescription,'%s','Delimiter','\n');
        
    else
        return
    end
else
    % Tiff object (don't know how to check for existence of ImageDescription field, so if it's not there code will crash)
    
    t=Tiff(imPath,'r');
    D=textscan(t.getTag('ImageDescription'),'%s','Delimiter','\n');
    t.close
    clear t
    
end


% parse each line to load it into a struct
% these lines are of the form "state.software.version=3.6"
for dd=1:length(D{1})
    %eval(['desc.' strrep(D{1}{dd},'''','"') ';']);
    eval(['desc.' D{1}{dd} ';']);
end


