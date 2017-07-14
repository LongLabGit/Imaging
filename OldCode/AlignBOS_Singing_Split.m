clear;clc;%close all;
addpath Fcns\AnalysisFcns
addpath Fcns\ROIFcns
set(0,'DefaultFigureWindowStyle','docked')
F={'Data\222\','Data\222 BOS\','Data\222mela\'};
% F={'Data\222\','Data\222 BOS\'};
for fi=1:length(F)
    f=F{fi};
    try
        load([f,'OnsetsUpdate.mat']);%if we havent run final yet
        O{fi}=Onsets;
    catch
        
    end
    load([f,'InitialC.mat']);%if we havent run final yet
    I{fi}=InitialC;
    if fi==2
        load([f,'ABF_Final.mat']);
    else
        load([f,'All\ABF_Final.mat']);
    end
    sets=vertcat(Motif.TimeSingingWARP);
    rm=cellfun(@isempty,{Motif.syllMiss});
    tS(fi,:)=mean(sets(rm,:));
    if fi>1
        tS(fi,:)=[0,.678];
    end
end
[C,folds]=xlsread('Data\Cross222b.xlsx');
rm=sum(isnan(C),2);
C=C(~rm,:);
% C=C(inds,:);
%%
load([F{1},'All\ABF_Final.mat']);
figure(1);clf;
h(1)=subplot(5,1,1);hold on;
audiof=Motif(1).audioF;
[dat,fs]=audioread(audiof);
[~,Fa,T,P]=spectrogram(dat,512,384,0:10:8e3,fs);%make it
S=10*log10(P);
T=linspace(Motif(1).audioTimesWARP(1),Motif(1).audioTimesWARP(2),length(T))-tS(1,1);
T=T/range(tS(1,:));
imagesc(T,Fa,S);set(h(1),'ydir','normal');
cmap=colormap(jet);    cmap(1:8,3)=linspace(0,1,8);    colormap(cmap);
set(gca,'clim',[min(S(:))+.6*range(S(:)),max(S(:))]);%change the colors
axis tight;
%%
h(2)=subplot(5,1,2:5);cla;hold on;
for c=1:size(C,1)
    %SINGING=RED
    i1=find([O{1}.cID]==C(c,1));
    t1=I{1}(i1).time;
    t1=(t1-tS(1,1))/range(tS(1,:));
    f1=norm01(I{1}(i1).traces,2);
    b1=nanmean(O{1}(i1).t,2);
    s1=nanmean(O{1}(i1).s,2);
    b1=(b1-tS(1,1))/range(tS(1,:));
    plot(t1',f1'+c,'r')
    for ii=1:length(b1)
        line(b1(ii)*[1,1],[c,c+1],'color','k','linewidth',2)
    end
    %BOS=BLUE
    i2=find([O{2}.cID]==C(c,2));
    t2=I{2}(i2).time;
    t2=(t2-tS(2,1))/range(tS(2,:));
    f2=norm01(I{2}(i2).traces,2);
    b2=nanmean(O{2}(i2).t,2);
    s2=nanmean(O{2}(i2).s,2);
    b2=(b2-tS(2,1))/range(tS(2,:));
    plot(t2',f2'+c+size(C,1)+1,'b')
    for ii=1:length(b2)
        line(b2(ii)*[1,1],[c,c+1]+size(C,1)+1,'color','k','linewidth',2)
    end
    %MELA=GREEN
%     i2=find([I{3}.cID]==C(c,3));
%     t2=I{3}(i2).time;
%     t2=(t2-tS(2,1))/range(tS(2,:));
%     f2=norm01(I{3}(i2).traces,2);
%     b3=nanmean(I{3}(i2).bursts,2);
%     b3=(b3-tS(2,1))/range(tS(2,:));
%     plot(t2',f2'+c+size(C,1)*2+2,'g')
%     for ii=1:length(b3)
%         line(b3(ii)*[1,1],[c,c+1]+ size(C,1)*2+2,'color','k','linewidth',2)
%     end
    b2
    B(c,:)=[b1(1),b2(1)];
    SB(c,:)=[s1(1),s2(1)];
end
set(gca,'ytick',1.5:9.5)
set(gca,'yticklabel',strread(num2str(C(:,2)'),'%s'))
line([0,0],ylim,'color','k');
line([1,1],ylim,'color','k');
linkaxes(h,'x');
xlim([-.1,1.1])
%%
figure(2);clf;hold on;
line([0,1],[0,1],'linewidth',1)
% plot(B(:,1),B(:,2),'x')
for i=1:3
    line(B(i,1)+SB(i,1)*[-2,2],B(i,2)+[0,0],'color','r')
    line(B(i,1)+[0,0],SB(i,2)*[-2,2]+B(i,2),'color','r')
end
xlim([0,1])
ylim([0,1])

xlabel('Normalized Burst Time During Singing')
ylabel('Normalized Burst Time During Sleep BOS')
title('Comparison of Burst Onsets')
