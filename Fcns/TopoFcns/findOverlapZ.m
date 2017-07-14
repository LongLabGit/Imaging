function [prob,UniB,t,xyz]=findOverlapZ(FinalC,brainC,mL,nT)
%for each burst within finalC2, find all other bursts that are within its
%time scale AND are within N microns
FCbID=[FinalC.bID];
%% inditialize vector with data about each burst
t=[];
cI=[];
bID=[];
s=[];
xyz=[];
%make an array of bursts
for b=1:length(FinalC)
    for ind=1:size(FinalC(b).bursts,1)
        t=[t,nanmean(FinalC(b).bursts(ind,:))];
        s=[s,nanmean(FinalC(b).Sburst(ind,:))];
        xyz=[xyz;FinalC(b).xyz];
        bID=[bID;FinalC(b).bID];
        cI=[cI,b];
    end
end
% phat = gamfit(s);
%% go through each burst and find out if there are other bursts that are similar
sameMat=zeros(length(bID));
maxD=0;
for b=1:length(t);
    Tdist=t(b)-t;
    cLoc=repmat(xyz(b,:),length(t),1);
    Ldist=sqrt(sum((cLoc-xyz).^2,2))';%euclidean distance between centers
    maxD=max([maxD,Ldist]);
    Tdist(b)=NaN;
    Ldist(b)=NaN;
    bothInrange=(abs(Tdist)<(s(b)*nT))&(Ldist<mL);
    sameMat(b,:)=bothInrange;%say that it is the same
    sameMat(:,b)=bothInrange';%say that the reverse is true (even though it doesnt need to be )
end
maxNsame=max(sum(sameMat))+1;
prob=cell(1,3*maxNsame);
prob(1,:)=repmat({'brainC Index','Plane', 'Cell Number'},1,maxNsame);
pI=2*ones(1,maxNsame);%allow for four overlapping cells 
sameMat=logical(sameMat);
iSM=find(sum(sameMat));
%%
for b=1:length(iSM)%for each bID that has overlap
    samebIDs=[bID(iSM(b)),bID(sameMat(:,iSM(b)))'];%find the bIDs, append onto it the original one
    bIDset{b}=sort(samebIDs);
    for bi=1:length(samebIDs)%for each bID
        indBrainC=FinalC(FCbID==samebIDs(bi)).inds;%find the brainC indices that correspond
        for ni=1:length(indBrainC);%for each corresponding brainC index
            prob{pI(bi),1+(bi-1)*3}=indBrainC(ni);
            prob{pI(bi),2+(bi-1)*3}=brainC(indBrainC(ni)).f;
            prob{pI(bi),3+(bi-1)*3}=brainC(indBrainC(ni)).cellN;
            pI(bi)=pI(bi)+1;
        end
    end
    pI=ones(1,maxNsame)*max(pI)+1;%update all pIs to mathc
end
a=uniquecell(bIDset);
UniB=a;
i=1;
while i<(length(UniB)-1)
    if ~isempty(intersect(UniB{i},UniB{i+1}))
        UniB{i}=union(UniB{i},UniB{i+1});
        UniB(i+1)=[];
        i=i-1;
    end
    i=i+1;
end


maxNsame=max(cellfun(@length,UniB));
prob=cell(1,3*maxNsame);
prob(1,:)=repmat({'brainC Index','Plane', 'Cell Number'},1,maxNsame);
pI=2*ones(1,maxNsame);%allow for four overlapping cells 
for b=1:length(UniB)
    samebIDs=UniB{b};
    for bi=1:length(samebIDs)%for each bID
        indBrainC=FinalC(FCbID==samebIDs(bi)).inds;%find the brainC indices that correspond
        for ni=1:length(indBrainC);%for each corresponding brainC index
            prob{pI(bi),1+(bi-1)*3}=indBrainC(ni);
            prob{pI(bi),2+(bi-1)*3}=brainC(indBrainC(ni)).f;
            prob{pI(bi),3+(bi-1)*3}=brainC(indBrainC(ni)).cellN;
            pI(bi)=pI(bi)+1;
        end
    end
    pI=ones(1,maxNsame)*max(pI)+1;%update all pIs to mathc
end
%% plot concept
% bL=iSM(1);%any element of ism
% figure(1);clf;
% Tdist=t(bL)-t;
% Ldist=sqrt(sum((repmat(xyz(bL,:),length(t),1)-xyz).^2,2))';%euclidean distance between centers
% Tdist(bL)=NaN;
% Ldist(bL)=NaN;
% plot(Tdist,Ldist,'o')
% patch([-s(bL),s(bL),s(bL)*nT,-s(bL)*nT],[0,0,max(Ldist),max(Ldist)],[.5,.5,.5],'FaceAlpha',.3)
% patch([min(Tdist),min(Tdist),max(Tdist),max(Tdist)],[0,mL,mL,0],[.5,.5,.5],'FaceAlpha',.3)
% xlabel('Distance in Time (s)')
% ylabel('Distance in Space (um)')
% title(['burst index  #', num2str(bL)])