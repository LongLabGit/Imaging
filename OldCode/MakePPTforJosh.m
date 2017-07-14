clear;clc;
load Gabo\Data\Cut2.mat
% b='102';F='Data\102\All2\';load([F,'ABF_Output.mat']);load('Data\102\CorrectedPlanes\burstInfo.mat');
% b='105';F='Data\105\All\';load([F,'ABF_Final.mat']);load('Data\105\Planes\burstInfo.mat');
% b='131';F='Data\131\All\old\';load([F,'ABF_Final.mat']);load('Data\131\All\burstInfo.mat');
% b='193';F='Data\193\All\';load([F,'ABF_Final.mat']);load('Data\193\burstInfo.mat');
b='192';F='Data\192\All\';load([F,'ABF_Final.mat']);load('Data\192\Planes\burstInfo.mat');
% GTE Audio
%get the GTE data
load(['Gabo\Data\' b 'GTEs.mat'],'nms','gtes','newG','allG','inds');
nms=nms(inds);
allG=allG(inds);
gtes=sort([gtes,reshape(newG,[1,length(newG)])]);
allF=strtok({Motif.name},'.');
indF=strcmp(strtok({Motif.name},'.'),nms{1});
%Get the audio data
if strcmp(b,'102')
    aud=Motif(indF).audio;
elseif strcmp(b,'105')
    aud=audioread([Motif(indF).audioF]);
elseif strcmp(b,'131')
    aud=audioread([strrep(Motif(indF).audioF,'All','All\old')]);
elseif strcmp(b,'192')||strcmp(b,'193')
    aud=audioread([strrep(Motif(indF).audioF,'motifWavs','All\motifWavs')]);
end
t=linspace(Motif(indF).audioTimesWARP(1),Motif(indF).audioTimesWARP(end),length(aud));
cut=Cut(strcmp({Cut.b},b)).range;
t=t(cut(1):end-cut(2));
aud=aud(cut(1):end-cut(2));
save([b,'GTEwav.mat'],'t','aud')
F=linspace(500,10000,2^10);
w=Motif(indF).warpFactor;
[~,F,T,P]=spectrogram(aud,512,384,F,4e4);%make it
T=[t(1)+T(1)/w,t(end)+(T(end)-length(aud)/4e4)/w];%update time vector
S=10*log10(P);
%% Vs GTEs
figure(1);clf;hold on;
h(1)=subplot(3,1,1);
t2=linspace(T(1),T(end),size(S,2));
imagesc(t2,F,S)
colormap jet;
ylabel('Hz');
cmap=colormap;
set(gca,'YDir','normal')
cmap(1:8,3)=linspace(0,1,8);
colormap(cmap);
climC=[min(min(S)), max(max(S))];
r=diff(climC);
climC(1)=climC(1)+.6*r;
set(gca,'clim',climC);%change the color
for n=1:length(gtes)
    line(gtes(n)*[1,1],[F(1),F(end)],'color','g','linewidth',.5)
end
set(gca,'TickDir','out')
title([b ' GTEs'])
h(2)=subplot(3,1,2);
specOverlay(burstInfo,S,T,F,1,1,.015,.02);
title('Bursts')
h(3)=subplot(3,1,3);
specOverlay(burstInfo,S,T,F,1,1,.015,.02);
for n=1:length(gtes)
    line(gtes(n)*[1,1],[F(1),F(end)],'color','g','linewidth',.5)
end
title('Overlay')
linkaxes(h,'x');