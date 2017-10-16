function plotROI(hObject,roiInd)
handles=guidata(hObject);%reload data
switch roiInd
    case 1
        axx=handles.roi1;
    case 2
        axx=handles.roi2;
    case 3
        axx=handles.roi3;
end            
try
    delete(handles.roiPlot(roiInd))
end
handles.roiPlot(roiInd)=plot(axx,handles.imgT,handles.roi_trace{roiInd},'color',handles.C{roiInd});
guidata(hObject,handles);
