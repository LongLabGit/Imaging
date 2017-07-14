%% plot it
folder='Data\102\CorrectedPlanes\18\';
% folder='Data\102\Efty2\';
load([folder,'ROIs\CellF.mat'])
% load([folder,'ROIs\ROIs.mat'])
if exist([folder,'ROIs\ROIparams.mat'],'file')
    load([folder,'ROIs\ROIparams.mat'])
end
% mb=[76,41,35,23,7];% sb=[90,75,59,14,12];
sb=[75,14,12];
mb=[76,41,7];
cells=[sb,mb];
% cells=19;
%% first look at them
inds=1:size(CellF(1).f,1);
col=jet(length(inds));
for cellNumber=1:length(cells)
    c=cells(cellNumber);
    h=figure(c);clf;
    for m=inds
        s=CellF(c).f(m,:);
        s=s-min(s);        
        s=s/mean(s);
        t=CellF(c).t(m,:);
        plot(t,s,'color',col(m,:))%to not include time
        hold on
        axis tight
    end
    title(['Cell #',num2str(c),', All Motifs, -min/mean'])
%     print
end
%% normalize
clear Cell;
close all;
onebyone=0;%if =1, will go one at a time
%Define which ones to cull
%how many frames to take this is for cell 76
for cellNumber=1:length(cells)
    fNadvance=fNadvanceC(cellNumber);%76
    inds=setdiff(1:size(CellF(1).f,1),BadMotifs{cellNumber});
    bStart=base(cellNumber);
    col=jet(length(inds));
    c=cells(cellNumber);
    figure(c);clf;hold on;title(['Cell#:',num2str(c),', ',num2str(length(inds)),' motifs'])
    disp(num2str(c))
    for mN=1:length(inds)
        m=inds(mN);
        t=CellF(c).t(m,:);
        s=CellF(c).f(m,:);
        [~,indF]=min(abs(bStart-t));
        baseline=s(indF:min(indF+fNadvance,length(s)));%get baseline vector
        s1=s-min(s);s1=s1/mean(s1);
        s=s-mean(baseline);%subtract off its mean
        center(mN)=mean(s);%store the normalization value
        s=s/abs(center(mN));%normalize by the ABS of the mean
        
        %store the values
        Cell(cellNumber).plane=18;
        Cell(cellNumber).CellID=c;
        Cell(cellNumber).motifInds=inds;
        Cell(cellNumber).T(mN,:)=t;
        Cell(cellNumber).raw(mN,:)=CellF(c).f(m,:);
        Cell(cellNumber).sigBase(mN,:)=s;
        Cell(cellNumber).sigMin(mN,:)=s1;
        plot(t,s,'color',col(mN,:))
        axis tight
        fprintf([num2str(m),','])
        if onebyone
            pause;
        end
    end
%     print
    disp('end')
end
save 
%%
throw=ones(42,6);
for i=1:6
    throw(BadMotifs{i},i)=0;
end
throw(:,7)=sum(throw,2);

