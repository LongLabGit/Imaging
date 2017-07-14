function ROIviewer(folder,maxSTD,frameRate)
%This function will created a tiff, where each image in it corresponds to a
%cell. on the left will be the averaged image, with the cell highlighted.
%on the right will be the trace
[ROItrace,ROInames]=xlsread([folder,'ROIs\ROIs.xlsx']);

rois=ReadImageJROI([folder,'ROIs\RoiSet.zip']);%need to make a way to find the correct ROI
rois=cell2mat(rois);
roiCells={rois(:).strName};
for i=1:length(ROInames)
    %get out the coordinates
    m=strcmp(ROInames(i),roiCells);
    if sum(m)==1
        x=rois(m).mnCoordinates(:,1);
        y=rois(m).mnCoordinates(:,2);
        %create a grid
        [X,Y] = meshgrid(min(x):max(x),min(y):max(y));
        x1=X(:);y1=Y(:);
        IN=inpolygon(x1,y1,x,y);
        pixels(i).x=x1(IN);
        pixels(i).y=y1(IN);
    else
        disp(['Missing cell named ',ROInames{i}])
    end
end
AVGimgTemp=imread([folder,'7-Full\AVG.tif']);
cutoff=median(median(AVGimgTemp))+std2(AVGimgTemp)*maxSTD;
AVGimgTemp(AVGimgTemp>cutoff)=cutoff;
AVGimg=real2rgb(double(AVGimgTemp),gray(256),double([min(min(AVGimgTemp)),max(max(AVGimgTemp))]));
colors=jet(length(ROInames));
aviName=[folder,'ROIs\CalciumTraces.avi'];
vW=vision.VideoFileWriter(aviName);
vW.FrameRate=frameRate;
for i=1:length(ROInames)
    frame=AVGimg;
    x=pixels(i).x;
    y=pixels(i).y;
    for p=1:length(y)
        frame(y(p),x(p),:)=colors(i,:)';
    end
    plot(ROItrace(:,i));
    axis tight
    legend(ROInames(i))
    f=getframe();
    [calcium,~]=frame2im(f);
    calcium=double(calcium/255);
    %might have issues with reshaped 3D image
    %reshape X 
    [cX,cY,~]=size(calcium);
    [fX,fY,~]=size(frame);
    newfX=linspace(1,cX,fX);
    calcium=interp1(1:cX,calcium,newfX);
    %reshape Y
    newfY=linspace(1,cY,fY);
    calcium=interp1(1:cY,permute(calcium,[2,1,3]),newfY);
    a=cat(2,frame,permute(calcium,[2,1,3]));
    step(vW,a);
end
close all;
release(vW);