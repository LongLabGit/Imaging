%% 1: Load your data
clear; clc; close all;
addpath Fcns\OnsetFcns
f='Data\383 PB\';
bird='383 PB';
load([f,'allRois.mat']);
if exist([f,'InitialC.mat'],'file')%if you already have one, load it in to continue to add to it
    load([f,'InitialC.mat'])
else
    InitialC=struct('cID',{});
end
cIDList=[ROIs.cID];
toDo=unique(cIDList);
%% 2: Look at
%help you guess
cID=33; %select the cell you want to analyze. find a list of them by running "unique(cIDList)"
normalize=1;%Normalize the trials
binCheck=0;%if 0, then the x axis is time (for checking it initially), switch to 1 so that you can guess bins
inds=find(cID==cIDList);%find rois with this cID
clear rmsub %step 1 and 2burstTimes
rmsub=[]; %if you awnt to keep all of them
%rmsub(1,1:2)={1,[10,3,9,5,13,7,8]};%prototype {subplane #, [excluded trials]}
[time,traces]=visualizeTraces(ROIs,inds,binCheck,normalize,rmsub,[],1,1);%step 1 and 2
%% 3: Run it and keep on changing parameters
burnIn=200;
BinGuess=1; % Guess the bin for the onset
[CaF,tau,offsets,rescalings,period,time2]=reshapeData(time,traces);
[burstTimes, trials, mcmc,paramOD]=sampleSpikes2_init(CaF,tau,BinGuess,offsets,rescalings,1,[]); %%Plotting 1, no plotting 0
%plot it
PlotMCMC(CaF,trials,mcmc,time2,burnIn)
%% plot onsets
%This section is mostly to make sure that it works well. It also helps save
%time later in that you might not have to click to select the bursts

%automated burst finder
refT=time2(1,:);refT(isnan(refT))=[];
fc=fit((1:length(refT))',refT','poly1');
% Dat.trials=trials;Dat.burstTimes=burstTimes;Dat.fc=fc;
% [bTn,bSn,SNR,n]=extractMCMC(mcmc,200,[.1:.001:.9],.1,.005,[0 1.03]); %[bTn,bSn,SNR,n]=extractMCMC(Dat,burnIn,eBins,sW,bw,Sing)
%

figure(1);clf;hold on;
nBursts=2; % set this manually
spread=.15;%std of burst
a=cell2mat(burstTimes(burnIn:end));

tSpike=feval(fc,a);
plot(tSpike,'k.')
ylim([min(refT-.1),max(refT+.1)])
c=jet(nBursts);
Tburst=[];
Sburst=[];
[x,y] = ginput(nBursts);
for ns=1:nBursts
    idx=abs(tSpike-y(ns))<spread;
    ind=1:length(tSpike);
    plot(ind(idx),tSpike(idx),'.','color',c(ns,:))
    Tburst(ns,1)=median(tSpike(idx));
    Sburst(ns,1)=1.4826*mad(tSpike(idx));
end

disp(Tburst)
disp(Sburst)

%% Save the cell!
indF=length(InitialC)+1;
InitialC(indF).cID=cID;
InitialC(indF).inds=inds;
InitialC(indF).rmsub=rmsub;
InitialC(indF).time=time;
InitialC(indF).traces=traces;
InitialC(indF).bursts=Tburst;
InitialC(indF).Sburst=Sburst;
InitialC(indF).paramOD=paramOD;
InitialC(indF).xy=vertcat(ROIs(inds).xy);%this will be filled in at step G
InitialC(indF).creationT=clock;
save([f,'InitialC.mat'],'InitialC')
