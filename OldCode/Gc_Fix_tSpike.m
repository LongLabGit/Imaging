clear; clc; close all;
addpath Fcns\OnsetFcns
f='Data\222\';
if exist([f,'OnsetsUpdate.mat'],'file')
    load([f,'OnsetsUpdate.mat'],'Onsets')
else
    load([f,'Onsets.mat'],'Onsets')
end
set(0,'DefaultFigureWindowStyle','docked')
burnIn=1500;
%% Select your cell and define the burst locations
c=21;%Field
nBursts=2;%Change this
spread=.08; %Change the spread (it's plus or minus this value)
useDn=0;%this is if you dont want to use the removal thing. 1 is standard. use it. 0 is dont use it

cID=Onsets(c).cID;
dat=[f,'OnsetData\', num2str(cID),'.mat'];
load(dat)
figure(1);clf;
col=lines(nBursts);
burstTimes=Dat(1).burstTimes(burnIn:end);
a=feval(fc,cell2mat(burstTimes));
plot(a,'k.')%plot all of them
ylim([-1,1.5])
[~,y] = ginput(nBursts);
y=sort(y);
%
Tburst=zeros(length(y),4);
Sburst=zeros(length(y),4);
SNR=zeros(length(y),4);
tau=zeros(2,4);
Bidx=cell(1);
% Apply it to the data
for r=1:length(Dat)
    burstTimes=Dat(r).burstTimes(burnIn:end);
    [rmDn,ID]=wrongNspikes(burstTimes,useDn);%will find the sweeps with the wrong burst times, apply 
    tSpike=feval(fc,cell2mat(burstTimes));
    cnoise=Dat(r).trials.cnoise(:,burnIn:end);%this is the denominator. 
    %get burst times
    subplot(2,2,r); hold on;
    ind=1:length(tSpike);
    plot(ID,tSpike,'k.')%plot all of them
    ylim([fc(0),1.5])
    for ns=1:length(y)
        %here make idx, which labels the indices of the times 
        idx=abs(tSpike-y(ns))<spread&~rmDn';%dont allow the ones we need to remove
        Bidx{r,ns}=idx;
        
        plot(ID(idx),tSpike(idx),'.','color',col(ns,:))
        %save the times
        Tburst(ns,r)=median(tSpike(idx));
        Sburst(ns,r)=1.4826*mad(tSpike(idx));

        %calculate SNR
        snr=zeros(size(Dat(r).trials.amp,1),1);
        for t=1:size(Dat(r).trials.amp,1)
            amps=cell2mat(Dat(r).trials.amp(t,burnIn:end));
            amps=amps(idx);
            sweep=ID(idx);
            noise=cnoise(t,sweep);
            SNR_sweeps=amps./sqrt(noise)*400;
            snr(t)=mean(SNR_sweeps);%the mean across all sweeps        
        end
        SNR(ns,r)=mean(snr);
    end
    title(num2str(r))
    xlim([0,ID(end)])
    %calculate the tau for onset and offset of each trial. same for
    %all bursts, so doesnt depend on all the stuff above
    tau(1:2,r)=mean(vertcat(Dat(r).trials.tau{burnIn:end}),1)*diff(fc(1:2));
end
suptitle(num2str(cID))
Tburst,Sburst
Msnr=mean(SNR,2)
%% If you want to remove some reptition OR burst within a repitition
rmRep=[4]; %to remove the rendition you don t like
%(Burst Number,Repitition Number)
Tburst(:,rmRep)=NaN;
Sburst(:,rmRep)=NaN;
SNR(:,rmRep)=NaN;
tau(:,rmRep)=NaN;

Tburst,Sburst
%% Once you're happy 
savefig(1,[f,'AutoFigures\',num2str(cID),'_tSpike.fig'])
Onsets(c).t=Tburst;
Onsets(c).s=Sburst;
Onsets(c).tau=tau;
Onsets(c).SNR=SNR;
Onsets(c).rmDn=useDn;
Onsets(c).Bidx=Bidx;

save([f,'OnsetsUpdate.mat'],'Onsets')
