clear;clc;close all;b='192';
load(['Data\' b '\Planes\allROIs.mat']);%go here for planes
load(['Data\' b '\Planes\burstInfo.mat']);
addpath Fcns\ROIFcns
%%
for c=1:length(burstInfo)
    rois=burstInfo(c).inds;
    R=ROIs(rois);
    for r=1:length(R)
        f=R(r).f;
        tName=['Data\ROIs\' f(6:8) ,'\',num2str(c) '.tif'];
        img=tiff_reader_new([f,'6-Full\Avg.tif']);
        img3=repmat(img,1,1,3)/max(img(:));%turn it into rgb by replicating channels and normalizing
        [x,y]=size(img);
        %load the ROI
        roiSet=ReadImageJROI([f,'\ROIs\RoiSet.zip']);%use michel's new ROIs. easier to get
        roi=roiSet{R(r).cellN};
        roiLoc=roi.mnCoordinates;%if you only want the center
        roiX=repmat(roiLoc(:,2)+1,3,1);%make the roi into 3 channels in x
        roiY=repmat(roiLoc(:,1)+1,3,1);%make the roi into 3 channels in y
        %for each location in roiLoc, get first second and third channel
        one=[ones(size(roiLoc,1),1);2*ones(size(roiLoc,1),1);3*ones(size(roiLoc,1),1)];
        lInd= sub2ind(size(img3), roiX,roiY,one);
        cFilt=repmat([1,0,0],size(roiLoc,1),1);cFilt=cFilt(:);
        img3(lInd)=cFilt;
        pName=strrep(f(17:end),'\','_');
        imwrite(img3,['Data\192\X_RA\ActiveROIs\cID',num2str(burstInfo(c).cID),'_',pName,'roi',num2str(R(r).cellN),'.tif'],'TIF','compression','none')
    end
end