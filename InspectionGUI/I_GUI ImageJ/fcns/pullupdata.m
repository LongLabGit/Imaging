function pullupdata(hObject)

handles=guidata(hObject);%reload data
%load in abf file
[wav,fs,imgT]=alignAudioImgs(handles.abfF,handles.imgF);
set(handles.imgSelect, 'SliderStep',[1/length(imgT),10/length(imgT)]);%step size should be one image
handles.imgT=imgT;%EVERYTHING IS IN SECONDS
handles.wav=wav;
handles.fs=fs;
axes(handles.audio);cla;hold on
vigiSpec(wav,fs,500:5:8e3,.6,512,384,[],1);
set (handles.audio, 'ButtonDownFcn', {@drawLine,hObject});
linkaxes([handles.audio handles.roi1 handles.roi2 handles.roi3], 'x'); %Link axes
axis tight
xlim([0,length(wav)/fs])
guidata(hObject,handles);
%load in image file
tObj= Tiff(handles.imgF,'r');%create a tiff object, only for reading
handles.tObj=tObj;

%LOAD IN IMAGE DATA
h=waitbar(0,'Loading Image Data');
for i=1:length(imgT)
    tObj.setDirectory(i);%change the IFD to first image
    ii= tObj.read();%get the image
    handles.Img(:,:,i)=double(ii);
    waitbar(i/length(imgT))
end
delete(h);
handles.maxI=double(prctile(handles.Img(:),99.9));
handles.minI=double(prctile(handles.Img(:),.1));
handles.rangeI=handles.maxI-handles.minI;
handles.avgImg=mean(double(handles.Img),3);
guidata(hObject,handles);
displayImg(hObject,1)
ylim(handles.roi1,[0,handles.maxI])
ylim(handles.roi2,[0,handles.maxI])
ylim(handles.roi3,[0,handles.maxI])
axis off