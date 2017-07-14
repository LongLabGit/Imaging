%% 1: Load your data
clear; clc; close all;
addpath Fcns\OnsetFcns
f='Data\316\';
load([f,'allRois.mat']);
load([f,'InitialC.mat'],'InitialC');
if ~isdir([f,'AutoFigures\']);
    mkdir([f,'AutoFigures\']);
    mkdir([f,'OnsetData\']);
end
%% Run the Sampler to find your Posterior.
indices=1:length(InitialC);%131
for c=1:length(InitialC)
    close all;
    cID=InitialC(c).cID; %select the cell you want to analyze. this is its brainID
    disp(['cell #',num2str(c),', cID #',num2str(cID)])

    %Plot the Traces
    [time,traces]=visualizeTraces(ROIs,InitialC(c).inds,0,0,InitialC(c).rmsub,InitialC(c).cut,1);
    title(num2str(cID))
    drawnow;
    savefig(1,[f,'AutoFigures\',num2str(cID),'_Traces.fig'])
    
    %prep the data
    [CaF,tau,offsets,rescalings,period,time2]=reshapeData(time,traces);
    refT=time2(1,:);refT(isnan(refT))=[];
    fc=fit((1:length(refT))',refT','poly1');%this will convert bins into time
    y=nanmean(InitialC(c).bursts,2)';
    paramOD=InitialC(c).paramOD;
    paramOD.nsweeps=4000;%make sure we do 4k instead of the initial test of 1k
    paramOD.tau_max=max(paramOD.tau_max,[10,25]);
    
    %run it 4 times
    for i=1:4
        %randomize initial parameters: tau and bin guess
        BinGuess=(y-refT(1))/period(1)+(rand-.5)*6;
        BinGuess=min(max(BinGuess,1),size(time2,2));
        [~,tau,~,~,~,~]=reshapeData(time,traces);%randomize tau initialization

        %run sampler
        [burstTimes, trials, mcmc,paramOD]  = sampleSpikes2_init(CaF,tau,BinGuess,offsets,rescalings,0,paramOD);
        curves=trials.curves;
        trials=rmfield(trials,'curves');%remove modelled traces
        Dat(i).burstTimes=burstTimes;
        Dat(i).trials=trials;
        Dat(i).mcmc=mcmc;
        Dat(i).tau=tau;
        Dat(i).BinGuess=BinGuess;
    end
    %store a subset of plotMCMC because too much data to save all curves,
    %we can recreate it later
    trials.curves=curves;
    PlotMCMC(CaF,trials,mcmc,time2,1500)%plot the last one
    suptitle(num2str(cID))
    drawnow;
    savefig(1,[f,'AutoFigures\',num2str(cID),'_plotMCMC.fig'])
    
    % Save the cell
    save([f,'OnsetData\', num2str(cID)],'Dat','refT','fc')
end