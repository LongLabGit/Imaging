function MotifsKept=resizeANDjoinSmall(folder,Motif,minLeft,maxLeft)
%Now we have a set of tiff files that correspond to motifs and we want to
%join them. before we do that we need to a) make them the same size and b)
%create a tiff od the avergages
tic;
disp('Beginning to resize all the SMALL motifs and create the average tiff')
if ~exist([folder,'3a-MotifsMin\'],'dir')
    mkdir([folder,'3a-MotifsMin\'])
    mkdir([folder,'4-Avgs\']);
end
%first create a cut down version of motif
%then make one file with the average of each
%first find the size of every file.
motifNames={Motif(:).name};
lens=zeros(1,length(motifNames));
wids=zeros(1,length(motifNames));
numM=length(motifNames);
indReport=unique(floor((.1:.1:1)*numM));
fprintf('Finding Sizes,')
for m=1:numM
    origT_name=[folder,'3-MotifsMotC\',motifNames{m}];%the name/location of the tiff file
    origT_obj = Tiff(origT_name,'r');%create a tiff object, only for reading
    lens(m)=origT_obj.getTag('ImageLength');%rows (first index)
    wids(m)=origT_obj.getTag('ImageWidth');%columns (second index). i.e. it would be [len,wid]=sizeimage)
    origT_obj.close();
    if sum(indReport==m)
        fprintf([num2str(m/numM,1),','])
    end
end
disp('Done')
%get the minimum of each. this will inform what size the final tiff will be
w=max(min(wids),minLeft);%the minimum size to accept
l=max(min(lens),minLeft);
avg_name=[folder,'4-Avgs\AVG.tif'];
fprintf('Cutting and Rewriting: ')
ind=1;
for m=1:length(motifNames)
    origT_name=[folder,'3-MotifsMotC\',motifNames{m}];%the name/location of the tiff file
    origT_obj = Tiff(origT_name,'r');%create a tiff object, only for reading
    a=origT_obj.getTag('ImageLength');%rows (first index)
    b=origT_obj.getTag('ImageWidth');%columns (second index). i.e. it would be [len,wid]=sizeimage)
    currSize=[a,b];
    %needs top be not too mution corrected, but small
    if (sum(currSize>minLeft)==2)&&(sum(currSize<maxLeft)==2)
        %first create a new set of cut motifs, where they are all the same size
        newT_name=[folder,'3a-MotifsMin\',motifNames{m}];%the name/location of the tiff file
        for i=1:Motif(m).numI
            origT_obj.setDirectory(i);
            imageData=origT_obj.read();
            %cut it down to minsize
            [lenI,widI]=size(imageData);
            dw1=floor((widI-w)/2)+1;%add half of the difference to the first index
            dw2=widI-dw1+round(mod((widI-w)+1,2));%remove what is left
            dl1=floor((lenI-l)/2)+1;
            dl2=lenI-dl1+round(mod((lenI-l)+1,2));
            imageData=imageData(dl1:dl2,dw1:dw2);
            %rewrite motifs to be the minimum size
            if i==1
                imwrite(uint16(imageData),newT_name,'TIF','compression','none')
            else
                imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none')
            end
            Itemp(:,:,i)=imageData;
        end
        origT_obj.close();%done with this file
        imageData=uint16(mean(Itemp,3));
        if m==1
            imwrite(imageData,avg_name,'TIF','compression','none')
        else
            imwrite(imageData,avg_name,'TIF','WriteMode','append','compression','none')
        end
    else
        tooMuchMot{ind}=motifNames{m};
        ind=ind+1;
    end
    if sum(indReport==m)
        fprintf([num2str(m/numM,1),','])
    end
end
disp('Done')
if ind>1
    fprintf('The following motifs have too much motion in them: ')
    MotifsKept=setdiff(motifNames,tooMuchMot)';
    disp(tooMuchMot)
else
    MotifsKept=motifNames;
end
totalT=toc;
disp(['Total Time: ',num2str(round(totalT/60)),' minutes'])
save([folder,'4-Avgs\MotifsKeptSmall.mat'],'MotifsKept');