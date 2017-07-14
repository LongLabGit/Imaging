function [allP,allC]=getAlteredRois(f,ind)

ind=ind-1;
fxs=[f,'SameCells_Previous.xlsx'];
[~,~,raw]=xlsread(fxs);
planesO=cellfun(@num2str,raw(1,:),'UniformOutput',0);%planes will be the same
cellsO=cell2mat(raw(2:end,:));
%cant do this, because it removes the extra planes. deal with case by case
% rm1=sum(isnan(cellsO),1)==size(cellsO,1);
% cellsO(:,rm1)=[];
% planesO(rm1)=[];
rm2=sum(isnan(cellsO),2)==size(cellsO,2);
cellsO(rm2,:)=[];

fxs=[f,'SameCells.xlsx'];
[~,~,raw]=xlsread(fxs);
planes=cellfun(@num2str,raw(1,:),'UniformOutput',0);
cells=cell2mat(raw(2:end,:));
rm1=sum(isnan(cells),1)==size(cells,1);
cells(:,rm1)=[];
planes(rm1)=[];
rm2=sum(isnan(cells),2)==size(cells,2);
cells(rm2,:)=[];

%if we added to the number of rows
lo=size(cellsO,1);
ln=size(cells,1);
if ln>lo
    cellsO=[cellsO;nan(ln-lo,length(planes))];
elseif ln<lo
    cells=[cells;nan(lo-ln,length(planes))];
end
if ~isequal(planes,planesO)
    disp('Please make sure that you have the same planes in both samecells')
end
%%
allP=cell(0,1);
allC=[];
caught=[];
for i=1:size(cells,1)
    cN=cells(i,:);
    cNo=cellsO(i,:);
    if ~isequalwithequalnans(cN,cNo)||any(i==ind);
        p=[planes(~isnan(cN)),planes(~isnan(cNo))];
        c=[cN(~isnan(cN)),cNo(~isnan(cNo))];
        ids=strcat(p,{'_'},cellfun(@num2str,num2cell(c),'UniformOutput',0));
        [~,b,~]=unique(ids);
        c=c(b);
        p=p(b);
        allC=[allC,c];
        allP=[allP,p];
    end
    if ~isequalwithequalnans(cN,cNo)
        caught=[caught,i];
    end
end
if ~isequal(caught,ind)
    disp('you arent correct in what changed')
    disp(caught)
    disp(ind)
else
    disp(['you have ',num2str(length(caught)),' cells changed'])
end