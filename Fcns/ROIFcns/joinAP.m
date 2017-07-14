function ROIs=joinAP(folder,ROIs)


%this will join across planes
Ps={ROIs.f}';%planes
Cs=[ROIs.cellN]';%cells
fxs=[folder,'SameCells.xlsx'];
[~,~,raw]=xlsread(fxs);
planes=cellfun(@num2str,raw(1,:),'UniformOutput',0);
cells=cell2mat(raw(2:end,:));
rm1=sum(isnan(cells),1)==size(cells,1);
cells(:,rm1)=[];
planes(rm1)=[];
rm2=sum(isnan(cells),2)==size(cells,2);
cells(rm2,:)=[];
cells(isnan(cells))=0;%remove nans

BCspInds=cell(1,length(planes));
for s=1:length(planes)%for each plane, 
    BCspInds{s}=find(strcmp(Ps,[folder,planes{s},'\']));%find the planes corresponding to it
    if isempty(BCspInds{s})%if 
        disp(['no active cells in plane ',planes{s}, ' anway. Why Bother?'])
    end
end
for c=1:size(cells,1);%for each cell
    indSame=find(cells(c,:));% the index of all the cells that are the same
    if length(indSame)>1%is it a set or just one?
        %if there is more than one, assign the unique ID from the first
        %one to all the rest.
        good=1;%the index of the same cells
        sameCN=find(Cs==cells(c,indSame(good)));%the brainC index that has the same cell number 
        sameP=BCspInds{indSame(good)};%the brainC indexs that has the same plane name
        indBC=intersect(sameP,sameCN);
        %step through the rois until you find one that is in brainC
        while isempty(indBC)&&good<length(indSame)
            %note that we are missing it
            %This is a cell noted to be similar to another cell. but that
            %cell was not active
%             disp(['Non active, only using for topography:  ',planes{indSame(good)},', cell# ',num2str(cells(c,indSame(good)))]);
            %increase index
            good=good+1;
            indBC=intersect(BCspInds{indSame(good)},find(Cs==cells(c,indSame(good))));
        end
        if ~isempty(indBC)
            ID=ROIs(indBC).cID;%the ID to transfer
            joinedB4=ROIs(indBC).joined;
            ROIs(indBC).joined=1;            %note that it is joined
            indOrig=indBC;%the index to transfer
            hadOther=0;
            %
            for is=(good+1):length(indSame)
                indBC=intersect(BCspInds{indSame(is)},find(Cs==cells(c,indSame(is))));
                if ~isempty(indBC)
                    if ROIs(indBC).joined
                        oldID=ROIs(indBC).cID;
                        ids=([ROIs.cID]==oldID);%get all that have the previos ID
                        [ROIs(ids).cID]=deal(ID);
                    else
                        ROIs(indBC).cID=ID;%replace it
                        ROIs(indBC).joined=1;
                    end
                    hadOther=1;
                else
                    %similar as above
%                     disp(['Non active, only using for topography:  ',planes{indSame(is)},', cell# ',num2str(cells(c,indSame(is)))]);
                end
            end
            if hadOther==0&&~joinedB4
                ROIs(indOrig).joined=0;
            end
        end
    end
end
disp(['Total Rois after joining across planes:' num2str(length(unique([ROIs.cID])))])