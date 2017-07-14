function [time,traces]=visualizeTraces(ROIs,inds,binCheck,normalize,rmsub,cut,plotit,rec)
if rec==1&&plotit&&~isempty(rmsub)%if you're allowed to be recursive
    visualizeTraces(ROIs,inds,binCheck,normalize,[],cut,plotit,0);
end
if plotit
    figure;clf;hold on;
end
%extract the data
tCell={ROIs(inds).t};
sCell={ROIs(inds).bin};
nTrials=cellfun(@(x) size(x,1),sCell);
col=lines(sum(nTrials));
indCol=1:length(col);
%now if we want to remove stuff
if ~isempty(rmsub)
    cI=[rmsub{:,1}];
    if sum(cI>length(tCell))
        disp('you are trying to remove trials from an ROI that doesnt exist')
    end
    for c=1:length(tCell)
        cI2=find(cI==c);
        if ~isempty(cI2)
            rm=rmsub{cI2,2};
            offset=sum(nTrials(1:c-1));
            indCol(rm+offset)=[];
            tCell{c}(rm,:)=[];
            sCell{c}(rm,:)=[];
        end
    end
end

%make legend
keptTrials=[];
for r=1:length(inds)
    if ~isempty(rmsub)
        rmI=cI==r;
        if sum(rmI)
            rm=rmsub{rmI,2};
            trials=setdiff((1:nTrials(r))',rm);
            trials=cellstr(num2str(trials));
        end
    else
        trials=cellstr(num2str((1:nTrials(r))'));
    end
    keptTrials=[keptTrials;strcat(num2str(r),':',trials)];
end

if ~isempty(cut)
    for c=1:length(tCell)
        c2=cut;
        if length(c2)==1||c2(2)>=length(tCell{c})
            tCell{c}=tCell{c}(:,c2:end);
            sCell{c}=sCell{c}(:,c2:end);
        else
            tCell{c}=tCell{c}(:,c2(1):c2(2));
            sCell{c}=sCell{c}(:,c2(1):c2(2));
        end
    end
end


%Append Each set of traces together. each one will come from a different
%set of rois. 
[nm,nf]=cellfun(@size,tCell);
indM=[0,cumsum(nm)];
time=nan(sum(nm),max(nf));
traces=nan(sum(nm),max(nf));
plotI=1;
for c=1:length(inds)
    t=tCell{c};
    s=sCell{c};
    time(indM(c)+1:indM(c+1),1:nf(c))=t;
    traces(indM(c)+1:indM(c+1),1:nf(c))=s;
    if normalize
        s=s-repmat(min(s,[],2),1,size(s,2));
        s=s./repmat(max(s,[],2),1,size(s,2));
    end
    if binCheck
        t=repmat(1:size(s,2),size(s,1),1);
    end
    if plotit
        for trial=1:size(t,1)
            plot(t(trial,:),s(trial,:),'color',col(indCol(plotI),:));
            plotI=plotI+1;
        end
    end
end
if plotit
    title([cellstr(num2str(inds'))]);
    legend(keptTrials);
end
if plotit
    axis tight;
end