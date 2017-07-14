function [burstRanges,nT,n]=cluster_tSpike(Dat,burnIn,eBins,sW,bw)
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
    a=cell2mat(burstTimes(burnIn:end));
    %Get Times points, SNR
    tSpike=feval(Dat.fc,a);%convert bins to time points
    tSpike=tSpike(tSpike>eBins(1)&tSpike<eBins(end));%only get during singing
    % hokey algorithm for finding the number of bursts
    n=histcounts(tSpike,eBins);
    [pks,locs]=findpeaks(n,'NPeaks',4,'MinPeakProminence',max(n)/5,'MinPeakDistance',sW/bw);
    %Then try to fit a mixture of gaussians. dont bother initializing to pk
    %locs (can add that later if you want)
    if length(tSpike)<100
        pks=[];
    end
    if ~isempty(pks)
        S.mu=eBins(locs)';
        S.Sigma=4e-4*ones(1,1,length(locs));
        S.ComponentProportion=1/length(locs)*ones(1,length(locs));
        GM=fitgmdist(tSpike,length(locs),'Replicates',1,'Start',S);
        %Can also do without initializing it and do 100 replicates, which will pick
        %the best one
        % figure(1);clf;hold on;y=pdf(GM,eBins');plot(eBins(1:end-1),n);plot(eBins,y/max(y)*max(n));%gut check
        m=GM.mu;[m,inds]=sort(m);
        s=squeeze(GM.Sigma);s=sqrt(s(inds));
    end
    %extract data using these centers and widths
    burstRanges=zeros(length(pks),2);
    for nT=1:min(length(pks),4)
        burstRanges(nT,1)=m(nT)-s(nT)*5;
        burstRanges(nT,2)=m(nT)+s(nT)*5;
    end
end