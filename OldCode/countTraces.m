%% 1: Load your data
clear; clc; close all;
addpath Fcns\GetTimes\Fcns
folder='Data\102\CorrectedPlanes\';
load([folder,'allRoisJoint.mat']);
if exist([folder,'FinalC.mat'],'file')%if you already have one, load it in to continue to add to it
    load([folder,'FinalC.mat'],'FinalC')
else
    FinalC=struct('bID',{});
end
bIDList=[brainC.bID];
%% 2: Look at
%help you guess
bID=59; %select the cell you want to analyze. this is its brainID
normalize=1;
binCheck=1;%if 0, then the x axis is time (for checking it initially), switch to 1 so that you can guess bins
inds=find(bID==bIDList);
%inds=inds(subset);
%inds(rmsubset)=[];
bIDs=unique(bIDList);
Ntrials=zeros(1,length(bIDs));
for i=1:length(bIDs)
    inds=find(bIDs(i)==bIDList);
    a={brainC(inds).t};
    [nm,nf]=cellfun(@size,a);
    Ntrials(i)=sum(nm);
end
