clear;clc;%close all;
addpath Fcns\AnalysisFcns
addpath Fcns\ROIFcns
% close all;
Fa={'Data\316\'};
subf={'plane X\','plane X-50\','plane Y\','plane Y-5-\','plane Z\'};
set(0,'DefaultFigureWindowStyle','docked')
onlySong=1;
plotTraces=0;
%%
for fi=length(Fa)
    f=Fa{fi};
    %get burst times
    load([f,'InitialC.mat'])%if we havent run final yet
    load([f,'allROIs.mat'])%if we havent run final yet]
    load([f,subf{1} 'ABF_Final.mat']);
    %convert to cell number
    cellN=[ROIs.cellN];
    %get singing times
    sets=vertcat(Motif.TimeSingingWARP);
    rm=cellfun(@isempty,{Motif.syllMiss});
    tS=mean(sets(rm,:));
    if fi>2
        tS=[0,.678];
    end
    %
    ICind=[];    t=[]; s=[]; ROIindex=[];
    ind=1;    nSing=0;
    planeInds=find(strcmp({ROIs.f},[f,subf{fi}]));
    for i=1:length(InitialC)
        bT=InitialC(i).bursts;
        bS=InitialC(i).Sburst;
        bT=bT-tS(1);
        in=bT>(tS(1)-tS(1))&bT<(tS(2)-tS(1));
        if onlySong
            bT=bT(in);
            bS=bS(in);
        end
        if ~isempty(bT)
            for ii=1:length(bT)
                foo=InitialC(i).inds;
                roiInd=intersect(foo,planeInds);
                if ~isempty(roiInd)
                    ICind(ind)=i;
                    ROIindex(ind)=roiInd;
                    t(ind)=bT(ii);
                    s(ind)=bS(ii);
                    ind=ind+1;
                end
            end
        end
        nSing=nSing+1;
    end
    figure(2+2*fi);clf;
    Effect2Roi([f,subf{fi},'ROIs\RoiSet.zip'],[f,subf{fi},'6-Full\Avg.tif'],t,cellN(ROIindex))
    set(gca,'clim',tS)
    length(unique(cellN(ROIindex)))
    suptitle(strrep([f,subf{fi}],'\',' '))
    
    %This will plot the spectrogram
    figure(3+2*fi);clf;
    h(1)=subplot(5,1,1);hold on;
    audiof=Motif(1).audioF;
    if strcmp(audiof,'Data\222mela\motifWavs\04_06_011_1.wav')
        audiof='Data\222mela\All\motifWavs\04_06_011_1.wav';
    elseif strcmp(audiof,'Data\316\motifWavs\07_30_001_1.wav')
        audiof='Data\316\316\motifWavs\07_30_001_1.wav';
    end
    [dat,fs]=audioread(audiof);
    [~,F,T,P]=spectrogram(dat,512,384,0:10:8e3,fs);%make it
    S=10*log10(P);
    T=linspace(Motif(1).audioTimesWARP(1),Motif(1).audioTimesWARP(2),length(T))-tS(1);
    imagesc(T,F,S);set(h(1),'ydir','normal');
    cmap=colormap(jet);    cmap(1:8,3)=linspace(0,1,8);    colormap(cmap);
    set(gca,'clim',[min(S(:))+.6*range(S(:)),max(S(:))]);%change the colors
    axis tight;
    egT=Motif(1).EguiTimesWARP;
    for i=1:length(egT)
        line(egT(i)*[1,1]-tS(1),ylim,'color','w')
    end
    if fi==1
        line(tS(2)*[1,1]-tS(1),ylim,'color','w')
    end
    %
    
    h(2)=subplot(5,1,2:5);hold on;
    [t2,inds]=sort(t);
    ICind2=ICind(inds);
    s=s(inds);
    colors=jet(256);
    wi=round((t2-min(t2))/range(t2)*255+1);
    for ci=1:length(t2)
        time=InitialC(ICind2(ci)).time(:)-tS(1);
        trace=InitialC(ICind2(ci)).traces(:);
%         cfun= fit(time,trace,'smoothingspline','SmoothingParam',1-1e-5);
%         T=sort(time);
%         y = feval(cfun,T);
%         y=(y-min(y))/range(y);
    %     plot(T,y+ci,'k','linewidth',2)
        traces=InitialC(ICind2(ci)).traces;
%         traces=(traces-min(traces(:)))/range(traces(:));
        tt=InitialC(ICind2(ci)).time-tS(1);
        tc=traces+length(t2)-ci;
        if plotTraces
            for cii=1:size(traces,1);
                timeCurr=tt(cii,:);
                start=find(timeCurr>-.2,1,'first');
                stop=find(timeCurr<0,1,'last');
                df=mean(tc(cii,start:stop));
                plot(tt(cii,:),(tc(cii,:)-df)/df+length(t2)-ci,'color',colors(wi(ci),:))
            end
            line(t2(ci)*[1,1],length(t2)-[ci,ci-1],'color',colors(wi(ci),:))
        else
            line(t2(ci)+s(ci)*[-1,1],length(t2)-[ci,ci]+.5,'color',colors(wi(ci),:))
        end
    end
    set(gca,'ytick',0:5:length(t2));
%     set(gca,'yticklabel',0:5:length(t2));
%     set(gca,'yticklabel',strread((0:5:length(t2))','%s'))
    axis tight
    y=ylim;
    ylim([0,y(2)+.5])
    xlim(xlim+[-.1,.1])
    line(tS(1)*[1,1]-tS(1),ylim)
    line(tS(2)*[1,1]-tS(1),ylim)
    linkaxes(h,'x')
    suptitle(strrep([f,subf{fi}],'\',' '))
end