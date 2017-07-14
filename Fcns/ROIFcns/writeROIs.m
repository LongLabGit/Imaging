function writeROIs(F,c,cROIs,dat)
w=40;
Zplanes=strcat(F,dat(2:end,1),'\');
MPP=[dat{2:end,5}];
for r=1:length(cROIs)
    f=cROIs(r).f;
    tName=['Data\ROIs\' f(6:8) ,'\',num2str(c) '.tif'];
    %load the average image
    img=tiff_reader_new([f,'6-Full\Avg.tif']);
    img3=repmat(img,1,1,3)/max(img(:));%turn it into rgb by replicating channels and normalizing
    [x,y]=size(img);
    
    %load the ROI
    roiSet=ReadImageJROI([f,'\ROIs\RoiSet.zip']);
    roi=roiSet{cROIs(r).cellN};
    roiLoc=round(mean(roi.mnCoordinates));%if you only want the center

    BW = poly2mask(roiLoc(:,1), roiLoc(:,2),x,y);
    roiX=repmat(roiLoc(:,2)+1,3,1);%make the roi into 3 channels in x
    roiY=repmat(roiLoc(:,1)+1,3,1);%make the roi into 3 channels in y
    %for each location in roiLoc, get first second and third channel
    one=[ones(size(roiLoc,1),1);2*ones(size(roiLoc,1),1);3*ones(size(roiLoc,1),1)];
    lInd=sub2ind(size(img3),roiX,roiY,one);
    sub=img3(lInd);
    cFilt=repmat([1 0 0],size(roiLoc,1),1);cFilt=cFilt(:);
    img3(lInd)=(1-.4)*sub+.4*cFilt;
    
    img4=zeros(2*w+1,2*w+1,3);
    indX=max((roiLoc(2)-w),1):min((roiLoc(2)+w),size(img3,1));
    indY=max((roiLoc(1)-w),1):min((roiLoc(1)+w),size(img3,2));
    missX=-min(roiLoc(2)-w-1,0);
    missY=-min(roiLoc(1)-w-1,0);
    img4((1:length(indX))+missX,(1:length(indY))+missY,:)=img3(indX,indY,:);
    
    mpp=MPP(strcmp(Zplanes,f));
    if mpp~=1
        sub=imresize(img4, mpp,'nearest');%simplest
        img4=zeros(2*w+1,2*w+1,3);
        [a,b,~]=size(sub);
        if mpp<1
            img4(floor((2*w-a)/2)+(1:a),floor((2*w-b)/2)+(1:b),:)=sub;
        else
            img4=sub((0:2*w)+round((a-2*w)/2),(0:2*w)+round((a-2*w)/2),:);
        end
        tName
        mpp
    end
    if r==1
        imwrite(img4,tName,'TIF','compression','none')
    else
        imwrite(img4,tName,'TIF','WriteMode','append','compression','none')
    end
end
    %get the offset