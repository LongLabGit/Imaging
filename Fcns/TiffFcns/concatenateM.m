function ccTimes=concatenateM(folder,Motif)
%here we create a single motif with all of the images interleaved
if ~exist([folder,'6-Full'],'dir')
    mkdir([folder,'6-Full'])
end
fprintf('Concatenating all the images into one big image: ')
concat_name=[folder,'6-Full\Concatenated.tif'];
%go through each motif, adding it to the end of an array. then organize the
%times and use that to organize the tiff
pathloc=[folder,'5-FinalMotifs\'];
%first create a huge array with all the images and all the times, but out
%of order
ccTimes=[];
indReport=floor((.1:.1:1)*(length(Motif)));
for m=1:length(Motif)
    origT_name=[pathloc,Motif(m).name];%the name/location of the tiff file
    origTobj= Tiff(origT_name,'r');%create a tiff object, only for reading
    for i=1:Motif(m).numI
        origTobj.setDirectory(i);
        img=origTobj.read();
        if (i==1)&&(m==1)%need to close it after the first time
            imwrite(uint16(img),concat_name,'TIF','compression','none')
        else
            imwrite(uint16(img),concat_name,'TIF','WriteMode','append','compression','none')
        end
    end
    tT=Motif(m).frameTimesWARP;%times of the frames in that motif. only use warped data
    ccTimes=[ccTimes;tT];
    origTobj.close();
    if sum(indReport==m)
        fprintf([num2str(m/(length(Motif)),1),','])
    end
end
Y=tiff_reader_new(concat_name);
avg=mean(Y,3);
imwrite(uint16(avg),[folder,'6-Full\Avg.tif'],'TIF','compression','none')
disp('Done')