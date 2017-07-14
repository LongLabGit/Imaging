function [sT,sono1]=remakeSono(sono,Tindex,tcurr,c,allCol)

sT=sono;%original sonogram
rangeT=[min(Tindex),max(Tindex)];
lineW=3;
if (tcurr>=rangeT(1))&&(tcurr<=rangeT(2))&&c>0
    c=allCol(c,:);
    [~,index]=min(abs(Tindex-tcurr));
    %make a colored line on the sonogram
    newLine=repmat(c,size(sono,1),1,lineW+1);
    newLine=permute(newLine,[1,3,2]);
    sT(:,index:index+lineW,:)=newLine;
end
sono1=sT;

newl=linspace(1,size(allCol,1),size(sT,2));
scale=interp1(1:size(allCol,1),allCol,newl);
scale=repmat(scale,1,1,4);
scale=permute(scale,[3,1,2]);
sT=cat(1,scale,sT)*255;