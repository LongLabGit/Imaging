function [imgPlane,imgCells]=makeOverlayIndividual(f,UniB,FinalC,brainC)

% Load Locations of Planes, copy code from makeVolume
[L,~,dat]=xlsread([f,'XYZ.xlsx']);
Zplanes=cellfun(@num2str,dat(2:end,1),'UniformOutput',0);
ZXY=L(:,2:4);
[~,inds]=sort(ZXY(:,1),'descend');
ZXY=ZXY(inds,:);
Zplanes=Zplanes(inds);
%how wide to make the pane
morX=ceil(range(ZXY(:,2)));
morX=morX+abs((mod(morX,2)-1));%make it oddd
morY=ceil(range(ZXY(:,3)));
morY=morY+abs((mod(morY,2)-1));
proto=zeros(512+morX,512+morY);%proto version



% Find the indices of the ROIs in brainC inds
for ub=1:length(UniB)
%     prob_bIDs=UniB{ub};
%     FC_bID=[FinalC.bID];
%     BCinds=sort([FinalC(ismember(FC_bID,prob_bIDs)).inds]);
    BCinds=UniB{ub};
    planes={brainC(BCinds).f};
    planes=strrep(planes,f,'');%remove the folder name
    if strcmp(planes{1}(end),'\')
        planes=cellfun(@(x) x(1:end-1),planes,'UniformOutput',0);
    end

    filename=[f,'OverlapOverlayFigures\OverlapOverlay',num2str(ub),'.tif'];
    fprintf([num2str(ub/length(UniB),2),', '])

    % Make each plane
    indTiff=1;
    for p=1:length(Zplanes)
        A=proto;
        hasROI=strcmp(planes,Zplanes{p});
        if sum(hasROI)
            %not to use avg, but rather need the size of the plane to use BW
            %inds
            if ~exist([f,Zplanes{p},'\6-Full\Avg.tif'],'file')
                Y=tiff_reader_new([f,Zplanes{p},'\6-Full\Concatenated.tif']);
                plane=mean(Y,3);
                imwrite(uint16(plane),[f,Zplanes{p},'\6-Full\Avg.tif'],'TIF','compression','none')
            else
                plane=tiff_reader_new([f,Zplanes{p},'\6-Full\Avg.tif']);
            end
            plane=zeros(size(plane));%just need the size of it for indices
            bc_inds=BCinds(hasROI);
            for c=1:length(bc_inds)
                BW = brainC(bc_inds(c)).inds;
                plane(BW)=1;
            end
            off=ZXY(p,2:3);%offset  in x and y
            %start with a vector of all indices. add in the offset of the minumum
            [x,y]=size(plane);
            xind=(1:x)+round(off(1)+abs(min(ZXY(:,2))));
            yind=(1:y)+round(off(2)+abs(min(ZXY(:,3))));
            A(xind,yind)=plane;
            if indTiff == 1;
                imwrite(A,filename,'TIF','compression','none')
            else
                imwrite(A,filename,'TIF','WriteMode','append','compression','none')
            end
            imgPlane{indTiff}=Zplanes{p};
            imgCells{indTiff}=bc_inds;
            indTiff=indTiff+1;
        end
    end
end