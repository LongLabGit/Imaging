% Firstthings you need to do is to load the ABFoutput
close all;
a=[Motif(:).warpFactor];
[~,indMean]=min(abs(a-1));
%get that data
mMean=Motif(indMean);
aud=mMean.audio;
Torig=mMean.audioTimesWARP;
Fs=4e4/mMean.warpFactor;
[~,F,T,P]= spectrogram(aud,384,256,linspace(500,1e4,1000),Fs);%make a sepctrogram out of it

T=T+Torig(1);%off set the time vector to be in sync with the imaging data 
spec=10*log10(P);
%% plot it
bot=.65;top=.01;%brightness and offset

figure(3);clf;
s(1)=subplot(2,1,1);
surf(T,F,spec,'edgecolor','none'); %plot it
%below is just a bunch of magic plotting stuff
axis tight;
ylabel('Hz');
colormap jet
cmap=colormap;
cmap(1:8,3)=linspace(0,1,8);
colormap(cmap);
climC=[min(min(spec)), max(max(spec))];
r=diff(climC);
climC(1)=climC(1)+bot*r;
climC(2)=climC(2)+top*r;
set(gca,'clim',climC);%change the colors
view(0,90);%look at it from the top
axis tight
%%
s(2)=subplot(2,1,2);
for i=1:3 
    plot(Motif(i).frameTimesWARP,cell7short(:,i))%cell7short is the data with the calciuml traces, you need to create it
    hold on
end
axis tight
linkaxes(s,'x')
xlim([-0.4 1.5]);