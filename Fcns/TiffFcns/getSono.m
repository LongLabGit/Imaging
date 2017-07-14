function sT=remakeSono(sono,Tindex,tcurr)

if sum(onsetFrame==i)%if we have a point here, drop a line
    %make a colored line on the sonogram
    newLine=repmat(colors(i,:),sonogramH,1,linewidth);
    newLine=permute(newLine,[1,3,2]);
    sT(:,lineLoc(i,:),:)=newLine;
    sonogram(:,lineLoc(i,:),:)=newLine;
else
    sT=sonogram;
end

songC=colors(songStart:songEnd,:);
newl=linspace(1,size(songC,1),w);
scale=interp1(1:size(songC,1),songC,newl);
scale=repmat(scale,1,1,4);
scale=permute(scale,[3,1,2]);
