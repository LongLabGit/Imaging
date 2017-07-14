function [Yt,Y] = tiff_reader_new(name,varargin)

if nargin > 1
    truncate = varargin{1};
else
    truncate = 0;
end
    
origT_obj = Tiff(name,'r');%create a tiff object, only for reading
i=0;
while ~origT_obj.lastDirectory
    i=i+1;
    origT_obj.setDirectory(i)
end
l=origT_obj.getTag('ImageLength');%rows (first index)
w=origT_obj.getTag('ImageWidth');%columns (second index). i.e. it would be [len,wid]=sizeimage)
Y = zeros(l,w,i);
for t = 1:i
    origT_obj.setDirectory(t);
    Y(:,:,t) = origT_obj.read();%get the image
end

if truncate
    d = d1*d2;
    Yr = reshape(Y,d,T);
    ff = find(Yr==0);
    mask = reshape(full(logical(sparse(ff,1,1,d*T,1))),d1,d2,T);
    se = ones(2,2,2);
    mask2 = imopen(mask,se);
    mask3d = mean(mask2,3);
    BW = im2bw(mask3d,0.05);
    hor_first = find(BW(round(d1/2),:)==0,1,'first');
    hor_last = find(BW(round(d1/2),:)==0,1,'last');
    ver_first = find(BW(:,round(d2/2))==0,1,'first');
    ver_last = find(BW(:,round(d2/2))==0,1,'last');
    Yt = Y(hor_first:hor_last,ver_first:ver_last,:);
else
    Yt = Y;
end

if nargin > 2
    viewer = varargin{2};
else
    viewer = 0;
end

if viewer
    mm = max(Y(:));
    figure;
    set(gcf, 'Units', 'inches')
    set(gcf, 'Position',[1,1, 17, 6])
    for t = 1:3:T
        %subplot(121);imagesc(Y(:,:,t),[nn,mm]); axis equal; axis tight; colorbar
        subplot(121); imagesc(Y(:,:,t),[0,mm]); axis equal; axis tight; colorbar
        title(sprintf('Frame %4i out of total %i',t,T));
        subplot(122); imagesc(Yt(:,:,t),[0,mm]); axis equal; axis tight; colorbar
        title(sprintf('Truncated %i pixels left, %i right, %i top, %i bottom',hor_first-1,...
            d2-hor_last,ver_first,d1-ver_last));
        %subplot(122);imagesc(Ys(:,:,t),[nn2,mm2]); axis equal; axis tight; colorbar
        drawnow;
    end
end