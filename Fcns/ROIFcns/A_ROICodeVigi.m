clear;clc;
% folder='Data\131\All';
folder='Data\102\Efty2\';
%first load in results from ImageJ
% num=xlsread([folder,'ROIs\ROIs.xlsx']);
load([folder,'ROIs\ROIs.mat']);
num=data1; clear data1;
%then load the motif. well need this to parse concat
% load([folder,'ABF_Output.mat'],'Motif')
load([folder,'ABF_Final.mat'],'Motif')
% load([folder,'ABF_Concat.mat'],'Motif')
indI=[0,cumsum([Motif(:).numI])];

maxL=max([Motif(:).numI]);
Nm=length(Motif);
numC=size(num,2);
% extract data
for c=1:numC
    %initialize
    CellF(c).f=nan(Nm,maxL);
    CellF(c).t=nan(Nm,maxL);
    for m=1:Nm
        CellF(c).f(m,1:Motif(m).numI)=num(indI(m)+1:indI(m+1),c);
        CellF(c).t(m,1:Motif(m).numI)=Motif(m).frameTimesWARP;
    end
end
%% plot it
clear sig base2;
set(0,'DefaultFigureWindowStyle','docked')
inds=4:34;
col=jet(length(inds));
for c=19
    h=figure(c);clf;
    for Nm=1:length(inds)
        m=inds(Nm);
        s=CellF(c).f(m,:);
        s=s-min(s);
        s=s/mean(s);
        plot(CellF(c).t(m,:),s,'color',col(Nm,:))
        T(Nm,:)=CellF(c).t(m,:);
        sig(Nm,:)=s;
        hold on
        axis tight
    end
    title([num2str(c)])
%     legend(allTrials)
%     pause;
end
save([folder,'ROIs\CellF.mat'],'CellF');