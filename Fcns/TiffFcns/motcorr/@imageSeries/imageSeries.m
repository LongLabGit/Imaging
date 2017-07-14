classdef imageSeries < handle
    %IMAGESERIES Series of images
    %
    %   loadImages('path/to/images.tif')
    %   loadImages('path/to/images.tif','verbose',0)
    %   loadImages('path/to/images.tif','channels',2)
    %   loadImages('path/to/images.tif','whichImages',[1 2 4 5])
    %   loadImages({'first/path.tif','second/path.tif'})
    
    
    properties
        images             %  d1=Y  d2=X  d3=color  d4=frame
        description
    end
    
    methods
        
        % value/type checking
        function set.images(obj,ims)
            if ~isa(ims,'numeric'); error('images must be numeric'); end
            obj.images = ims; end
        
        % constructor
        function obj = imageSeries(varargin)
            if ~isempty(varargin)
                
                % if string or cell array of strings, treat as path(s) to image file(s)
                if ischar(varargin{1}) || iscellstr(varargin{1})
                    obj.loadImages(varargin{:})
                    
                    % if a numeric array was passed, assume it is the image data
                elseif isnumeric(varargin{1})
                    obj.images = varargin{1};
                end
            end
        end
        
        % make rainbow summary viewer figure
        function viewRainbowSummary(obj)
            imageSeriesRainbowSummaryViewer(obj)
        end
        
        % make sequential viewer figure
        function plotImagesSequentially(obj)
            imageSeriesPlotSequentially(obj)
        end
        
    end %methods
    
end %classdef

