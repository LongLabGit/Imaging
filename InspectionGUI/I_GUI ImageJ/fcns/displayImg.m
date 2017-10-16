function displayImg(hObject,frame)
%set c limit
handles=guidata(hObject);
lowerPerc = get(handles.lowerImg,'Value');
upperPerc = 1-get(handles.upperImg,'Value');
right=handles.maxI-handles.rangeI*upperPerc;
left=handles.minI+handles.rangeI*lowerPerc;
left=min([left,right-.001]);

if frame>0
    if handles.imgPlot~=0
        delete(handles.imgPlot)
    end
    handles.imgPlot=imagesc(handles.imgAxes,handles.Img(:,:,frame));
    uistack(handles.imgPlot,'bottom')
    set(handles.imgAxes,'clim',[left,right]);
    colormap gray
    %fix slider
    set(handles.imgSelect,'Value',frame/length(handles.imgT));
else
    set(handles.imgAxes,'clim',[left,right]);
end

%put on rois
for i=1:length(handles.roiShape)
    B=handles.roiShape{i};
    if ~isempty(B)
        try
            delete(handles.roiShapePlot(i))
        end
        handles.roiShapePlot(i)=plot(handles.imgAxes,B(:,2), B(:,1), handles.C{i}, 'LineWidth', 2);
    end
end
guidata(hObject,handles);
