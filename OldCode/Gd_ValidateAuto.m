%at this stage we need to clean up FinalC because it was cobbled together
%in a peicemeal fashion
clear;clc;close all;
addpath Fcns\TopoFcns
addpath Fcns\ROIFcns%need readimagej
f='Data\105\Planes\';
load([f,'FinalC_AutoUpdate.mat'])
load([f,'allROIs.mat'])
[~,~,info]=xlsread([f,'BrainCNotes.xlsx'],'n2');
info=info(2:end,1:4);
allbIDs=[info{:,1}];
%% 1: find doubles. 
cIDs=[FinalC_Update.cID];
[a,b,c]=unique(cIDs);
doubles=cIDs;
doubles(b)=[];
sort(doubles)
%% 2: compare list of bIDs to brainC notes
%These will be mostly cells that were never put in in the first place, but
%some 
labeledBad=logical([info{:,2}]');
badID=allbIDs(labeledBad);
rm=sum(ismember(cIDs,badID));%Find things that he says are bad but he has done
if rm
    find(ismember(cIDs,badID))
else
    disp('nothing to remove')
end
missed=setdiff(allbIDs(~labeledBad),cIDs);%Find things that he said that he did but he didnt
if ~isempty(missed)
    disp('You wanted to do these')
    disp(missed)
else
    disp('You arent missing anything')
end
%% 3: Check for similar locations and time
[FinalC_Update,Rxyz]=assignLoc(FinalC_Update,ROIs);
[prob,UniB,t,xyz]=findOverlap(f,FinalC_Update,ROIs,[25,25,100],1,0);
% [imgPlaneI,imgCellsI]=makeOverlayIndividual(f,UniB,FinalC,brainC);
FinalC=FinalC_Update;
save([f,'FinalC_Complete.mat'],'FinalC')