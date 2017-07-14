clear;clc;close all;
set(0,'DefaultFigureWindowStyle','docked')
addpath Fcns\AnalysisFcns
b='192';
load(['Data\' b '\Planes\allROIs.mat']);%go here for planes
load(['Data\' b '\Planes\burstInfo.mat']);
load(['Data\' b '\Planes\InitialC2.mat']);%go here for cell ID to go into ROIS
load(['Data\' b '\All\ABF_Final.mat'],'Motif');%go here to find missing motifs
%% Prep Data 
% What are the burst times that you want to look into?
tLeft=.7;%make -Inf if you dont want to use this
tRight=Inf;%make Inf if you dont want to use this
% Get Motifs by Plane
planes=unique({ROIs.f});
for p=1:length(planes)
    M2=load([planes{p},'ROIs\ABF_Concat.mat']);
    motifsInPlane{p}=strcat(strtok({M2.Motif.name},'.'),'.wav');
end
% get ID of Motifs
motifs=strcat(strtok({Motif.name},'.'),'.wav');
miss=logical(cellfun(@length,{Motif.syllMiss}));
aMots=motifs(miss)';
bMots=motifs(~miss)';
% Get ROIs that burst at a select time
cID=[burstInfo.cID];
FCid=[InitialC.cID];
cIDset=[];%cell ID
ROIset={};%index of ROI
ICSet=[];%index of InitialC
for i=1:length(burstInfo)
    if any((burstInfo(i).t>tLeft)&(burstInfo(i).t<tRight))
        ind=FCid==burstInfo(i).cID;
        cIDset=[cIDset,burstInfo(i).cID];
        ROIset=[ROIset,{InitialC(ind).inds}];
        ICSet=[ICSet,find(ind)];
    end
end

%% for each cell
cID_index=30;%index out of the options that burst in your time
allMots=0;%for a given cell, do you want to load all at once, or do you want to see a specific motif #?
onlyA=1;%to only look at the motifs that are missing data

% if allMots is 0:
%which motif do you want? set it to a single number, [] to see all, or a
%vector to step through them
indMots=[];
spec=0;%to see the spectrogram of a single one

%Extract your data
figure(cID_index);clf;
rois=ROIset{cID_index};%if you only want to see a specific roi you can modify it here
rmSub=InitialC(ICSet(cID_index)).rmsub;%make a dotted color line
pln={ROIs(rois).f}';%get the planes 
cut=InitialC(ICSet(cID_index)).cut;%look at a subset

mCell={};
for p=1:length(pln)
    currP=pln{p};%what plane was the ROI in?
    indM=strcmp(planes,currP);%find its index 
    mCell{p}=motifsInPlane{indM}';%get all the motifs that were recorded during that plane
end
tCell={ROIs(rois).t};%time
sCell={ROIs(rois).bin};%signal


if ~allMots%if we are doing one at a time
    if isempty(indMots)%if actually we want all of the motifs, just one at a time
        if ~onlyA
            maxN=length(vertcat(mCell{:}));
        else
            maxN=sum(ismember(aMots,vertcat(mCell{:})));
        end
        indMots=1:maxN;%to step through them
    end
    for n=indMots%go through each one
        h(1)=subplot(2,1,1);cla;
        [allID,m]=visualizeTracesAlternate(tCell,sCell,mCell,cut,rmSub,aMots,bMots,onlyA,n);
        title([m ', m #', num2str(n)]);
        h(2)=subplot(2,1,2);cla;
        visualizeMotifs(Motif,mCell,rmSub,aMots,onlyA,spec,n)
        linkaxes(h,'x');
        drawnow;
        %if we asked for more than just one, pause here before advancing
        if length(indMots)>1
            pause;
        end
    end
else
    h(1)=subplot(2,1,1);cla;hold on
    allID=visualizeTracesAlternate(tCell,sCell,mCell,cut,rmSub,aMots,bMots,onlyA,[]);
    title(['All Motifs, cID: ', num2str(cIDset(cID_index))])
    h(2)=subplot(2,1,2);cla;hold on
    visualizeMotifs(Motif,mCell,rmSub,aMots,onlyA,0,[])
    linkaxes(h,'x');
end