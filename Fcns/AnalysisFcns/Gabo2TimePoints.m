function [gtes,eGui]=Gabo2TimePoints(f,locAll,plotit)
%% load my data
load Analysis\GTEs\WaveFiles\Cuts.mat
b=f(6:8);
B={'105','131','192','193'};
wavs={'02_01_010_1','05_26_002_1','04_04_001_1','03_02_001_1'};


cut=Cut(strcmp(B,b)).range;
wvF=wavs(strcmp(B,b));
load([f,locAll,'ABF_Final.mat']);
a=strtok({Motif.name},'.')';
Motif=Motif(strcmp(a,wvF));
eGui=Motif.EguiTimesWARP;
ts=Motif.audioTimesWARP;
audf=Motif.audioF;
indS=regexp(audf,'\');
audf=audf(indS(end)+1:end);
wav=audioread([f,locAll,'motifWavs\',audf]);
t=linspace(ts(1),ts(2),length(wav));
t=t(cut(1):end-cut(2));
wav=wav(cut(1):end-cut(2));

%% Load Gabo Data


for i=1:4
    g=load(['Data\Gabo\gtes',num2str(i),'.Bird_',b,'.dat']);
    if i~=3
        g=load(['C:\Users\User\GaboCode\gtes',num2str(i),'.Bird_',b,'.dat']);
    else
        g=load(['C:\Users\User\GaboCode\gtes',num2str(i),'a.Bird_',b,'.dat']);
    end
%     G(i).g=g(g>eps)*4;
    G(i).g=g(g>1);
    G(i).id=i*ones(size(G(i).g));
end
gte=vertcat(G.g);
id=vertcat(G.id);
songGTE=gte(gte<length(wav));
gtes=t(songGTE);
songID=id(gte<length(wav));
dualGTE=gte(gte>length(wav)&gte<2*length(wav))-length(wav);
dualGTEid=id(gte>length(wav)&gte<2*length(wav));%shift it back

if plotit
    gwav=load(['Data\Gabo\Bird_' b '.Sound.dat']);
    tg=(0:(length(gwav)-1))*mode(diff(t))+t(1);
    figure(2);clf;hold on;
    h(1)=subplot(2,1,1);hold on;
    plot(tg,gwav,'c');
    plot(t,wav)
    for n=1:length(gte)
        line(tg(gte(n))*[1,1],.2*[-1,1],'color','k','linewidth',2)
    end
    for n=1:length(dualGTE)
        line(tg(dualGTE(n))*[1,1],.1*[-1,1],'color','g','linewidth',2)
    end
%     for n=1:length(eGui)
%         line(eGui(n)*[1,1],.05*[-1,1],'color','c','linewidth',2)
%     end
    axis tight;
    h(2)=subplot(2,1,2);hold on;
    cols=lines(4);
    cols(2,:)=[1 0 1];
    for g=1:length(G)
        for n=1%:length(G(g).g)
            line(tg(G(g).g(n))*[1,1],.2*[-1,1],'color',cols(g,:),'linewidth',2)
        end
    end
    legend('Syl','Pressure','Acoustic Features','F0 decay')
    plot(tg,gwav,'c');
    plot(t,wav,'r')
    for g=1:length(G)
        for n=1:length(G(g).g)
            line(tg(G(g).g(n))*[1,1],.2*[-1,1],'color',cols(g,:),'linewidth',2)
        end
    end
    axis tight;
    linkaxes(h)
    suptitle(b)
end
%%
fprintf('Diff: ')
thr=2e2;


[dualGTE,inds]=sort(dualGTE);
dualGTEid=dualGTEid(inds);

songID(songGTE>(max(dualGTE)+thr))=[];
songGTE(songGTE>(max(dualGTE)+thr))=[];
[songGTE,inds]=sort(songGTE);
id=songID(inds);

for i=1:length(dualGTE)
    d=abs(dualGTE(i)-songGTE);
    if sum(d<thr)==0
        fprintf([num2str(dualGTEid(i)),', '])
        plot(tg(dualGTE(i)),0,'g*')
        plot(tg(dualGTE(i)+length(wav)),0,'b*')
    end
end
for i=1:length(songGTE)
    d=abs(dualGTE-songGTE(i));
    if sum(d<thr)==0
        fprintf([num2str(id(i)),', '])
        plot(tg(songGTE(i)),0,'b*')
    end
end
disp('Done')