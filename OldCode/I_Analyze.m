clear; clc; close all;
addpath Fcns\AnalysisFcns
set(0,'DefaultFigureWindowStyle','docked')
% dont use tsing use gte times instead!!!
% ts(1,:)=[-0.215    0.5659];
% ts(2,:)=[-.162 .6436];
% ts(3,:)=[0 .6478];
% ts(4,:)=[-.2475 .247];
% ts(5,:)=[0 .956];
%
f='Data\102\';locAll='All2\';locSub='CorrectedPlanes\';%tSing=ts(1,:);
% f='Data\105\';locAll='All\';locSub='Planes\';tSing=ts(2,:);
% f='Data\131\';locAll='All\old\';locSub='All\';tSing=ts(3,:);
% f='Data\193\';locAll='All\';locSub='';tSing=ts(4,:);
% f='Data\192\';locAll='All\';locSub='Planes\';tSing=ts(5,:);
% load the data
load([f,locSub,'burstInfo.mat'])
load(['Gabo\Data\' f(end-3:end-1) 'GTEs.mat'],'nms','gtes','newG','allG','inds');
% load([f,locSub,'InitialC.mat'],'InitialC')
% load([f,locSub,'allROIs.mat'])


nms=nms(inds);
allG=allG(inds);
gtes=sort(unique([gtes,reshape(newG,[1,length(newG)])]));
[wav,t,ts,S,T,F]=genAudio(f,locAll,nms{1});%get the best wav file
%%
% specOverlay
% Make Plots
[bT,bS]=plotDists(FinalC,wav,t,ts,.02);%distributions
% makeBooklet([f,locSub],FinalC,ROIs,t)
plotSteps(FinalC,0,[1,2])
plotSteps3D(FinalC,0)
% Scientific Questions
%do [-Inf,Inf] instead of ts if you want all the data. 
dLdT(burstInfo,[min(gtes),max(gtes)])%correlation between distance in time and distance in space%102: -.23,.57

%% Make Topo
for i=1:length(FinalC)
    FinalC(i).burstT=nanmean(FinalC(i).bursts,2)-.02;
    FinalC(i).burstS=nanmean(FinalC(i).Sburst,2);
end
FinalC = rmfield(FinalC, 'cID');
FinalC = rmfield(FinalC, {'inds', 'rmsub', 'time', 'traces', 'Sburst', 'Tau', 'tSpike', 'paramOD','creationT','bursts'});
FinalC = orderfields(FinalC,[2 3 1]);
Topo=FinalC;