function [prob,UniB,t,xyz]=findOverlap(f,InitialC,ROIs,mL,nT,plotit)
%mL is the distance apart
%nT is the number of stds in time
%for each burst within finalC2, find all other bursts that are within its
%time scale AND are within N microns

if exist([f,'DiffROIsO.xlsx'],'file')
    Dsets=xlsread([f,'DiffROIsO.xlsx']);
else
    Dsets=[];
end

FCcID=[InitialC.cID];
% inditialize vector with data about each burst
t=[];cI=[];cID=[];s=[];xyz=[];
%make an array of bursts
for b=1:length(InitialC)
    for ind=1:size(InitialC(b).bursts,1)
        t=[t,nanmean(InitialC(b).bursts(ind,:))];
        s=[s,nanmean(InitialC(b).Sburst(ind,:))];
        xyz=[xyz;InitialC(b).xyz];
        cID=[cID;InitialC(b).cID];
        cI=[cI,b];
    end
end

% go through each burst and find out if there are other bursts that are similar
sameMat=zeros(length(cID));
for b=1:length(t);
    Tdist=t(b)-t;
    cLoc=repmat(xyz(b,:),length(t),1);%will break here is no location was assigned
    Ldist=cLoc-xyz;%simple xyz distance, 
    % here remove matches that you know are wrong
    % first dont let it match with itself
    Tdist(b)=NaN;
    Ldist(b,:)=NaN;
    %next dont let it match with cells on the 'DifferentCells' List
    %meh, just check the chart
    
    inRange=abs(Ldist)<=repmat(mL,size(Ldist,1),1);
    closeLoc=sum(inRange,2)==3;%close in all dimensions
    TandL=(abs(Tdist)<(s(b)*nT))&closeLoc';
    
    %a burst is due to a bunch of ROIs. when one is similar to another
    %burst, you need to check all the rois in the two. if we find a pair
    %that is in Diff ROIs we can throw out that burst
    Diff=zeros(size(TandL));
    if sum(TandL)
        TandL=TandL&~(cID==cID(b))';%make sure it isnt the same cell

        %need to transform from burst space to cID space and then to InitialC space. 
        cROIs=InitialC(cID(b)==FCcID).inds;
        pairedBursts=find(TandL);
        BurstcIDs=unique(cID(pairedBursts));
        ICindex=ismember(FCcID,BurstcIDs);
        pairedROIs={InitialC(ICindex).inds};
        if length(pairedBursts)>1%to make sure it doesnt catch a cell against itself
            for pb=1:length(pairedROIs)%for each burst that is paired with it
                pROIs=pairedROIs{pb};
                %now we have two sets of ROIs: pROIs and cROIs. see if any
                %of them are different from eachother. if so, pb index is
                %different. 
                for pr=1:length(pROIs)%get the rois that contributed to that burst
                    rm=Dsets(:,logical(sum(Dsets==pROIs(pr))));%find every column that that ROI is in
                    rm=unique(rm(~isnan(rm)));%find every ROI that it is different to
                    if any(ismember(rm,cROIs))
                        Diff(pairedBursts(pb))=1;
                    end
                end
            end
        end
    end
    sameMat(b,:)=TandL&~Diff;%say that it is the same
    sameMat(:,b)=TandL'&~Diff';%say that the reverse is true (even though it doesnt need to be )
end
sameMat=logical(sameMat);
iSM=find(sum(sameMat));
%%
cIDset={};
for b=1:length(iSM)%for each cID that has overlap
    samecIDs=[cID(iSM(b)),cID(sameMat(:,iSM(b)))'];%find the cIDs, append onto it the original one
    cIDset{b}=sort(samecIDs);
end

%Now we need to join sets. if a==b and b==c we want just one a==b==c. This
%is a slow looper that basically checks every cell against each next one.
%any time it gets a hit it starts over. slow but 
UniB=uniquecell(cIDset);
i=1;
while i<length(UniB)
    j=i+1;
    while j<=length(UniB)%check the 
        if ~isempty(intersect(UniB{i},UniB{j}))%if they have cells in common
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
    prob(1,:)=repmat({'bID','Plane', 'Cell Number'},1,maxNsame);
    pI=2*ones(1,maxNsame);%allow for four overlapping cells 
    for b=1:length(UniB)
        samecIDs=UniB{b};
        for bi=1:length(samecIDs)%for each cID
            indBrainC=InitialC(FCcID==samecIDs(bi)).inds;%find the brainC indices that correspond
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
% xlswrite([f,'PossibleOverlap.xlsx'],prob);
%% plot concept
if plotit
    bL=iSM(1);%any element of ism
    figure(1);clf;
    Tdist=t(bL)-t;
    Ldist=sqrt(sum((repmat(xyz(bL,:),length(t),1)-xyz).^2,2))';%euclidean distance between centers
    Tdist(bL)=NaN;
    Ldist(bL)=NaN;
    plot(Tdist,Ldist,'o')
    patch([-s(bL),s(bL),s(bL)*nT,-s(bL)*nT],[0,0,max(Ldist),max(Ldist)],[.5,.5,.5],'FaceAlpha',.3)
    patch([min(Tdist),min(Tdist),max(Tdist),max(Tdist)],[0,mL,mL,0],[.5,.5,.5],'FaceAlpha',.3)
    xlabel('Distance in Time (s)')
    ylabel('Distance in Space (um)')
    title(['burst index  #', num2str(bL)])
end