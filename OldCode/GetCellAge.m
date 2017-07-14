clear;clc;
set(0,'DefaultFigureWindowStyle','docked')
addpath Fcns\AnalysisFcns
F={'Data\102\CorrectedPlanes\',...
    'Data\105\Planes\',...
    'Data\131\All\',...
    'Data\193\',...
    'Data\192\Planes\'};
indB=5;
b=F{indB};
load([b 'allROIs.mat']);%go here for planes
load([ b 'burstInfo.mat']);
load([ b 'InitialC2.mat']);%go here for cell ID to go into ROIS
if strcmp(b,'Data\192\Planes\')
    InitialC(59).rmsub(4:end,:)=[];
elseif strcmp(b,'Data\102\CorrectedPlanes\')
    InitialC(66).rmsub(1,:)=[];
elseif strcmp(b,'Data\105\Planes\')
    InitialC(7).rmsub(2,:)=[];
elseif strcmp(b,'Data\131\All\')
    InitialC(2).rmsub(3:end,:)=[];
    InitialC(7).rmsub(2:end,:)=[];
    InitialC(12).rmsub(end,:)=[];
elseif strcmp(b,'Data\193\')
    InitialC(19).rmsub(end,:)=[];
end
%% get planes
planes=unique({ROIs.f});
for p=1:length(planes)
    M2=load([planes{p},'ROIs\ABF_Concat.mat']);
    motifsInPlane{p}=strcat(strtok({M2.Motif.name},'.'),'.wav');
%     for m=1:length(motifs)
%         date(m)=datenum(motifsInPlane{m}(1:5),'mm_dd');
%     end
end
%% get names
cIDset=[burstInfo.cID];
ROIset={burstInfo.inds};
for i=1:length(burstInfo)
    ICSet(i)=find([InitialC.cID]==burstInfo(i).cID);
end
for c=1:length(cIDset)
    rois=ROIset{c};%if you only want to see a specific roi you can modify it here
    rmsub=InitialC(ICSet(c)).rmsub;%make a dotted color line
    pln={ROIs(rois).f}';%get the planes 
    mCell={};
    for p=1:length(pln)
        currP=pln{p};%what plane was the ROI in?
        indM=strcmp(planes,currP);%find its index 
        mCell{p}=motifsInPlane{indM}';%get all the motifs that were recorded during that plane
    end
    if ~isempty(rmsub)
        for i=1:size(rmsub,1)
            mCell{rmsub{i,1}}(rmsub{i,2})=[];
        end
    end
    motifs=vertcat(mCell{:});
    date=zeros(1,length(motifs));
    for m=1:length(motifs)
        date(m)=datenum(motifs{m}(1:5),'mm_dd');
    end
    D{c}=unique(date);
end
%%
figure(1);clf;hold on;
d1=min([D{:}]);
cols=lines(length(D));
for c=1:length(D)
    ds=(D{c}-d1);
    plot(ds,c*ones(size(ds)),'o','color',cols(c,:))
    ds=[ds(1),ds(end)];
    plot(ds,c*ones(size(ds)),'color',cols(c,:))
end
xlabel('days imaged')
ylabel('cell number')
axis tight;
load L.mat
L{indB}=D;
save L.mat L;
%%
clear;figure(2);
load L
L=[L{:}];
d=cellfun(@range,L);
histogram(d,(1:1:max(d))-.5)
xlabel('days confirmed to be consistent')
ylabel('number of cells')
title('stability')
axis  tight