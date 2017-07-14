function discardBottomLine(obj)

obj.images = obj.images(1:end-1,:,:,:);
