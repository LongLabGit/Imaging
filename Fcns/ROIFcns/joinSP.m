function ROIs=joinSP(folder,ROIs,subplanes)

Ps={ROIs.f}';
Cs=[ROIs.cellN]';
for spi=1:length(subplanes)
    sp=subplanes{spi};
    [~,~,raw]=xlsread([folder,sp,'\LookUpTable.xlsx'],'Sheet2');
    cells=cell2mat(raw(2:end,:));
    sbs=cellfun(@num2str,raw(1,:),'UniformOutput',0);
    rm=isnan(cells);rm=sum(rm)==size(rm,1);
    sbs(rm)=[];
    cells(:,rm)=[];
    %find all indices
    BCspInds=cell(length(sbs),1);%the indices in ROIs corresponding to the subplanes in that plane
    for s=1:length(sbs)
%         f2=strrep(folder,'192bis\','');
        BCspInds{s}=find(strcmp(Ps,[f2,sp,'\',sbs{s},'\']));%get the index in brain that corresponses to each subplane
        if isempty(BCspInds{s})
            disp(['No active ROIs found in ' sp ', subplane #', sbs{s}])
        end
    end
    if isempty(cells)
        disp(['Coregister data not validated by Michel: ',sp])
    end
    for c=1:size(cells,1)%for each set of ROIs (every row is a single cell)
        indSame=find(cells(c,:));
        if length(indSame)>1%is it a set or just one?
            %if there is more than one, assign the unique ID from the first
            %one to all the rest.
            indBC=intersect(BCspInds{indSame(1)},find(Cs==cells(c,indSame(1))));
            if ~isempty(indBC)
                ID=ROIs(indBC).cID;%the ID to transfer
                ROIs(indBC).joined=1;
                %note that it is joint
                for is=2:length(indSame)
                    indBC=intersect(BCspInds{indSame(is)},find(Cs==cells(c,indSame(is))));
                    if ~isempty(indBC)
                        ROIs(indBC).cID=ID;%replace it
                        ROIs(indBC).joined=1;
                    else
                        %i.e. we never collected that data in the first place
    %                     disp(['Missing ', folder,sp,'\',sbs{indSame(is)},', cell# ',num2str(cells(c,indSame(is)))]);
                    end
                end
            else
                disp(['Extra cells found in subplane ',sp,'. Do not put this information here'])
            end
        end
    end
end
disp(['Total Rois after joining subplanes:' num2str(length(unique([ROIs.cID])))])