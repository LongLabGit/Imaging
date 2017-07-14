clear; clc; close all;
addpath Fcns\OnsetFcns
f='Data\383 PB\';
bird='383 PB';
%% Load and initialize some stuff. 
if ~isdir([f,'MCMC'])
    mkdir([f,'MCMC'])%put in paramOD.xlsx and paramOD_standard
    mkdir([f,'Traces'])%for plots
end
if exist([f,'InitialC.mat'],'file')
    load([f,'InitialC.mat'],'InitialC')
else
    InitialC=struct('cID',{});%initialize the struct of data.
end
load([f,'ABF_Warped.mat']);%get the time that singing happened so we can ignore other brusts
load([f,'allRois.mat']);%load your traces
%some paramters
bw=.001;%bins for histogram, in seconds (plotting and finding peaks)
burnIn=600;%to trhow out first 600 sweeps
% bird=f(regexp(f,'\d'));%get bird name for excel spreadsheet later
cIDList=[ROIs.cID];%cids 
cells=unique(cIDList);%unique cids
%get bins for histogram for clustering algorithm, which basically just
%finds peaks in histograms
tS=vertcat(Motif.TimeSingingWARP);
Song=[min(tS(:,1)),max(tS(:,2))];
eBins=(Song(1)-.1):bw:(Song(2)+.1);
tBins=eBins(2:end)-bw/2;
%% Run Extracter
for ci=33%1:size(cells,2)
    close all;
    cID=cells(ci);
    fprintf([num2str(ci),', '])
    %standard get traces
    inds=find(cID==cIDList);%find rois with this cID
    [time,traces]=visualizeTraces(ROIs,inds,0,0,[],[],1,1);%step 1 and 2
    savefig(1,[f,'Traces\',num2str(cID) 'traces.fig']);
    %intialize storage for mcmcs
    Dat=struct('fc',[],'burstTimes',[],'trials',[],'mcmc',[],'tau',[],'BinGuess',[],'error',[]);
    nTry=1;%some times it breaks due to intiliation. run it multiple times to try to cheat
    while nTry<10
        try%sometimes it breaks
%             paramOD=load_paramOD(bird,cID);%get paramsters. load from excel if annotated, else stanrdard
%             if isfield(paramOD,'BinGuess')%if you want to initilize it, at the very least jitter it
%                 BinGuess=paramOD.BinGuess;
%                 BinGuess=BinGuess+randn(size(BinGuess));%add a random number
%                 paramOD = rmfield(paramOD,'BinGuess');%its not part of it
%             else
%                 BinGuess=1;
%             end
            BinGuess=5;
            %run the core
            [CaF,tau,offsets,rescalings,period,time2]=reshapeData(time,traces);%reorder
            refT=time2(1,:);refT(isnan(refT))=[];fc=fit((1:length(refT))',refT','poly1');%interpolate timing
            [burstTimes, trials, mcmc,paramOD]=sampleSpikes2_init(CaF,tau,BinGuess,offsets,rescalings,1,[]);%run sampler, plot 1/do not plot 0,
            nTry=Inf;%we did it!
            

            %store data from mcmc
            trials=rmfield(trials,'curves');%remove modelled traces. too much to save
            Dat.fc=fc;
            Dat.burstTimes=burstTimes;
            Dat.trials=trials;
            Dat.mcmc=mcmc;
            Dat.tau=tau;%this is randomized
            Dat.BinGuess=BinGuess;%this is initialized outside of song. 
            Dat.error=0;
            Dat.paramOD=paramOD;
            save([f,'MCMC\' num2str(cID) '.mat'],'Dat') 

            % auto extraction
            try %just so it doesnt hang up if i have a bug here. this is the fast part
                [burstRanges,nB,n]=cluster_tSpike(Dat,burnIn,eBins,.1,bw);%initial estimate of burst Ranges
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
                InitialC(ci).paramOD=paramOD;
                InitialC(ci).xy=vertcat(ROIs(inds).xy);%this will be filled in at step G
                InitialC(ci).creationT=clock;
                save([f,'InitialC.mat'],'InitialC')
                
                %Now plot it
                figure(2);clf;hold on;
                %get burst times
                burstTimes=Dat.burstTimes;
                a=cell2mat(burstTimes(burnIn:end));
                tSpike=feval(Dat.fc,a);%convert bins to time points
                %plot data
                plot(tSpike,1:length(tSpike),'.')
                cols=lines(size(burstRanges,1));
                axis tight;
                for b=1:size(burstRanges,1)%for each cluster, plot edges
                    line(burstRanges(b,1)*[1,1],ylim,'color',cols(b,:))
                    line(burstRanges(b,2)*[1,1],ylim,'color',cols(b,:))
                end
                xlim([min(time(:)),max(time(:))]);
                %show where song was
                line(Song(1)*[1,1],ylim,'color','k')
                line(Song(2)*[1,1],ylim,'color','k')
                savefig(2,[f,'Traces\',num2str(cID) 'mcmc_out.fig']);%save the figure
            end
        catch
            disp('BROKED')
            nTry=nTry+1;%try it a few times
        end
    end
end
disp('Done with all')