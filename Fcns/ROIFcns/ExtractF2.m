function Cell=ExtractF2(folder,Motif,plotit)
% open info
rois=ReadImageJROI([folder,'ROIs\RoiSet.zip']);
Y = tiff_reader_new([folder,'6-Full\Concatenated.tif'],0,0);%turn this into Tiff
rois=cell2mat(rois);
roiNames={rois(:).strName};
%now create the pixels struct corresponding to the frame number
nF=size(Y,3);
mxI=max([Motif(:).numI]);
indsI=[0,cumsum([Motif(:).numI])];
Plane=zeros(size(Y,1),size(Y,2));%get background, defined as the darkest possible
orig=mean(Y,3);%get background, defined as the darkest possible
for c=1:length(roiNames)
    %get out the coordinates
    Cell(c).f=folder;
    Cell(c).name=roiNames{c};
    Cell(c).cellN=c;
    Cell(c).patch=rois(c).mnCoordinates;
    %use the command patch(Cell(i).patch(:,1),Cell(i).patch(:,2),'c','FaceAlpha',.3)
    BW = poly2mask(Cell(c).patch(:,1), Cell(c).patch(:,2), size(Y,1), size(Y,2));
    sigBin=repmat(BW,[1,1,size(Y,3)]).*Y;
    [a,b]=find(BW);
    inds=sub2ind([size(Y,1),size(Y,2)],a,b);
    sigPix=zeros(length(inds),nF);
    %convert this to reshape
    for f=1:nF
        temp=Y(:,:,f);
        sigPix(:,f)=temp(inds);
    end
    Cell(c).inds=inds;
    bin=mean(sigPix);%mean of each point
    [W,H,D] = nnmf(sigPix,1);
    %H2 = H*norm(W)/sqrt(32);
%     Cell(c).W=W;
    a=bin/H;
    mask=H*a;%use this one
	mask=W'*sigPix/sum(W);%dont use this one
    Plane(inds)=W;
    %plot it
    %now convert to useable matrices
    Cell(c).t=nan(length(Motif),mxI);
    Cell(c).bin=nan(length(Motif),mxI);
    for m=1:length(Motif)
        Cell(c).t(m,1:Motif(m).numI)=Motif(m).frameTimesWARP;
        %Cell(c).mask(m,1:Motif(m).numI)=mask(indsI(m)+1:indsI(m+1));
        Cell(c).bin(m,1:Motif(m).numI)=bin(indsI(m)+1:indsI(m+1));
    end
end
if plotit
    figure(2)
    dots=Plane(Plane>0);
    maxlvl=mean(dots)+2*std(dots);
    Plane2=Plane;
    Plane2(Plane>maxlvl)=maxlvl;
    imagesc(Plane2);axis equal;axis tight;
end
save([folder,'CellF.mat'],'Cell');