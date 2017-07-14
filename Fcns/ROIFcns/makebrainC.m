function brainC=makebrainC(folder,planeIDs,plane,cellN,remake)

brainC=struct([]);
for pi=1:length(planeIDs)
    p=planeIDs{pi};
    cs=sort(cellN(strcmp(plane,p)));
    f=[folder,p,'\'];
    %you can use this code if you arent sure that all cell is the latest
    %edition
    if remake
        load([f,'ROIs\ABF_Concat'],'Motif')%load in Motif
        Cell=ExtractF2(f,Motif,0);%extract the signal from the concat
    else
        load([f,'ROIs\CellF.mat'],'Cell');
    end
    if isempty(cs)
        disp(p);
    end
    C=Cell(cs);
    for i=1:length(C);
        C(i).joined=0;
        C(i).bID=i+length(brainC);
    end
    brainC=[brainC,C];
    clear Cell;%make sure that we arent using the old one
%     fprintf([num2str(pi),','])
end
disp(['Total Rois:' num2str(length(brainC))])
% save([folder,'\allRois.mat'],'brainC')