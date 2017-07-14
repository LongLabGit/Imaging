function [allID,m]=visualizeTracesAlternate(tCell,sCell,mCell,cut,rmsub,aMots,bMots,onlyA,n)

%Cut Traces
if ~isempty(cut)
    for r=1:length(tCell)
        %for diff sampling rate
        if diff(tCell{r}(1,1:2))<.03;
            cut=cut*2;
        end
        if length(cut)==1||cut(2)>=length(tCell{r})
            tCell{r}=tCell{r}(:,cut:end);
            sCell{r}=sCell{r}(:,cut:end);
        else
            tCell{r}=tCell{r}(:,cut(1):cut(2));
            sCell{r}=sCell{r}(:,cut(1):cut(2));
        end
    end
end



%Join ROIs together. 
allT=[];%time
allS=[];%signal
allID=[];%binary ID
allRm=[];
for r=1:length(tCell)
    t=tCell{r};
    s=sCell{r};
    %make index for removed
    rmI=zeros(size(tCell{r},1),1);
    if ~isempty(rmsub)
        cI=[rmsub{:,1}];
        rmSubI=find(cI==r);
        if ~isempty(rmSubI)
            rmI(rmsub{rmSubI,2})=1;
        end
    end
    %index for binary identity
    bID=zeros(size(tCell{r},1),1);
    indA=ismember(mCell{r},aMots);
    indB=ismember(mCell{r},bMots);
    bID(indA)=1;
    bID(indB)=2;
    if 0%normalize
        s=s-repmat(min(s,[],2),1,size(s,2));
        s=s./repmat(max(s,[],2),1,size(s,2));        
    end
    %this will break if given different lengths of data. will need to deal
    %with that only for 105, ignore for now,. to fix see original
    %visualize traces
    allT=[allT;t];
    allS=[allS;s];
    allID=[allID;bID];
    allRm=[allRm;rmI];
end
% now plot everything
%first plot for legend
% if ~onlyA
%     indA=find(allID==1&~allRm,1,'first');
%     indB=find(allID==2&~allRm,1,'first');
%     plot(allT(indA,:),allS(indA,:),'r');
%     plot(allT(indB,:),allS(indB,:),'b');
%     legend('Partial Song','Full Song')
% end
%we sometimes need to take a subset of the possible data
Subset=zeros(size(allID));
%if its is only A we need to transform N to be the nth motif of only the A
%files

if isempty(n)
    Subset(:)=1;
end

if onlyA
    indexOfA=find(allID==1);
    n=indexOfA(n);
    Subset(n)=1;
    t1=allT(allID==1&~allRm&Subset,:)';
    s1=allS(allID==1&~allRm&Subset,:)';
    plot(t1,s1,'r');
    plot(allT(allID==1&allRm&Subset,:)',allS(allID==1&allRm&Subset,:)',':r');
else
    Subset(n)=1;
    t1=allT(allID==1&~allRm&Subset,:)';
    s1=allS(allID==1&~allRm&Subset,:)';
    plot(t1,s1,'r');
    t2=allT(allID==2&~allRm&Subset,:)';
    s2=allS(allID==2&~allRm&Subset,:)';
    plot(t2,s2,'b');
%     if isempty(n)%only look at the removed ones when we are alooking at all
        plot(allT(allID==1&allRm&Subset,:)',allS(allID==1&allRm&Subset,:)',':r');
        plot(allT(allID==2&allRm&Subset,:)',allS(allID==2&allRm&Subset,:)',':b');
%     end
end

axis tight;
m=vertcat(mCell{:});
if sum(Subset)==1
    m=strrep(m{logical(Subset)},'_','\_');
end