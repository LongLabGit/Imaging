function [xl,yl,xlS,ylS]=iterativeLoc(f,X,Y,planes)
nReps=1e4;
relset=zeros(nReps,size(X,2));
%first do X
mat=X;
rel=mat(1,:);
for n=1:nReps
    for i=1:length(rel)
        offsets=mat(:,i)';%these are the options
        offsets(i)=NaN;
        rel_to_1=~isnan(rel);
        keep=rel_to_1&~isnan(offsets);
        loc=mean(rel(keep)+offsets(keep));
        rel(i)=loc;
    end
    relset(n,:)=rel;
end
xl=mean(relset);
%then do Y
mat=Y;
rel=mat(1,:);
for n=1:nReps
    for i=1:length(rel)
        offsets=mat(:,i)';%these are the options
        offsets(i)=NaN;
        rel_to_1=~isnan(rel);
        keep=rel_to_1&~isnan(offsets);
        loc=mean(rel(keep)+offsets(keep));
        rel(i)=loc;
    end
    relset(n,:)=rel;
end
yl=mean(relset);
%then align to our previous list
[~,~,dat]=xlsread([f,'Z planes.xlsx']);
planes2=dat(2:end,1);
planes2=cellfun(@num2str,planes2,'UniformOutput',0);
[~,Locb] = ismember(planes',planes2);
xlS=nan(size(planes2));
ylS=nan(size(planes2));
xlS(Locb)=xl;
ylS(Locb)=yl;
