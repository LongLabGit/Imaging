function [tiffIDs,mTimes]=makeMovieTif(folder,binSize,groupOpt,Motif)
% This will make a movie tiff by averging across motifs
%tiffIDs is just helpful debugging stuff
%mTimes
fprintf('Averaging them together to create one high resolution tiff: ') 
if ~exist([folder,'6-Full'],'dir')
    mkdir([folder,'6-Full'])
end
%if you didnt give a binsize, do the same binSize as the original (elect to
%improve the spatial resolution)
%join the warped times for each frame for each motif
if isempty(binSize)
    t=[];
    for i=1:length(Motif)
        t=[t;Motif(i).frameTimesWARP];
    end
    d=diff(t);d(d<0)=[];
    binSize=mean(d);%this will make it the average of your bins, similar to what you imaged at, but account for warping
end
%if we leave it empty then it means we want all of them
newT_name=[folder,'6-Full\All',num2str(binSize,3),'.tif'];

xloc=sort(vertcat(Motif(:).frameTimesWARP));
cuts=min(xloc):binSize:(max(xloc)+binSize);
mTimes=(cuts(1:end-1)+cuts(2:end))/2;%the center of each bin
%first create the objects 
pathloc=[folder,'5-FinalMotifs\'];
for m=1:length(Motif)
    origT_name=[pathloc,Motif(m).name];%the name/location of the tiff file
    TiffObjs(m)= Tiff(origT_name,'r');%create a tiff object, only for reading
end
% Write the new tiff
numImage=zeros(length(cuts)-1,1);%initialize the bin counter
indReport=floor((.1:.1:1)*(length(cuts)-2));
for c=1:length(cuts)-2%dont do the last file because its usually very few in the last bin
    clear Itemp times ts;
    %initialize the parameters for this bin
    time_range=[cuts(c),cuts(c+1)];%get the time range of our bin
    indImage=1;%initialize the image counter
    %go through each motif/new tiff and find out if it had any 
    for m=1:length(Motif)
        tT=Motif(m).frameTimesWARP;%times of the tiffs in that motif.
        tiffs2take=find(tT>=time_range(1)&tT<time_range(2));
        if ~isempty(tiffs2take)
            for t2t=1:length(tiffs2take)
                TiffObjs(m).setDirectory(tiffs2take(t2t));
                Itemp(:,:,indImage)=TiffObjs(m).read();
                ts(indImage,:)=[m,tiffs2take(t2t)];%the motif and its index
                times(indImage)=tT(tiffs2take(t2t));%te time of that motif's index (we dont care which motif)
                indImage=indImage+1;
            end
        end
    end
    tiffIDs{c}=ts;%for every frame, we should know what motifs went into it
    numImage(c)=indImage-1;%number of images in that bin
    %now combine it
    switch groupOpt
        case 'avg'
            imageData=mean(Itemp,3);
        case 'median'
            imageData=median(Itemp,3);
        case 'max'
            imageData=max(Itemp,[],3);
        case 'std'
            imageData=std(Itemp,0,3);
        case 'CoVar'
            imageData=std(Itemp,0,3)./mean(Itemp,0,3);%http://en.wikipedia.org/wiki/Coefficient_of_variation
    end
    if c==1%need to close it after the first time
        imwrite(uint16(imageData),newT_name,'TIF','compression','none')
    else
        imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none')
    end
    if sum(indReport==c)
        fprintf([num2str(c/(length(cuts)-2),2),','])
    end
end
%close them
for m=1:length(Motif)
    TiffObjs(m).close();
end
disp('Done')