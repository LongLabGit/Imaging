function roiMeans = extractRoiMeans(obj,rois)
% 
% rois - Y x X x R matrix (R = # ROIs)

nRois = size(rois,3);
nImages = size(obj.images,4);

roiMatrix = reshape(permute(rois,[3 1 2]),nRois,[]);
imsMatrix = double(reshape(permute(obj.images,[4 1 2 3]),nImages,[]));

% initialize storage of time courses
roiMeans = zeros(nImages,nRois);

for rr = 1:nRois
    theRoi = roiMatrix(rr,:);
    roiMeans(:,rr) = sum(repmat(theRoi,[nImages 1]).*imsMatrix,2)/sum(theRoi);
end
