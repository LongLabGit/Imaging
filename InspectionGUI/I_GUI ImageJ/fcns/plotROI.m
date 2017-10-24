function plotROI(hObject,roiSel,r)
handles=guidata(hObject);%reload data
switch roiSel
    case 1
        axx=handles.roi1;
    case 2
        axx=handles.roi2;
    case 3
        axx=handles.roi3;
end            
try
    delete(handles.roiPlot(roiSel))
end
handles.roiPlot(roiSel)=plot(axx,handles.imgT,handles.roi_trace{r},'color',handles.C{roiSel});
ylim(axx,[min(handles.roi_trace{r}),max(handles.roi_trace{r})])
guidata(hObject,handles);
