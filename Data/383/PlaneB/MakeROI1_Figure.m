%go to michel stuff
%Interneurons
load('A:\Michel\Michel2photon\ImagingAnalysis\Data\182\1-9\ROIs\CellF.mat');
figure(2);clf;hold on;
c=2;
subplot(2,1,1);cla;
[wav,fs]=audioread('A:\Michel\Michel2photon\ImagingAnalysis\Data\182\All\motifWavs\03_19_002_1.wav');
tR=[-1.4750,1.7713];
tW=(1:length(wav))/fs+tR(1);
wav(tW<0)=wav(1);
wav(tW>.99)=wav(1);
vigiSpec(wav,fs,500:10:8000,.6,[],[],[-1.4750,1.7713])
xlim([-.5,1.5])
subplot(2,1,2);cla;hold on;
for i=1:9
    t=Cell(c).t(i,:);
    f=Cell(c).bin(i,:);
    f0=mean(f(1:20));
    plot(t,(f-f0)/f0,'color','b')
end
axis tight
xlim([-.5,1.5])
%% 
% first CD into this folder
% A:\Felix\ImagingAnalysisFelix\Data\383\PlaneB
reboot;
load InitialC.mat
load ABF_Used.mat;
m=1;
for c=[2 8 21 26 33]
    figure(c);clf
    h(1)=subplot(2,1,1);cla;hold on;
    af=Motif(m).audioF;
    [wav,fs]=audioread(af(18:end));
    tR=Motif(m).audioTimesWARP;
    vigiSpec(wav,fs,500:10:8000,.6,[],[],tR)
    axis tight;
    h(2)=subplot(2,1,2); hold on;
    for trial=1:15
        f=InitialC(c).traces(trial,:);
        f0=prctile(f,10);
        f=(f-f0)/f0;
        plot(InitialC(c).time(trial,:),f,'b')
    end
    linkaxes(h,'x')
    xlim([.2,.87])
%     axis tight
end