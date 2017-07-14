%Here we look at specific traces from a single cell 
%Forwards model Motif--> ROI -->Traces 
%Genrate a list of planes
%For each plane, get a list of motifs that were sung during that plane

%Backwards Model: Cell -->Motif-->Traces
%Find the rois for that cell
%get the planes for those rois
%find the motifs sung during those planes
%cellF
%%
clear;clc;close all;
set(0,'DefaultFigureWindowStyle','docked')
addpath Fcns\AnalysisFcns
b='193';
load(['Data\' b '\allROIs.mat']);
load(['Data\' b '\burstInfo.mat']);
load(['Data\' b '\InitialC2.mat']);
%% Get Motifs by Plane
planes=unique({ROIs.f});
for p=1:length(planes)
    load([planes{p},'ROIs\ABF_Concat.mat'])
    motifsInPlane{p}=strcat(strtok({Motif.name},'.'),'.wav');
end
%% get ID of Motifs
[~,IDs]=xlsread('Data\193\All\motifWavs\List.xlsx');
aMots=IDs(strcmp(IDs(:,2),'a'),1);
bMots=IDs(strcmp(IDs(:,2),'b'),1);
%% Get ROIs in the first half
cID=[burstInfo.cID];
FCid=[InitialC.cID];
cIDset=[];
ROIset={};
indSet=[];
for i=1:length(burstInfo)
    if any((burstInfo(i).t<-.1))%first half
        ind=FCid==burstInfo(i).cID;
        cIDset=[cIDset,burstInfo(i).cID];
        ROIset=[ROIset,{InitialC(ind).inds}];
        indSet=[indSet,find(ind)];
    end
end

%% for each cell
close all;
for i=1:length(cIDset)%[3,5,8,14,21]
    figure(i);clf;hold on;
    rois=ROIset{i};
    rmSub=InitialC(indSet(i)).rmsub;%make a dotted color line
    pln={ROIs(rois).f}';
    cut=InitialC(indSet(i)).cut;%make a dotted color line
    mCell={};
    for p=1:length(pln)
        currP=pln{p};%what plane was the ROI in?
        indM=strcmp(planes,currP);%find its index 
        mCell{p}=motifsInPlane{indM}';%get all the motifs that were recorded during that plane
    end
    tCell={ROIs(rois).t};%time
    sCell={ROIs(rois).bin};%signal
    allID=visualizeTracesAlternate(tCell,sCell,mCell,cut,rmSub,aMots,bMots);
    title(cIDset(i))
%     savefig(1,['Data\193\FirstSyllable\Traces_' num2str(cIDset(i)) '.fig'])
end
