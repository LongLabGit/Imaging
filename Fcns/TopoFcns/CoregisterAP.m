function [prob,UniB]=CoregisterAP(f,ROIs,mL)

%for each burst within finalC2, find all other bursts that are within its
%time scale AND are within N microns
cID=[ROIs.cID];%list of cIDs for each roi.
xyz=vertcat(ROIs.xyz);
if exist([f,'DiffROIs.xlsx'],'file')
    Dsets=xlsread([f,'DiffROIs.xlsx']);
else
    Dsets=[];
end
%% go through each burst and find out if there are other bursts that are similar
sameMat=zeros(length(xyz));
for b=1:length(xyz);
    cLoc=repmat(xyz(b,:),length(xyz),1);%will break here is no location was assigned
    Ldist=cLoc-xyz;%simple xyz distance, 
    % first dont let it match with itself
    Ldist(b,:)=NaN;
    inRange=abs(Ldist)<=repmat(mL,size(Ldist,1),1);
    closeLoc=(sum(inRange,2)==3);%;%close in all dimensions
    Diff=zeros(size(closeLoc));
    if ~isempty(Dsets)
        if sum(Dsets(:)==b)
            rm=Dsets(:,logical(sum(Dsets==b)));%find every column that that ROI is in
            rm=unique(rm(~isnan(rm)));%find every ROI that it is different to
            Diff(rm)=1;
        end
    end
    sameMat(b,:)=closeLoc&~Diff;%say that it is the same
    sameMat(:,b)=closeLoc'&~Diff';%say that the reverse is true (even though it doesnt need to be )
end
sameMat=logical(sameMat);
%same mat now represents a logical matrix, each element representing
%whether or not that pair is close;
iSM=find(sum(sameMat));%iSM is the list of cells that are suspect
%%
cIDset=cell(length(iSM),1);
for b=1:length(iSM)%for each cell that is suspected to overlap with others
    samecIDs=[cID(iSM(b)),cID(sameMat(:,iSM(b)))];%find the bIDs, append onto it the original one
    cIDset{b}=unique(samecIDs);
end
nS=cellfun(@length,cIDset);
cIDset(nS<2)=[];
%Now we need to join sets. if a==b and b==c we want just one a==b==c. This
%is a slow looper that basically checks every cell against each next one.
%any time it gets a hit it starts over. slow but 
UniB=uniquecell(cIDset);
i=1;
while i<length(UniB)
    j=i+1;
    while j<=length(UniB)%check the 
        overlapC=intersect(UniB{i},UniB{j});%set contains similar cells
        if ~isempty(overlapC)%if they have cells in common
            UniB{i}=union(UniB{i},UniB{j});%join them
            UniB(j)=[];%remove the other one
            i=0;%reset the looper to start checking all over again
            break;%break out and start over
        else
            j=j+1;
        end
    end
    i=i+1;
end

%now turn it into a excel ready peice of data
maxNsame=max(cellfun(@length,UniB));
prob=cell(1,3*maxNsame);
if ~isempty(maxNsame)
    prob(1,:)=repmat({'brainC Index','Plane', 'Cell Number'},1,maxNsame);
    pI=2*ones(1,maxNsame);%allow for four overlapping cells 
    for b=1:length(UniB)
        samecIDs=UniB{b};
        for bi=1:length(samecIDs)%for each bID
            indBrainC=find(cID==samecIDs(bi));%find the brainC indices that correspond
            for ni=1:length(indBrainC);%for each corresponding brainC index
                prob{pI(bi),1+(bi-1)*3}=indBrainC(ni);
                prob{pI(bi),2+(bi-1)*3}=ROIs(indBrainC(ni)).f;
                prob{pI(bi),3+(bi-1)*3}=ROIs(indBrainC(ni)).cellN;
                pI(bi)=pI(bi)+1;
            end
        end
        pI=ones(1,maxNsame)*max(pI)+1;%update all pIs to mathc
    end
end