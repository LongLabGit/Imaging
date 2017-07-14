function [bTn,bSn,SNR,nB]=extractMCMC(Dat,burnIn,burstRanges)
%Input:
%   Dat: struct that has the info from MCMC
%   burnIn: number of sweeps to throw out 
%   eBins: histogram bin edges for the intiailization of burst numbers.
%   make  this something like (Song Onset+.1):.001:(Song offset-.1)
%   sW: min distance between bursts, make ~0.1 seconds
%   bW: width of bins in eBins
%   Sing: song edges
%Output
%   bTn: burst times
%   bSn: std of burst times
%   SNR: SNR of bursts
%   n: histogram points. not really neccesary, but good for gutchecking
if ~Dat.error
    burstTimes=Dat.burstTimes;%get burst times
    [~,ID]=wrongNspikes(burstTimes(burnIn:end),0);%will find the sweeps with the wrong burst times, apply 
    a=cell2mat(burstTimes(burnIn:end));
    %Get Times points, SNR
    tSpike=feval(Dat.fc,a);%convert bins to time points
    cnoise=Dat.trials.cnoise(:,burnIn:end);%get noise on trials
    [bSn,bTn,SNR]=deal([]);
    for nT=1:size(burstRanges,1)
        inds=(tSpike>burstRanges(nT,1)) & (tSpike<burstRanges(nT,2));
        %get burst times
        bTn(nT)=median(tSpike(inds));
        bSn(nT)=1.4826*mad(tSpike(inds),1);
        %get SNR, take the average across trials
        snr=zeros(size(Dat.trials.amp,1),1);%initialize a trails x 1 vector of SNR
        for trial=1:size(Dat.trials.amp,1)%for each trial
            amps=cell2mat(Dat.trials.amp(trial,burnIn:end));%get amplitudes
            amps=amps(inds);%extract the amplitudes of that burst
            sweep=ID(inds);
            noise=cnoise(trial,sweep);
            SNR_sweeps=amps./sqrt(noise);
            snr(trial)=mean(SNR_sweeps);%the mean across all sweeps
        end
        SNR(nT)=mean(snr*400);%Josh's arbitrary number
    end

    %Remove outside song!
%     if ~manualPutIn
%         bSn(bTn<Sing(1)|bTn>Sing(2))=[];
%         SNR(bTn<Sing(1)|bTn>Sing(2))=[];
%         bTn(bTn<Sing(1)|bTn>Sing(2))=[];
%     end

else
    [bSn,bTn,SNR]=deal([]);
end
nB=length(SNR);