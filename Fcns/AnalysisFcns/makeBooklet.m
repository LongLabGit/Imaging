function makeBooklet(f,FinalC,ROIs,tN)

% [co,~,pl]=xlsread([f,'manualonsetdetection102.xlsx']);
% co=co(:,2:3);
% pl=cellfun(@num2str,pl(2:end,1),'UniformOutput',0);
% pl((size(co,1)+1):end)=[];


%convert michel to brainC index
% bcPln={ROIs.f};
% bcPln=strrep(bcPln,'Data\102\CorrectedPlanes\','')';%clean it up
% bcPln=cellfun(@(x) x(1:end-1),bcPln,'UniformOutput',0);
% bcCl=[ROIs.cellN];
% for c=1:length(pl)
%     samePlane=strcmp(pl{c},bcPln);
%     sameCell=(bcCl==co(c,1))';
%     if sum(samePlane&sameCell)==0
%         disp([pl{c},' ,',num2str(co(c,1))])
%         brainInd(c)=0;
%     else
%         brainInd(c)=find(samePlane&sameCell);
%     end
% end
% dat=unique(brainInd);
% dat=dat(dat>0);
% for i=1:length(dat)
%     mo{i}=co(brainInd==dat(i),2);
% end
%order by burst time
bT=zeros(length(FinalC),1);%maximum 5 bursts in a motif
for i=1:length(FinalC)
    b=nanmean(FinalC(i).bursts,2)';
    b=sort(b);
    bT(i)=b(1);
end
[~,indsFC]=sort(bT);
FinalC=FinalC(indsFC);%sort by onset time


for c=1:length(FinalC)
    inds=FinalC(c).inds;
%     mos=vertcat(mo{ismember(dat,inds)});
    
    cID=FinalC(c).cID;
    figure(1);
    h(1)=openfig([f,'AutoFigures\',num2str(cID),'_Traces.fig'],'reuse');
    
    h(2)=openfig([f,'AutoFigures\',num2str(cID),'_tSpike.fig'],'reuse');
%     h(3)=openfig([f,'AutoFigures\',num2str(cID),'_plotMCMC.fig'],'reuse');
    figure(1);clf;
    %traces
    tr=subplot(1,2,1);
    ch=get(gca(h(1)),'children');

    copyobj(ch,tr)
    legend(cellstr(num2str(FinalC(c).inds')))
    xlabel('time (s)')
    ylabel('F')
    %tSpike
    a=get(h(2),'children');
    a=a(cellfun(@isempty,get(a,'Tag')));%throw out the suptitle
    SPinds=[3,4,7,8];
    for i=1:4
        tr=subplot(2,4,SPinds(i));
        copyobj(get(a(i),'Children'),tr)
        axis tight;%squeeze on x
        ylim(tN)
        xlabel('sweep index')
        ylabel('time (s)')
        title(['Iteration #',num2str(i)])
    end
    onset=round(nanmean(FinalC(c).bursts,2)*1e3)/1e3;
    st=round(nanmean(FinalC(c).Sburst,2)*1e3)/1e3;
    if length(onset)>1
        os='';
        ss='';
        for ol=1:length(onset)
            os=[os,num2str(onset(ol)),', '];
            ss=[ss,num2str(st(ol)),', '];
        end
        os=os(1:end-2);
        ss=ss(1:end-2);
    else
        os=num2str(onset);
        ss=num2str(st);
    end
    supT=['cID #',num2str(cID),' OS=',os,' & S=' ss];
%     mM=nan(size(onset));
%     if ~isempty(mos)
%         for onsI=1:length(onset)
%             mM(onsI)=mean(mos(abs(mos-onset(onsI))<.1));
%         end
%     end
%     if sum(isnan(mM))
%         supT=[supT, ' & d2m: '];
%         for i=1:length(mM)
%             if ~isnan(mM(i))
%                 dM(i)=onset(i)-mM(i);
%                 supT=[supT,num2str(dM,2),', '];
%             end
%         end
%         supT=supT(1:end-1);
%     end
    suptitle(supT)
    cdata1 = print('-RGBImage','-r90');
    if c==1
        imwrite(cdata1,[f,'Booklet.tif'],'compression','none')
    else
        imwrite(cdata1,[f,'Booklet.tif'],'WriteMode','append','compression','none')
    end
    close all;
    openfig([f,'AutoFigures\',num2str(cID),'_plotMCMC.fig'],'reuse'); 
    suptitle(['cID #', num2str(cID),', Plot MCMC'])
    cdata2 = print('-RGBImage','-r90');
    imwrite(cdata2,[f,'Booklet.tif'],'WriteMode','append','compression','none')
end