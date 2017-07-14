function [bT,bS]=plotDists(FinalC,wav,tN,tS,delay)
% parse out data
bT=[];
bS=[];
for i=1:length(FinalC)
    bT=[bT;nanmean(FinalC(i).t,2)-.02];%move back by 20 ms
    sn=nanmean(FinalC(i).s,2);
    if any(isnan(sn))
        keyboard;
    end
    bS=[bS;sn];
end
disp(['You have ',num2str(length(bT)),' bursts, with a mean std of ',num2str(mean(bS),2),' seconds'])
disp(['Of those, ', num2str(length(bT(bT>tS(1)&bT<tS(2)))), ' are within song'])
% Tau 
figure(1);clf;
tau=vertcat(FinalC.Tau);
bins=0:.05:max(tau(:));
subplot(2,1,1)
hist(tau(:,1),bins);
ylabel('Number of Cells')
axis tight
title(['Mean Onset Tau: ',num2str(mean(tau(:,1)),2),' s'])
xlabel('Time (s)')
subplot(2,1,2)
hist(tau(:,2),bins);
title(['Mean Offset Tau: ',num2str(mean(tau(:,2)),2),' s'])
axis tight
ylabel('Number of Cells')
xlabel('Time (s)')
%% STD
figure(2);clf;
h=[];
bw=.001;
bins=0:bw:(max(bS)+bw);
h(1)=subplot(1,4,1:3);
plot(sort(bS),'o')
xlabel('Sorted Burst Index')
ylabel('SEM (s)')
ylim([0,max(bins)+bw/2])
h(2)=subplot(1,4,4);
[a,b]=hist(bS,bins);
barh(b,a)
xlabel('Number of Bursts')
axis tight
linkaxes(h,'y')
suptitle('Estimate of Error in Burst Onset')
%% Burst Onset
figure(3);clf;
h=[];
h(1)=subplot(4,1,1);
t=linspace(tN(1),tN(2),length(wav));
plot(t,wav);
xlabel('time (s)')
ylabel('amplitude')
h(2)=subplot(4,1,2:4);
hist(bT-delay,50);
ylabel('number of bursts')
linkaxes(h,'x')
xlabel('time (s)')