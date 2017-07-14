%at this stage we need to clean up FinalC because it was cobbled together
%in a peicemeal fashion
clear;clc;close all;
addpath Fcns\TopoFcns
addpath Fcns\ROIFcns%need readimagej
f='Data\192\Planes\';
load([f,'InitialC.mat'])
save([f,'InitialC_orig.mat'],'InitialC')
load([f,'allROIs.mat'])
[~,~,info]=xlsread([f,'BrainCNotes.xlsx'],'n2');
info=info(2:end,1:4);
allbIDs=[info{:,1}];
%% 1: find doubles. 
cIDs=[InitialC.cID];
[a,b,c]=unique(cIDs);
doubles=cIDs;
doubles(b)=[];
sort(doubles)
%% Find extras
allcID=unique([ROIs.cID]);
setdiff(cIDs,allcID)
%% 2: compare list of bIDs to brainC notes
%These will be mostly cells that were never put in in the first place, but
%some 
labeledBad=logical([info{:,2}]');
badID=allbIDs(labeledBad);
rm=sum(ismember(cIDs,badID));%Find things that he says are bad but he has done
missed=setdiff(allbIDs(~labeledBad),cIDs);%Find things that he said that he did but he didnt

disp(cIDs(ismember(cIDs,badID)))
disp(missed)
%% 3: Check for similar locations and time
[InitialC,Rxyz]=assignLoc(InitialC,ROIs);%should we separate anything?
[prob,UniB,t,xyz]=findOverlap(f,InitialC,ROIs,[25,25,100],1,0);%should we join anything?
% [imgPlaneI,imgCellsI]=makeOverlayIndividual(f,UniB,FinalC,brainC);
save([f,'InitialC.mat'])
%%
%%
%here write down any cells that were affected by your updates
%this is the index in the excel spreadhseet of anything that changed. 
%use it to check against what we find
changedRows=[5,9,29,51,54,55,56];
[pD,cD]=getAlteredRois(f,changedRows);
alteredInds=pc2ind(f,pD,cD,{ROIs.f},[ROIs.cellN]);
[rmIC_Ind,redocID]=ind2cID(alteredInds,[ROIs.cID],InitialC);