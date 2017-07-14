%% 1: Load your data
clear; close all;%clc;
addpath Fcns\OnsetFcns
f='Data\222\';
I=load([f,'InitialC.mat'],'InitialC');%only for 192
b=fieldnames(I);I=I.(b{1});%parse it out.
burnIn=1500;
spread=.05; %The standard spread
nReps=4; %number of replicates
col=lines(4);%we dont have more than 4 bursts
Onsets=rmfield(I,{'time','traces','bursts','Sburst','paramOD','creationT'});
%% Now lead each cell, extracting data
for c=1:length(I)
    close all;
    fprintf([num2str(c),', ']);
    cID=Onsets(c).cID; %select the cell you want to analyze. this is its brainID
    load([f,'OnsetData\', num2str(cID),'.mat'])
    y=sort(nanmean(I(c).bursts,2));
    Tburst=zeros(length(y),4);Sburst=zeros(length(y),4);
    SNR=zeros(length(y),4);tau=zeros(2,4);
    Bidx=cell(1);
    for r=1:length(Dat)
        if logical(Dat(r).mcmc.tauMoves(1))%make sure we had moves
            burstTimes=Dat(r).burstTimes(burnIn:end);
            [rmDn,ID]=wrongNspikes(burstTimes,1);%will find the sweeps with the wrong burst times, apply 
            tSpike=feval(fc,cell2mat(burstTimes));
            cnoise=Dat(r).trials.cnoise(:,burnIn:end);%this is the denominator. 
            %get burst times
            subplot(2,2,r); hold on;
            plot(ID,tSpike,'k.')%plot all of them
            ylim([fc(0),1.5])
            for ns=1:length(y)
                idx=abs(tSpike-y(ns))<spread&~rmDn';
                y2=median(tSpike(idx));%update your estimate
                idx=abs(tSpike-y2)<spread&~rmDn';%dont allow the ones we need to remove
                %store the index of the bursts
                Bidx{r,ns}=idx;
                
                plot(ID(idx),tSpike(idx),'.','color',col(ns,:))
                
                %save the times
                Tburst(ns,r)=median(tSpike(idx));
                Sburst(ns,r)=1.4826*mad(tSpike(idx));
                
                %calculate SNR
                snr=zeros(size(Dat(r).trials.amp,1),1);
                for t=1:size(Dat(r).trials.amp,1)%for each trial
                    amps=cell2mat(Dat(r).trials.amp(t,burnIn:end));
                    amps=amps(idx);
                    sweep=ID(idx);
                    noise=cnoise(t,sweep);
                    SNR_sweeps=amps./sqrt(noise);
                    snr(t)=mean(SNR_sweeps);%the mean across all sweeps
                end
                SNR(ns,r)=mean(snr);
            end
            title(num2str(r))
            xlim([0,max(ID)])
            %calculate the tau for onset and offset of each trial. same for
            %all bursts, so doesnt depend on all the stuff above
            tau(1:2,r)=mean(vertcat(Dat(r).trials.tau{burnIn:end}),1)*diff(fc(1:2));
        else 
            disp('redo this one, no tau moves')
        end
    end
    suptitle(num2str(cID))
    savefig(1,[f,'AutoFigures\',num2str(cID),'_tSpike.fig'])
    Onsets(c).t=Tburst;
    Onsets(c).s=Sburst;
    Onsets(c).tau=tau;
    Onsets(c).SNR=SNR;
    Onsets(c).rmDn=1;
    Onsets(c).Bidx=Bidx;
end
save([f,'Onsets.mat'],'Onsets');
% ([f,'OnsetsUpdate.mat'],'Onsets')save;%DO NOT, michel worked hard on
% this!
%if you have to redo any onsets, do it to onserts, and then copy manually
%to onsets update. 
disp('Done')
%%
% a=nanmean(vertcat(Onsets.s),2);
% b=nanmean(vertcat(Onsets.SNR),2);
% plot(b,a,'o')