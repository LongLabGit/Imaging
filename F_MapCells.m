clear;clc;close all;
addpath Fcns\AnalysisFcns
addpath Fcns\ROIFcns
f='Data\348\';
%get burst times
load([f,'InitialC.mat'])%if we havent run final yet
load([f,'allROIs.mat'])%if we havent run final yet
set(0,'DefaultFigureWindowStyle','docked')
%% Show Cells on Planes
% Plot the images
planes=unique({ROIs.f})';
for p=1:length(planes)
    figure(p);clf;
    avgName=[planes{p},'4-Avgs\AVG.tif'];
    ImfI=imfinfo(avgName);
    img=nan(ImfI(1).Height,ImfI(1).Width,length(ImfI));
    for i=1:length(ImfI)
        img(:,:,i)=double(imread(avgName,'Info',ImfI));
    end
    img=mean(img,3);
    img=(img-min(img(:)))/range(img(:))*9;
    img(img>1.2)=1.2;
    imagesc(img)
    axis equal
    axis tight
    axis square
    colormap gray
    title(strrep(planes{p},'\',' '))
    
    %Make the cell alignment
    figure(p+length(planes));clf;
    load([planes{p},'ABF_Avgs.mat'])
    sets=vertcat(Motif.TimeSingingWARP);
    keep=cellfun(@isempty,{Motif.syllMiss});
    tS=mean(sets(keep,:),1);
    %get audio
    %audiof=Motif(1).audioF;
    %OR: enter path manually
    %audiof='Data\383 PA\Plane A\motifWavs\05_23_013_1.wav';
    audiof='Data\383 PB\Plane B\motifWavs\05_29_001_1.wav';
    [dat,fs]=audioread(audiof);
    [~,F,T,P]=spectrogram(dat,1024,800,500:2:8e3,fs);%make it
    S=10*log10(P);
    T=linspace(Motif(1).audioTimesWARP(1),Motif(1).audioTimesWARP(2),length(T));
    T=T-tS(1);%shift it forward?
    h(1)=subplot(4,1,1);
    imagesc(T,F,S);
    set(h(1),'ydir','normal');
    cmap=colormap(jet);    cmap(1:8,3)=linspace(0,1,8);    colormap(cmap);
    set(gca,'clim',[min(S(:))+.6*range(S(:)),max(S(:))]);%change the colors
    axis tight;
    egT=Motif(1).EguiTimesWARP;
%     for i=1:length(egT)
%         line(egT(i)*[1,1]-tS(1),ylim,'color','w')
%     end
    title(strrep(planes{p},'\',' '))
    h(2)=subplot(4,1,2:4);cla;hold on;
    planeInds=find(strcmp({ROIs.f},planes{p}));
    ICIndices=cellfun(@any,cellfun(@(x) ismember(planeInds,x),{InitialC.inds},'UniformOutput' ,false));%get the indices of all InitialCs that might have had this plane
    IC2=InitialC(ICIndices);
    
    [~,inds]=sort(cellfun(@min,{IC2.bursts}));
    IC2=IC2(inds);
    cols=jet(length(IC2));
    cIDs=[];    ind=1;
    for i=1:length(IC2)
        rInd=IC2(i).inds;
        rInd=intersect(rInd,planeInds);
        pt=ROIs(rInd).patch;
        pp=find(strcmp(planes,ROIs(rInd).f));
        figure(pp);
        patch(pt(:,1),pt(:,2),cols(i,:),'EdgeColor','none');
        text(mean(pt(:,1))+10,mean(pt(:,2))+10,num2str(IC2(i).cID),'color',cols(i,:))
        
        figure(p+length(planes))
        tBurst=IC2(i).bursts;
        sBurst=IC2(i).Sburst;
        for ti=1:length(tBurst)
            line(tBurst(ti)*[1,1]-tS(1),ind+[-.5,.5],'color',cols(i,:))
%             line(tBurst(ti)*[1,1]-tS(1)+sBurst(ti)*[-1,1],ind+[0,0],'color',cols(i,:))
            cIDs(ind)=IC2(i).cID;
            ind=ind+1;
        end
    end    
    axis tight;
    linkaxes(h,'x');
    set(gca,'ytick',1:length(cIDs));
    set(gca,'yticklabel',strread(num2str(cIDs),'%s'));
    line((tS(1)-tS(1))*[1,1],ylim,'color','k','linewidth',2)
    line((tS(2)-tS(1))*[1,1],ylim,'color','k','linewidth',2)
    axes(h(1))
    axis tight;
end