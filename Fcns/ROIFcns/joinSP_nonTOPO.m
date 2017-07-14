function ROIs=joinSP_nonTOPO(f,ROIs,masterPlanes)

Ps={ROIs.f}';%planes
Cs=[ROIs.cellN]';%cells
masterPlanes=unique(strtok(strrep(masterPlanes,f,''),'\'));%find upper, main planes
for mpi=1:length(masterPlanes)%for each main plane
    mp=masterPlanes{mpi};%get main plane
    indMP=find(~cellfun(@isempty,regexp(Ps,mp)));%find the ROIs that are on any subplanes of this main plane
    subplanes=unique(Ps(indMP));%get the subplanes
    for spi=1:length(subplanes)%for each subplane
        sp=subplanes{spi};
        indSP=find(strcmp(Ps,sp));%find any cells on that subplane
        cells=Cs(indSP);
        indSP_other=setdiff(indMP,indSP);
        for c=1:length(cells)%for each cell
            matches=find(Cs(indSP_other)==cells(c));%find cells on the master plane WITH THE SAME NUMBER
            for m=1:length(matches)
                ROIs(indSP_other(matches(m))).cID=ROIs(indSP(c)).cID;%join them
                ROIs(indSP_other(matches(m))).joined=1;
                ROIs(indSP(c)).joined=1;
            end
        end
        
    end
end
disp(['Total Rois after joining subplanes:' num2str(length(unique([ROIs.cID])))])