function ShiftPixels2(iOrig,iNew,shift,iAVGnew)
%if not obvious by its name, the purpose of this function is to correct for
%any scanImage linescan errors. 
%

%check to see if there exists a folder already
origTobj= Tiff(iOrig,'r');%create a tiff object, only for reading
imf=imfinfo(iOrig);
numI=length(imf);
indY=2:2:512;
indX=1:512;
rm1=[(1:abs(shift))*sign(shift)+513,(1:abs(shift))*sign(shift)];
rm2=rm1-sign(shift)*(abs(shift)+1);
indX1=setdiff(indX,rm1);
indX2=setdiff(indX,rm2);
stack=[];
for f=1:numI
    origTobj.setDirectory(f);
    Itemp=origTobj.read();%initialize the temporary Image
    %shift the even ones only
    imageData=Itemp;
    imageData(indY,indX1)=Itemp(indY,indX2);
    if f==1%need to close it after the first time
        imwrite(uint16(imageData),iNew,'TIF','compression','none')
        stack=imageData;
    else
        imwrite(uint16(imageData),iNew,'TIF','WriteMode','append','compression','none')
        stack=stack+imageData;
    end
end
origTobj.close();
imageData=mean(stack,3);
imwrite(uint16(imageData),iAVGnew,'TIF','compression','none')