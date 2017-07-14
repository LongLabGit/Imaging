function Cell=getCells(folder,plane,z,Cell)

%times for each frame
%I should have saved mTimes. since i didnt, I'll have to recreate it
f=[folder,plane,'\'];
load([f,'ABF_Output.mat'])
t=[];
for i=1:length(Motif)
    t=[t;Motif(i).frameTimesWARP];
end
d=diff(t);d(d<0)=[];
binSize=mean(d);%this will make it the average of your bins, similar to what you imaged at, but account for warping
xloc=sort(vertcat(Motif(:).frameTimesWARP));
cuts=min(xloc):binSize:(max(xloc)+binSize);
mTimes=(cuts(1:end-2)+cuts(2:end-1))/2;%the center of each bin. remove the last one


[~,~,ROI]=xlsread([f,'ROIs\ROI.xlsx']);
Names=ROI(2:end,2);
Onset=ROI(2:end,3);
rem=strcmp(Onset,'NA');
Names(rem)=[];
Onset(rem)=[];
rois=ReadImageJROI([f,'ROIs\RoiSet.zip']);%need to make a way to find the correct ROI
rois=cell2mat(rois);
roiNames={rois(:).strName};
%now create the pixels struct corresponding to the frame number
for i=1:length(Names)
    %get out the coordinates
    m=strcmp(Names{i},roiNames);
    if sum(m)==1
        newcells(i).name=Names{i};
        newcells(i).patch=rois(m).mnCoordinates;%use the command patch(Cell(i).patch(:,1),Cell(i).patch(:,2),'c','FaceAlpha',.3)
        newcells(i).tOnset=mTimes(Onset{i});
        newcells(i).plane=plane;
        newcells(i).z=z;
    else
        disp(['cant find cell ',Names{i}])
    end
end

if length(Cell)==1
    Cell=newcells;
else
    Cell=[Cell,newcells];
end