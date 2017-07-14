function visualizeMotifs(Motif,mCell,rmsub,aMots,onlyA,spec,n)

motifWavs=strcat(strtok({Motif.name},'.'),'.wav');
indw=1;
for r=1:length(mCell)%for each ROI
    %make index for removed
    rmI=zeros(size(mCell{r},1),1);
    if ~isempty(rmsub)
        cI=[rmsub{:,1}];
        rmSubI=find(cI==r);
        if ~isempty(rmSubI)
            rmI(rmsub{rmSubI,2})=1;
        end
    end
    motifs=mCell{r};
    for m=1:length(motifs)
        wavF=motifs{m};
        isA=ismember(wavF,aMots);
        
        %index for binary identity
        if isA
            id='r';
        else
            id='b';
        end
        if rmI
            id=[':',id];
        end
        
        if isA&&onlyA
            if isempty(n)||sum(indw==n)
                indF=strcmp(wavF,motifWavs);
                wavLoc=Motif(indF).audioF;
                wavLoc=strrep(wavLoc,'m','All\m');
                wav=audioread(wavLoc);
                t=Motif(indF).audioTimesWARP;
                t=linspace(t(1),t(end),length(wav));
                if spec
                    [~,F,~,S]=spectrogram(wav,512,384,linspace(200,8000,500),4e4);%make it
                    T=linspace(t(1),t(end),size(S,1));
                    imagesc(T,F,10*log10(S));
                    ylabel('Hz');
                    cmap=colormap(jet);
                    set(gca,'YDir','normal')
                    cmap(1:8,3)=linspace(0,1,8);
                    colormap(cmap);
                    climC=[min(min(10*log10(S))), max(max(10*log10(S)))];
                    rang=diff(climC);
                    climC(1)=climC(1)+.6*rang;
                    set(gca,'clim',climC);%change the colors
                else
                    plot(t,wav+indw,id)
                end
            end
            indw=indw+1;
        elseif ~onlyA
            if isempty(n)||sum(indw==n)
                indF=strcmp(wavF,motifWavs);
                wavLoc=Motif(indF).audioF;
                wavLoc=strrep(wavLoc,'m','All\m');
                wav=audioread(wavLoc);
                t=Motif(indF).audioTimesWARP;
                t=linspace(t(1),t(end),length(wav));
                if spec
                    [~,F,~,S]=spectrogram(wav,512,384,linspace(200,8000,500),4e4);%make it
                    T=linspace(t(1),t(end),size(S,1));
                    imagesc(T,F,10*log10(S));
                    ylabel('Hz');
                    cmap=colormap(jet);
                    set(gca,'YDir','normal')
                    cmap(1:8,3)=linspace(0,1,8);
                    colormap(cmap);
                    climC=[min(min(10*log10(S))), max(max(10*log10(S)))];
                    rang=diff(climC);
                    climC(1)=climC(1)+.6*rang;
                    set(gca,'clim',climC);%change the colors
                else
                    plot(t,wav+indw,id)
                end
            end
            indw=indw+1;
        end
    end
end
if ~spec&&~isempty(n)
    ylim([min(n)-1,max(n)+1]);
elseif isempty(n)
    ylim([0,indw]);
end
