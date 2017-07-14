function Cell=ExtractF_notconcat(folder, Motif)
% open info
rois=ReadImageJROI([folder,'ROIs\RoiSet.zip']);
rois=cell2mat(rois);
roiNames={rois(:).strName};
disp(['Extracting ' folder ', ' num2str(length(Motif)) ' motifs'])
for m=1:length(Motif)
    fn=Motif(m).name;
    Y = tiff_reader_new([folder, '5-FinalMotifs\' fn],0,0);%turn this into Tiff
    %now create the pixels struct corresponding to the frame number
    nF=size(Y,3);
    for c=1:length(roiNames)
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
            Cell(c).bin(m,:)=trace;
            Cell(c).t(m,:)=Motif(m).frameTimesWARP;
        else
            disp('ROI incorrect location')
        end
    end
    fprintf([num2str(m) ', '])
end
disp('Done')
save([folder, 'ROIs\CellF.mat'],'Cell');