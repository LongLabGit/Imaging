function Zplanes=makeZStack(f,SCplanes,cells,dat,start,all)
%Here you will 
%get locations in space
UniquePlanes=unique(SCplanes);%same cell planes
Zplanes=dat(2:end,1);
ZXY=cell2mat(dat(2:end,2:4));
MPP=cell2mat(dat(2:end,5));
rm=~ismember(Zplanes,UniquePlanes);%remove anything that doesnt have an ROI in it. 
if ~isempty(setdiff(UniquePlanes,Zplanes))
    disp('You are missing a location for the following planes: ')
    disp(setdiff(UniquePlanes,Zplanes))
end
if ~all%if we only want the ones we had same cells for
    if sum(rm)
        disp('The following planes are extra: ')
        disp(setdiff(Zplanes,UniquePlanes))
        ZXY(rm,:)=[];
        Zplanes(rm,:)=[];
        MPP(rm,:)=[];
    end
end
    
%sort it from dorsal to ventral, so we are going down in the brain
[~,inds]=sort(ZXY(:,1),'descend');
ZXY=ZXY(inds,:);
Zplanes=Zplanes(inds);
MPP=MPP(inds);

morX=ceil(range(ZXY(:,2)));
morX=morX+abs((mod(morX,2)-1));
morY=ceil(range(ZXY(:,3)));
morY=morY+abs((mod(morY,2)-1));
proto=zeros(500*max(MPP)+morX,500*max(MPP)+morY,3);%upped to 600 just in case of MPP being too large
%%
w=.4;%relative level
cN=[1,0,0];%color
for zI=start:length(Zplanes)
    fprintf([num2str(zI/length(Zplanes),2),', '])
    if ~exist([f,Zplanes{zI},'\6-Full\Avg.tif'],'file')
        Y=tiff_reader_new([f,Zplanes{zI},'\6-Full\Concatenated.tif']);
        avg=mean(Y,3);
        imwrite(uint16(avg),[f,Zplanes{zI},'\6-Full\Avg.tif'],'TIF','compression','none')
    else
        avg=tiff_reader_new([f,Zplanes{zI},'\6-Full\Avg.tif']);
    end
    maxPix=median(avg(:))+10*mad(avg(:));%remove really bright noise
    avg(avg>maxPix)=maxPix;
    %
    avg3=repmat(avg,1,1,3)/max(avg(:));%turn it into rgb by replicating channels and normalizing
    A=proto;
    [x,y]=size(avg);
    %Put in cells that were used to make topo from SameCells
    hasROI=strcmp(SCplanes,Zplanes{zI});
    if sum(hasROI)
        jointC=cells(:,hasROI);
        jointC=jointC(jointC>0);%0s where there are no cells overlapping
        roi=ReadImageJROI([f,Zplanes{zI},'\ROIs\RoiSet.zip']);
        roi=[roi{:}];
        for c=1:length(jointC)
            roiLoc=roi(jointC(c)).mnCoordinates;
            BW = poly2mask(roiLoc(:,1), roiLoc(:,2),x,y);
            roiX=repmat(roiLoc(:,2)+1,3,1);%make the roi into 3 channels in x
            roiY=repmat(roiLoc(:,1)+1,3,1);%make the roi into 3 channels in y
            %for each location in roiLoc, get first second and third channel
            one=[ones(size(roiLoc,1),1);2*ones(size(roiLoc,1),1);3*ones(size(roiLoc,1),1)];
            lInd= sub2ind(size(avg3), roiX-1,roiY-1,one);
            sub=avg3(lInd);
            cFilt=repmat(cN,size(roiLoc,1),1);cFilt=cFilt(:);
            avg3(lInd)=(1-w)*sub+w*cFilt;
        end
    end
    %now put in the offset
    off=ZXY(zI,2:3)+abs(min(ZXY(:,2:3)));
    if ~sum(isnan(off))
        %now interpolate avg3 such that it becomes one micron per pixel;
        if MPP(zI)~=1
            avg4=imresize(avg3, MPP(zI),'nearest');%simplest
        else
            avg4=avg3;%dont bother
        end
        [x,y,~]=size(avg4);
        xind=(1:x)+round(off(1));%start with a vector of all indices. add in the offset of the minumum
        yind=(1:y)+round(off(2));
        A(xind,yind,1:3)=avg4;
        if zI == start;
            imwrite(A,[f,'Zstack.tif'],'TIF','compression','none')
        else
            imwrite(A,[f,'Zstack.tif'],'TIF','WriteMode','append','compression','none')
        end
    else
        Zplanes{zI}=NaN;
    end
end
disp('Done')
Zplanes=Zplanes(start:end);
rm=cellfun(@(x) any(isnan(x)),Zplanes);
Zplanes(rm)=[];