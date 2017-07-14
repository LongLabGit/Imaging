function ccTimes=concatenateM_legacy(folder,tiffLocs)
%here we create a single motif with all of the images interleaved
fprintf('Concatenating all the images into one big image: ')
concat_name=[folder,'\8-Eftychios\Concatenated.tif'];
%go through each motif, adding it to the end of an array. then organize the
%times and use that to organize the tiff
pathloc=[folder,'\8-Eftychios\motifs\'];
%first create a huge array with all the images and all the times, but out
%of order
ccTimes=[];
motifTifs=dir([pathloc,'*.tif']);motifTifs={motifTifs(:).name};
indReport=floor((.1:.1:1)*length(motifTifs));
for m=1:length(motifTifs)
    ind=find(ismember(tiffLocs(:,2),motifTifs{m}));
    origT_name=[pathloc,tiffLocs{ind,2}];%the name/location of the tiff file
    origTobj= Tiff(origT_name,'r');%create a tiff object, only for reading
    for i=1:length(tiffLocs{ind,4})
        origTobj.setDirectory(i);
        img=origTobj.read();
        if (i==1)&&(m==1)%need to close it after the first time
            imwrite(uint16(img),concat_name,'TIF','compression','none')
        else
            imwrite(uint16(img),concat_name,'TIF','WriteMode','append','compression','none')
        end
    end
    tT=tiffLocs{ind,4};%times of the frames in that motif. only use warped data
    ccTimes=[ccTimes;tT];
    origTobj.close();
    if sum(indReport==m)
        fprintf([num2str(m/(length(motifTifs)),1),','])
    end
end
disp('Done')