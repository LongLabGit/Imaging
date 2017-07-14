clear; clc; close all;
addpath Fcns\OnsetFcns
f='Data\383 PB\';
bird='383 PB';
load([f,'InitialC.mat'],'InitialC')
%% Load and initialize some stuff. 
if ~isdir([f,'MCMC'])
    mkdir([f,'MCMC'])%put in paramOD.xlsx and paramOD_standard
    mkdir([f,'Traces'])%for plots
end
load([f,'ABF_Warped.mat']);%get the time that singing happened so we can ignore other brusts
load([f,'allRois.mat']);%load your traces
%some paramters
bw=.001;%bins for histogram, in seconds (plotting and finding peaks)
burnIn=600;%to trhow out first 600 sweeps
cIDList=[ROIs.cID];%cids 
cells=unique(cIDList);%unique cids
%get bins for histogram for clustering algorithm, which basically just
%finds peaks in histograms
tS=vertcat(Motif.TimeSingingWARP);
Song=[min(tS(:,1)),max(tS(:,2))];
eBins=(Song(1)-.1):bw:(Song(2)+.1);
tBins=eBins(2:end)-bw/2;
%% Run Extracter
close all;
ci=32;%index of cells. look this up if you have multiple ROIs. else is identical
nBursts=2;
cID=cells(ci);
inds=find(cID==cIDList);%find rois with this cID
[time,traces]=visualizeTraces(ROIs,inds,0,0,[],[],0,1);%step 1 and 2

fprintf([num2str(cID),', '])
load([f,'MCMC\' num2str(cID) '.mat'],'Dat') 
%Now plot it
figure(2);clf;hold on;
%get burst times
burstTimes=Dat.burstTimes;
a=cell2mat(burstTimes(burnIn:end));
tSpike=feval(Dat.fc,a);%convert bins to time points
%plot data
plot(tSpike,1:length(tSpike),'.')
xlim([min(Song),max(Song)]+.05*[-1,1]);
%show where song was
line(Song(1)*[1,1],ylim,'color','k')
line(Song(2)*[1,1],ylim,'color','k')

[burstRanges,~]=ginput(nBursts*2);
burstRanges=reshape(burstRanges,nBursts,2);
[Tburst,Sburst,SNR,nB]=extractMCMC(Dat,burnIn,burstRanges);%turn that into spike times
%store everything
InitialC(ci).cID=cID;
InitialC(ci).inds=inds;
InitialC(ci).rmsub=[];
InitialC(ci).time=time;
InitialC(ci).traces=traces;
InitialC(ci).bursts=Tburst;
InitialC(ci).Sburst=Sburst;
InitialC(ci).bSNR=SNR;
InitialC(ci).nB=nB;
% InitialC(ci).paramOD=paramOD;
InitialC(ci).xy=vertcat(ROIs(inds).xy);%this will be filled in at step G
InitialC(ci).creationT=clock;
save([f,'InitialC.mat'],'InitialC')

if size(burstRanges,1)>1
    burstRanges=burstRanges';
end
cols=lines(size(burstRanges,1));
axis tight;
for b=1:size(burstRanges,1)%for each cluster, plot edges
    line(burstRanges(b,1)*[1,1],ylim,'color',cols(b,:))
    line(burstRanges(b,2)*[1,1],ylim,'color',cols(b,:))
end
savefig(2,[f,'Traces\',num2str(cID) 'mcmc_out.fig']);%save the figure

fprintf('SAVED')