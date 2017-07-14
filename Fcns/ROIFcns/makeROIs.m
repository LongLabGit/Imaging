function ROIs=makeROIs(folder,plane,cellN)

ROIs=struct([]);
planeIDs=unique(plane);
for pi=1:length(planeIDs)
    p=planeIDs{pi};
    cs=sort(cellN(strcmp(plane,p)));
    f=[folder,p,'\']; %standard
    
    load([f,'ROIs\CellF.mat'],'Cell');
    C=Cell(cs);
    for i=1:length(C);
        C(i).joined=0;
        C(i).cID=i+length(ROIs);
        C(i).f=f;
        %location, why not
        [x,y]=strtok(C(i).name,'-');%the name of the cell refers to its center (via imageJ)
        x=str2double(x);
        y=str2double(strtok(y,'-'));%remove the line mark
        C(i).xy=[x,y]+1;%imagej does 0 indexing, add 1
    end
    ROIs=[ROIs,C];
    clear Cell;%make sure that we arent using the old one
end
disp(['Total Rois:' num2str(length(ROIs))])