 function Motif=CutUpTiffs(folder,Motif)
%next step is to cut all the motifs out of the original tiffs. this is
%pretty straight forward. if you would like the motifs to be longer you
%need to change it all the way at ExtractFromAbf.m
if ~exist([folder,'2-Motifs'],'dir')
    mkdir([folder,'2-Motifs'])
end
%Make sure that you have all the files you need in orig
haveTif=dir([folder,'1-Orig\*.tif']);
haveTif={haveTif.name};
haveAbf=unique({Motif.Origname});
missingTif=setdiff(haveAbf,haveTif);
if ~isempty(missingTif)
    error(['Missing ' missingTif{:}])
end

%find all the files in the folder orig shifted. go through each, finding
%any motifs that might be in them (as found in the Motif struct)
indReport=round((.1:.1:1)*length(Motif));
totalM=length(Motif);
if isempty(gcp('nocreate'))
    parpool;%start a parallel pool if we dont have one
end
parfor m=1:totalM
    origT_name=[folder,'1-Orig\',Motif(m).Origname];%the name/location of the tiff file
    origT_obj = Tiff(origT_name,'r');%create a tiff object, only for reading
    %the motif m that is bird is singing is temporally located between
    motifRange=Motif(m).frames;
    newT_name=[folder,'2-Motifs\',Motif(m).name];%create the motif file
    for f=motifRange(1):motifRange(2)
        if ~origT_obj.lastDirectory
            origT_obj.setDirectory(f);%change the IFD
            imageData = origT_obj.read();%get the image
            if f==motifRange(1)
                imwrite(uint16(imageData),newT_name,'TIF','compression','none')
            else
                imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none')
            end
        else
            Motif(m).frames(end)=f-1;
            disp(['needed to truncate ',Motif(m).name,' because the tiff ended early!', ...
                'I updated Motif so you needed to save it again'])
        end
    end
    origT_obj.close();%done with this file
    if sum(indReport==m)
        fprintf([num2str(m/totalM,2),',']);
    end
end
delete(gcp);
disp('Done')