function drawROI(hObject,roiInd)

handles=guidata(hObject);%reload data

%Get ROI
fr=figure;
imagesc(handles.avgImg);
colormap gray
lowerPerc = get(handles.lowerImg,'Value');
upperPerc = 1-get(handles.upperImg,'Value');
right=handles.maxI-handles.rangeI*upperPerc;
left=handles.minI+handles.rangeI*lowerPerc;
set(gca,'clim',[left,right]);
BW = roipoly();
close(fr);

%Extract Trace

h=waitbar(0,'Extracting Trace');
for i=1:length(handles.imgT)
    img=double(handles.Img(:,:,i));
    handles.roi_trace{roiInd}(i)=mean(img(BW));
    waitbar(i/length(handles.imgT))
end
delete(h);
%get trace
axes(handles.imgAxes);hold on;
B = bwboundaries(BW);
B=B{1};
handles.roiShape{roiInd}=B;
try 
    delete(handles.roiShapePlot(roiInd))
end
handles.roiShapePlot(roiInd)=plot(handles.imgAxes,B(:,2), B(:,1), handles.C{roiInd}, 'LineWidth', 2);
guidata(hObject,handles);
