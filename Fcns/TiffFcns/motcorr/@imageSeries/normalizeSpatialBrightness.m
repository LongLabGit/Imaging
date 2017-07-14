function normalizeSpatialBrightness(obj)

% make option to calculate brightness over a larger region, even mean of
% the whole frame, or including neighboring frames as well.

ims = double(obj.images);
medOrig = median(ims(:));
%flt = fspecial('gauss',50,15);
flt = fspecial('gauss',100,30);

for ff = 1:size(ims,4)
    
    % get mean light level in the vicinity of each pixel
    meanBright = conv2(ims(:,:,:,ff),flt,'same');
    
    % ensure pixels equal to zero get kept at 0
    meanBright(meanBright==0) = Inf;
    
    % divide by this brightness
    ims(:,:,:,ff) = ims(:,:,:,ff)./meanBright;
end

medNew = median(ims(:));

obj.images = ims*medOrig/medNew;
