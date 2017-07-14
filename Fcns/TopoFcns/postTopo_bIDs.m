clear;clc;close all;
f='Data\102\CorrectedPlanes\';
[~,~,info]=xlsread([f,'BrainCNotes.xlsx'],'bIDNotes');
info=info(2:end,1:4);
load([f,'allRoisJoint2.mat']);%the correct brainC
load([f,'FinalC2.mat'])%the cells that we are keeping
%% allROIsJoint2 
bIDs=[info{:,1}];
labeledBad=strcmp(info(:,2),'n')|strcmp(info(:,2),'to remove');
badID=[info{labeledBad,1}];
goodID=[info{~labeledBad,1}];
rm2=ismember(bIDs,badID);
%
allBrainC=[brainC.bID];
bIDList=unique(allBrainC)';
remove=zeros(size(bIDList));
for c=1:length(bIDList)
    inds=find(allBrainC==bIDList(c));
    rm=sum(ismember(bIDList(c),badID));
    kp=sum(ismember(inds,goodID));
    remove(c)=double(rm&&~kp);
end
%% allRoisJoint3
% this is after looking for cells that are the same
clear;close all;
f='Data\102\CorrectedPlanes\';
load([f,'FinalC_AutoUpdate.mat'])
load([f,'allRoisJoint3.mat'])
%anything that was impacted by noting that the cell should have been joined
removebIDs=[1,3,8,13,15,17,22,27,37,48,52,53,59,86,96,125,131,134,...
    148,164,168,170,171,188,199,247,267,273,340,343,354,379,389];
%bIDs to redo, remove bIDs are compressed into that
redobIDs=[1,3,8,13,17,22,48,125,148,171,354,379];%based on looking it up if it isnt the first one
%These did NOT have to be the same as in brainC before,. but they are which
%is nice
noLongerE=setdiff(removebIDs,redobIDs);%the ones lost
bIDs=unique([brainC.bID]);
intersect(noLongerE,bIDs)%is there something that we are trying to remove from FinalC_Upodate still in brainC?
bIDFCU=[FinalC_Update.bID];
setdiff(removebIDs,bIDFCU)%is there something removebIDs that isnt in FinalC_update 
setdiff(redobIDs,bIDs)%is there something in redobIDs that isnt in brainC

rm=ismember(bIDFCU,removebIDs);
FinalC_Update(rm)=[];
save([f,'FinalC_AutoUpdate2.mat'],'FinalC_Update')
%%
clear;close all;
f='Data\102\CorrectedPlanes\';
load([f,'FinalC_AutoUpdate2.mat'])
load([f,'allRoisJoint4.mat'])
%% This is after topo a third time, with 30,30,200
%anything that was impacted by noting that the cell should have been joined
removebIDs=[148,323,154,262,344,598,98,354,596];
%bIDs to redo, remove bIDs are compressed into that
redobIDs=[148,154,354];%based on looking it up if it isnt the first one
%These did NOT have to be the same as in brainC before,. but they are which
%is nice
noLongerE=setdiff(removebIDs,redobIDs);%the ones lost
bIDs=unique([brainC.bID]);
%is there something that we are trying to remove from FinalC_Upodate still in brainC?
%The only way that this is possible is if it is an roi that split the cell
intersect(noLongerE,bIDs)
bIDFCU=[FinalC_Update.bID];
setdiff(removebIDs,bIDFCU)%is there something removebIDs that isnt in FinalC_update 
setdiff(redobIDs,bIDs)%is there something in redobIDs that isnt in brainC
rm=ismember(bIDFCU,removebIDs);
FinalC_Update(rm)=[];
save([f,'FinalC_AutoUpdate3.mat'],'FinalC_Update')