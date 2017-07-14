function ShiftPixels(folder,shift,batch)
%if not obvious by its name, the purpose of this function is to correct for
%any scanImage linescan errors. There are two modes, batch and not. Start
%with batch=0, as it will take just the first tiff and only generate an
%average, which is much faster. once  you have the shift that you like,
%switch batch to 1 and let it go through all of them
pathloc=[folder,'1-Orig\'];
tiffFiles=dir(pathloc);
tiffFiles={tiffFiles.name};
tiffFiles=tiffFiles(3:end);
%first create the objects 

%check to see if there exists a folder already
% Write the new tiff
if batch
    tiffs=1:length(tiffFiles);
    if ~exist([folder,'2-OrigShifted'],'dir')
        mkdir([folder,'2-OrigShifted'])
    end
else
    tiffs=1;
    if ~exist([folder,'2a-ShiftedTests'],'dir')
        mkdir([folder,'2a-ShiftedTests'])
    end
end
for t=tiffs
    origT_name=[pathloc,tiffFiles{t}];%the name/location of the tiff file
    origTobj= Tiff(origT_name,'r');%create a tiff object, only for reading
    imf=imfinfo(origT_name);
    numI=length(imf);
    fileName=strtok(tiffFiles{t},'.');
    if batch%if you arent batching, label which one you are doing
        newT_name=[folder,'2-OrigShifted\',fileName,'.tif'];
    else
        fileName=[fileName,'s',num2str(shift)];
        newT_name=[folder,'2a-ShiftedTests\',fileName,'.tif'];
    end
    for f=1:numI
        origTobj.setDirectory(f);
        Itemp=origTobj.read();%initialize the temporary Image
        %shift the even ones only
        imageData=Itemp;
        s1=abs(shift);
        if shift>0
            imageData(2:2:512,1:(512-s1))=Itemp(2:2:512,(1+s1):512);
        else
             imageData(2:2:512,(1+s1):512)=Itemp(2:2:512,1:(512-s1));
        end
        if batch
            if f==1%need to close it after the first time
                imwrite(uint16(imageData),newT_name,'TIF','compression','none')
            else
                imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none')
            end
        else
            stack(:,:,f)=imageData;
        end
        if mod(round(f/numI*1000),100)==0
            fprintf([num2str(f/numI,2),','])
        end
    end
    origTobj.close();
end
if ~batch
    imageData=mean(stack,3);
    imwrite(uint16(imageData),newT_name,'TIF','compression','none')
end
disp('Done')