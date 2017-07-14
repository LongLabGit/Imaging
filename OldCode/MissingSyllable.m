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
b='192';
load(['Data\' b '\Planes\allROIs.mat']);%go here for planes
load(['Data\' b '\Planes\burstInfo.mat']);
load(['Data\' b '\Planes\InitialC2.mat']);%go here for cell ID to go into ROIS
load(['Data\' b '\All\ABF_Final.mat'],'Motif');%go here to find missing motifs
%% Get Motifs by Plane
planes=unique({ROIs.f});
for p=1:length(planes)
    M2=load([planes{p},'ROIs\ABF_Concat.mat']);
    motifsInPlane{p}=strcat(strtok({M2.Motif.name},'.'),'.wav');
end
%% get ID of Motifs
motifs=strcat(strtok({Motif.name},'.'),'.wav');
miss=logical(cellfun(@length,{Motif.syllMiss}));
aMots=motifs(miss)';
bMots=motifs(~miss)';
%% Get ROIs in the first half
cID=[burstInfo.cID];
FCid=[InitialC.cID];
cIDset=[];
ROIset={};
indSet=[];
for i=1:length(burstInfo)
    if any((burstInfo(i).t>.7))%first half
        ind=FCid==burstInfo(i).cID;
        cIDset=[cIDset,burstInfo(i).cID];
        ROIset=[ROIset,{InitialC(ind).inds}];
        indSet=[indSet,find(ind)];
    end
end

%% for each cell
close all;
for i=1:length(ROIset)
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
%     savefig(1,['Data\192\FirstSyllable\Traces_' num2str(cIDset(i)) '.fig'])
end
