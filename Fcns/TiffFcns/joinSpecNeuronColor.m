function numC=joinSpecNeuronColor(f,inputFPS,Motif,specParamslinewidth,cursorColor,offset,crop,spread,frameTimes,songOnly,cellsOnly)
%in this movie we color

%we will need a indexed list of frame numbers and pixels, color in the
%pixels (with a changing color) as the frame advances. we also need to know
%if we colored in this before, since we will then need to mix in colors

%Get your pixels and frame numbers
[~,ROInames]=xlsread([f,'ROIs\ROInames.xlsx'],'1:1');
onsetFrame=xlsread([f,'ROIs\ROInames.xlsx'],'2:2');
doneAlready=zeros(length(ROInames),1);
rois=ReadImageJROI([f,'ROIs\RoiSet.zip']);%need to make a way to find the correct ROI
rois=cell2mat(rois);
roiCells={rois(:).strName};
numC=length(rois)-length(setdiff(roiCells,ROInames));%all the cells that we 
%now create the pixels struct corresponding to the frame number
for i=1:length(ROInames)
    %check to see if the previous ROIname had a frame number
    if i>1
        if strcmp(ROInames(i),ROInames(i-1))
            doneAlready(i)=1;
        end
    end
    %get out the coordinates
    m=strcmp(ROInames(i),roiCells);
    if sum(m)==1
        x=rois(m).mnCoordinates(:,1);
        y=rois(m).mnCoordinates(:,2);
        %create a grid
        [X,Y] = meshgrid(min(x):max(x),min(y):max(y));
        x1=X(:);y1=Y(:);
        IN=inpolygon(x1,y1,x,y);
        pixels(i).x=x1(IN);
        pixels(i).y=y1(IN);
    end
end

%Now turn it into a movie
%video objects
fileIn=[f,'7-Full\Movies\ImageJ\',num2str(inputFPS),'FPS_NoAudio.avi'];
obj = VideoReader(fileIn);
w=get(obj,'Width');
h=get(obj,'Height');
numFrames=get(obj,'NumberOfFrames');%get the number of frames. this doesnt work for the vision reader
clear obj;
vR=vision.VideoFileReader(fileIn);
aviName=[f,'7-Full\Movies\SpecNeuron\',num2str(inputFPS),'Colored'];
imageName=[f,'7-Full\Movies\SpecNeuron\',num2str(inputFPS),'Final'];
if songOnly
    aviName=[aviName,'Song'];
    imageName=[imageName,'Song'];
end
if cellsOnly
    aviName=[aviName,'Cells'];
    imageName=[imageName,'Cells'];
end
aviName=[aviName,'.avi'];
imageName=[imageName,'.jpg'];
vW=vision.VideoFileWriter(aviName);
vW.FrameRate=inputFPS;

%sonogram
sonogramH=round(h/2);%the height of the sonogram
Fs=4e4;
F=linspace(500,1e4,sonogramH);%frequency range
if ~isempty(crop)
    Motif=Motif(crop);
end
[~,~,T,P]= spectrogram(Motif,384,256,F,Fs);
spec=fliplr(10*log10(abs(P))');
newT1=linspace(min(T),max(T),w);
spec2=interp1(T,spec,newT1);
cmap=jet(256);
cmap(1,:)=[0,0,0];%convert the 0 to black
Specrange=max(max(spec))-min(min(spec));
sonogram=real2rgb(spec2',cmap,[min(min(spec))+Specrange*offset(1),min(min(spec))+Specrange*offset(2)]);
newT=newT1-spread(1)+crop(1)/Fs;%offset the song by the appropriate amount'
%make your line locations and colors
for i=1:length(frameTimes)
    [~,l1]=min(abs(newT-frameTimes(i)));
    if (l1+linewidth-1)<w
        lineLoc(i,:)=l1:(l1+linewidth-1);
    else
        lineLoc(i,:)=(l1-linewidth+1):l1;
    end
end
cursor=repmat(cursorColor,sonogramH,1,linewidth);%make thicker
cursor = permute(cursor,[1,3,2]);

[~,songStart]=min(abs(newT(1)-frameTimes));
songStart=songStart-1;%shift back one to account for transmission delay in neuron
[~,songEnd]=min(abs(newT(end)-frameTimes));
%colors
if songOnly
    colors=jet(songEnd-songStart+1);
    buff=zeros(songStart-1,3);
    %add a buffer to it so that the first one is in the right place
    colors=[buff;colors];
else
    colors=jet(numFrames);
end

%scale for undersneath the spectrogram
songC=colors(songStart:songEnd,:);
newl=linspace(1,size(songC,1),w);
scale=interp1(1:size(songC,1),songC,newl);
scale=repmat(scale,1,1,4);
scale=permute(scale,[3,1,2]);
%cut down to only song if we dont want the outside
if songOnly
    bad=((onsetFrame<songStart)|(onsetFrame>songEnd));
    onsetFrame(bad)=[];
    pixels(bad)=[];
    doneAlready(bad)=[];
end
for i=1:numFrames
    frame=step(vR);
    if cellsOnly%if we only want to see the cells, clear out neuron image and make it all black
        frame=zeros(size(frame));
    end
    cellOn=find(onsetFrame<=i);
    for r=1:length(cellOn)
        ind=cellOn(r);
        x=pixels(ind).x;
        y=pixels(ind).y;
%         if doneAlready(ind)
%             %half of it
% %             mid=(max(x)-min(x))/2+min(x);%if we already had it, cut it in half
% %             portion=x>mid;
%             %interleave
%             portion=logical(mod(x,2));
%             x=x(portion);
%             y=y(portion);
%         end
        for p=1:length(y)
            frame(y(p),x(p),:)=colors(onsetFrame(ind),:)';
        end
    end
   
    %add the cursor to the sonogram
    sT=sonogram;
    if sum(onsetFrame==i)%if we have a point here, drop a line
        %make a colored line on the sonogram
        newLine=repmat(colors(i,:),sonogramH,1,linewidth);
        newLine=permute(newLine,[1,3,2]);
        sT(:,lineLoc(i,:),:)=newLine;
        sonogram(:,lineLoc(i,:),:)=newLine;
    elseif (i>=songStart)&&(i<=songEnd)
        sT(:,lineLoc(i,:),:)=cursor;
    else
        sT=sonogram;
    end
    a=cat(1,scale,frame);
    a=cat(1,sT,a);
    step(vW,a);
    imshow(a);
end
release(vR)
release(vW);
%now in the last stage just write an image of just the last frame
imshow(a);
export_fig(imageName);