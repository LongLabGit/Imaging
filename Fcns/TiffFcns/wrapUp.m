function Times=wrapUp(folder,Motif,binSize,ILtimes,keepEdges)

%TIMES
%get the times of your individual motifs
Times=struct;
xloc=[];
for m=1:length(Motif)
    eval(['Times.m',strtok(Motif(m).name,'.'),'=Motif(m).frameTimesWARP;']);
    xloc=[xloc;Motif(m).frameTimesWARP];
end
%do your averaged movie
cuts=min(xloc):binSize:max(xloc);
timeAvg=cuts(1:end-1)+binSize/2;
id=strrep(num2str(binSize*1000,3),'.','_');%replace all .s with _s (structs cant handle another .)
eval(['Times.avg',id,'=timeAvg;']);
%store the interleaved one
Times.Interleaved=ILtimes;

%TIFS
y1=keepEdges(1,1);
x1=keepEdges(1,2);
y2=keepEdges(2,1);
x2=keepEdges(2,2);
%crop the average
origT_name=[folder,'7-Full\All0.0348.tif'];
newT_name=[folder,'8-Eftychios\All34_8.tif'];
origT_obj= Tiff(origT_name,'r');%create a tiff object, only for reading
for i=1:length(timeAvg)
    origT_obj.setDirectory(i);
    imageData=origT_obj.read();
    imageData=imageData(x1:x2,y1:y2);
    if i==1
        imwrite(uint16(imageData),newT_name,'TIF','compression','none');
    else
        imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none');
    end
end
origT_obj.close();
%crop the motifs
for m=1:length(Motif(m).name)
    origT_name=[folder,'6-FinalMotifs\',Motif(m).name];
    newT_name=[folder,'8-Eftychios\motifs\',Motif(m).name];
    origT_obj= Tiff(origT_name,'r');%create a tiff object, only for reading
    for i=1:motifLengths(m)
        origT_obj.setDirectory(i);
        imageData=origT_obj.read();
        imageData=imageData(x1:x2,y1:y2);
        if i==1
            imwrite(uint16(imageData),newT_name,'TIF','compression','none');
        else
            imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none');
        end
    end
    origT_obj.close();
end
%crop the interleaved
origT_name=[folder,'7-Full\Interleaved.tif'];
newT_name=[folder,'8-Eftychios\Interleaved.tif'];
origT_obj= Tiff(origT_name,'r');%create a tiff object, only for reading
for i=1:length(ILtimes)
    origT_obj.setDirectory(i);
    imageData=origT_obj.read();
    imageData=imageData(x1:x2,y1:y2);
    if i==1
        imwrite(uint16(imageData),newT_name,'TIF','compression','none');
    else
        imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none');
    end
end
origT_obj.close();
%crop the interleaved
origT_name=[folder,'7-Full\Concatenated.tif'];
newT_name=[folder,'8-Eftychios\Concatenated.tif'];
origT_obj= Tiff(origT_name,'r');%create a tiff object, only for reading
for i=1:length(ccTimes)
    origT_obj.setDirectory(i);
    imageData=origT_obj.read();
    imageData=imageData(x1:x2,y1:y2);
    if i==1
        imwrite(uint16(imageData),newT_name,'TIF','compression','none');
    else
        imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none');
    end
end
origT_obj.close();