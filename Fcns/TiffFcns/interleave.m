function ilTimes=interleave(folder,Motif)
%here we create a single motif with all of the images interleaved
disp('Interleaving all the images into one big image')
interleave_name=[folder,'7-Full\Interleaved.tif'];
%go through each motif, adding it to the end of an array. then organize the
%times and use that to organize the tiff
pathloc=[folder,'6-FinalMotifs\'];
%first create a huge array with all the images and all the times, but out
%of order
indImage=1;
times=[];
disp(['reading'])
for m=1:length(Motif)
    origT_name=[pathloc,Motif(m).name];%the name/location of the tiff file
    origTobj= Tiff(origT_name,'r');%create a tiff object, only for reading
    tT=Motif(m).frameTimesWARP;%times of the frames in that motif. only use warped data
    times=[times;tT];
    for i=1:Motif(m).numI
        origTobj.setDirectory(i);
        bigDaddy(:,:,indImage)=origTobj.read();
        indImage=indImage+1;
    end
    origTobj.close();
    disp(num2str(m/length(Motif),3))
end
%then rearrange it according to times
[ilTimes,inds]=sort(times);
bigDaddy=bigDaddy(:,:,inds);%reorder Itemp in its space order
for ti=1:size(bigDaddy,3)
    if ti==1%need to close it after the first time
        imwrite(uint16(bigDaddy(:,:,ti)),interleave_name,'TIF','compression','none')
    else
        imwrite(uint16(bigDaddy(:,:,ti)),interleave_name,'TIF','WriteMode','append','compression','none')
    end
end