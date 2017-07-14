function Cell=sel_and_norm(folder,CellF,CellInfo,both,onebyone)
close all;
set(0,'DefaultFigureWindowStyle','docked');%important for viewing a lot of traces
% first look at them
allM=1:size(CellF(1).f,1);%get the 
if both
    for indC=1:length(CellInfo)
        c=CellInfo(indC).cellID;
        figure(c);clf;subplot(2,1,1);hold on
        inds=setdiff(allM,CellInfo(indC).rmMotif);
        col=jet(length(inds));
        for nM=1:length(inds)
            m=inds(nM);
            s=CellF(c).f(m,:);
            s=s-min(s);        
            s=s/mean(s);
            t=CellF(c).t(m,:);
            plot(t,s,'color',col(nM,:))%to not include time
            axis tight
        end
        title(['Cell #',num2str(c),', -min/mean'])
    %     print
    end
end

% normalize
clear Cell;
for indC=1:length(CellInfo)
    c=CellInfo(indC).cellID;    disp(num2str(c))
    %plot set up
    figure(c);
    if both
        subplot(2,1,2);
    else
        clf;
    end
    hold on;
    title(['Cell#:',num2str(c),', ',num2str(length(inds)),' motifs, baseNorm'])
    %select your data
    bStart=CellInfo(indC).baseStart;    baseLen=CellInfo(indC).baseLen;
    inds=setdiff(allM,CellInfo(indC).rmMotif);
    col=jet(length(inds));
    Cell(indC).f=folder;
    Cell(indC).CellID=c;
    Cell(indC).motifInds=inds;

    for mN=1:length(inds)
        m=inds(mN);
        t=CellF(c).t(m,:);
        s=CellF(c).f(m,:);
        [~,f1]=min(abs(bStart-t));
        f2=min(f1+baseLen,length(s));%make sure we dont go past it
        baseline=s(f1:f2);%get baseline vector
        s=s-mean(baseline);%subtract off its mean
        center(mN)=mean(s);%store the normalization value
        s=s/abs(center(mN));%normalize by the ABS of the mean
        
        %store the values
        Cell(indC).T(mN,:)=t;
        Cell(indC).raw(mN,:)=CellF(c).f(m,:);
        Cell(indC).norm(mN,:)=s;
        plot(t,s,'color',col(mN,:))
        axis tight
        fprintf([num2str(m),','])
        if onebyone
            pause;
        end
    end
    disp('end')
end
save([folder,'ROIs\FinalROIs.mat'],'Cell')