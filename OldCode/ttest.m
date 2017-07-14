mMean=repmat(mean(base),39,1);
dFoFbase=(base-mMean)./mMean;
data1raw=data1.*mMean+mMean;
clear h p
[h(:,1),p(:,1)]=ttest2(dFoFbase,data1,.05);
[h(:,2),p(:,2)]=ttest2(dFoFbase,data2,.05);
[h(:,3),p(:,3)]=ttest2(dFoFbase,data3,.05);

%%
Big=[data1;data2;data3]';
DataSort=sort(Big,2);
topN=round(size(DataSort,2)*1);
top=DataSort(:,topN);
% yn=[];
scatter(yn,top)
xlim([.1,2])