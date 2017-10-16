function Cell=ExtractF_notconcat(folder, Motif)
% open info
rois=ReadImageJROI([folder,'ROIs\RoiSet.zip']);
rois=cell2mat(rois);
roiNames={rois(:).strName};
disp(['Extracting ' folder ', ' num2str(length(Motif)) ' motifs'])
Cell=struct('f',{},'name',{},'cellN',[],'patch',[],'inds',[]);
if ~isfield(Motif,'imagingP')
    disp('using standard imaging period of 34 milliseconds')
end
for m=1:length(Motif)
    fn=Motif(m).name;%name of motif
    moShift=Motif(m).hor_vert(2);%horizatonal and vertical alignment of the motion corrected aligned tiff to the original tiff
    %this is useful for knowing the effect of line scan time 
    totalLines=Motif(m).totalLines;%total lines in original tiff. use this to calculated effect of location. 
    if isfield(Motif,'imagingP')
        imagingP=Motif(m).imagingP*Motif(m).warpFactor;
    else
        imagingP=.034*Motif(m).warpFactor;
    end
    Y = tiff_reader_new([folder, '5-FinalMotifs\' fn],0,0);%turn this into Tiff
    %now create the pixels struct corresponding to the frame number
    nF=size(Y,3);
    for c=1:length(roiNames)%for every cell
        %get out the coordinates
        Cell(c).f=folder;
        Cell(c).name=roiNames{c};
        Cell(c).cellN=c;
        Cell(c).patch=rois(c).mnCoordinates;
        [a,b]=find(poly2mask(Cell(c).patch(:,1), Cell(c).patch(:,2), size(Y,1), size(Y,2)));
        if ~isempty(a)
            inds=sub2ind([size(Y,1),size(Y,2)],a,b);
            Cell(c).inds=inds;
            sigPix=zeros(length(inds),nF);
            %convert this to reshape
            for f=1:nF
                temp=Y(:,:,f);
                sigPix(:,f)=temp(inds);
            end
            trace=mean(sigPix);%mean of each point
            %get time offset
            curLoc=mean(Cell(c).patch(:,2));%FIGURE THIS OUT
            origLoc=moShift+curLoc;%original location is mean of y axis + pixel loss due to mot corr etc.  
            shiftPerc=((origLoc-totalLines/2)+1)/totalLines;%what percent of imaging period do i shift it by
            locationOffset=shiftPerc*imagingP;%multiple fraction
            
            Cell(c).locationOffset(m)=locationOffset;%THIS DOES NOT INCLUDE HORIZONTAL, that is less than 100 micros for now
            Cell(c).bin(m,:)=trace;
            Cell(c).t(m,:)=Motif(m).frameTimesWARP+locationOffset;
            Cell(c).t_old(m,:)=Motif(m).frameTimesWARP;
        else
            disp('ROI incorrect location')
        end
    end
    fprintf([num2str(m) ', '])
end
disp('Done')
save([folder, 'ROIs\CellF.mat'],'Cell');