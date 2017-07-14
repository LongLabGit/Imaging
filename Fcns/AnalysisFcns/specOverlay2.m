function specOverlay(burstInfo,S,T,F,splay,Song,stdLim,delay)
%FinalC=our struct with the timing info
%splay=separtate bT to individual bursts
%S,T,F: spectrogram info
%song=do you want the song underlay?
%stdLim=maximum burst std, throw out bursts that are worse than that
%delay=offset of burst to electrophysiology

% generate spectrogram
set(gca,'color','k');
k=.6;
t2=linspace(T(1),T(end),size(S,2));
if Song
    imagesc(t2,F,S)
    colormap jet;
    ylabel('Hz');
    cmap=colormap;
    set(gca,'YDir','normal')
    cmap(1:8,3)=linspace(0,1,8);
    colormap(cmap);
    climC=[min(min(S)), max(max(S))];
    r=diff(climC);
    climC(1)=climC(1)+k*r;
    set(gca,'clim',climC);%change the colors
    hold on;
else%if you dont want to put the song underneath
    xlim([min(t2),max(t2)]);
    ylim([min(F)+100,max(F)]);
end
%% Put on the cells
bT=nan(length(burstInfo),5);%maximum 5 bursts in a motif. just a made up number. 
bS=nan(length(burstInfo),5);
for i=1:length(burstInfo)
    b=nanmean(burstInfo(i).t,2)'-delay;%take an average of the four repititions and shift back by the delay between burst and calcium
    s=nanmean(burstInfo(i).s,2)';
    [b,inds]=sort(b);
    bT(i,1:length(b))=b;
    bS(i,1:length(s))=s(inds);
end
rmS=bS>stdLim;
bT(rmS)=NaN;
bS(rmS)=NaN;
%make skinnier. no reason why
bT(:,~sum(~isnan(bT)))=[];
bS(:,~sum(~isnan(bS)))=[];
if splay%separate burst id turn turn into vector
    bT=bT(:);
    bS=bS(:);
    bT=bT(~isnan(bT));
    bS=bS(~isnan(bS));
end
[~,ind]=sort(bT(:,1));%sort on first burst
ind=flipud(ind);
bT=bT(ind,:);
bS=bS(ind,:);
if Song
    Y=linspace(F(1)+diff(F(1:2)),F(end),length(bT)+1);
    axis tight
else
    Y=1:length(bT);
    ylim([0,length(bT)+1])
end
for i=1:length(bT)
    bi=bT(i,:);
    si=bS(i,:);
    bi=bi(~isnan(bi));
    si=si(~isnan(si));
    for b=1:length(bi)
        line(bi(b)+si(b)*[-1,1],[Y(i),Y(i)],'color','w','linewidth',2)
    end
end
set(gca,'TickDir','out')
xlabel('time (s)')
% title('Spectrogram Overlay')