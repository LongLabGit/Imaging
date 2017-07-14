folder='Data\102\CorrectedPlanes\';
a=dir(folder);
isFold=[a(:).isdir];
a=a(isFold);
planes={a(3:end).name};
planes=sort_nat(planes);
planes=planes(1:end-1);%remove oldplanes
%first get minimum size
for p=1:length(planes)
    origT_name=[folder,'3-MotifsMotC\',motifNames{m}];%the name/location of the tiff file
    origT_obj = Tiff(origT_name,'r');%create a tiff object, only for reading
    a=origT_obj.getTag('ImageLength');%rows (first index)
    b=origT_obj.getTag('ImageWidth');%columns (second index). i.e. it would be [len,wid]=sizeimage)
    currSize=[a,b];
end
%then go through each one and take the avg of their average
%first create a new set of cut motifs, where they are all the same size
newT_name=[folder,'3a-MotifsMin\',motifNames{m}];%the name/location of the tiff file
for p=1:length(planes)
    for i=1:Motif(m).numI
        origT_obj.setDirectory(i);
        imageData=origT_obj.read();
        if i==1
            Itemp=imageData;
        else
            Itemp=Itemp+imageData;
        end
    end
    imageData=uint16(mean(Itemp,3));
    [lenI,widI]=size(imageData);
    dw1=floor((widI-w)/2)+1;%add half of the difference to the first index
    dw2=widI-dw1+round(mod((widI-w)+1,2));%remove what is left
    dl1=floor((lenI-l)/2)+1;
    dl2=lenI-dl1+round(mod((lenI-l)+1,2));
    imageData=imageData(dl1:dl2,dw1:dw2);
    if p==1
        imwrite(imageData,avg_name,'TIF','compression','none')
    else
        imwrite(imageData,avg_name,'TIF','WriteMode','append','compression','none')
    end

end