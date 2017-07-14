function averageFrames(is,nFrames)

newIms = zeros(size(is.images));

for ff=nFrames:length(is.images)
    newIms(:,:,:,ff) = mean(is.images(:,:,:,ff-nFrames+1:ff),4);
end

is.images = newIms;
