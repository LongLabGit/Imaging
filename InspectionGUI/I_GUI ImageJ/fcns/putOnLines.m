function putOnLines(hObject,t)

handles=guidata(hObject);%reload data
try
    for i=1:4
        delete(handles.line(i))
    end
end

handles.line(1)=line(handles.audio,t*[1,1],[500 8000],'color','r');

if isempty(handles.roi_trace{handles.assignedR(1)})
    handles.line(2)=line(handles.roi1,t*[1,1],[0,handles.maxI],'color','r');
else
    handles.line(2)=line(handles.roi1,t*[1,1],[min(handles.roi_trace{handles.assignedR(1)}),max(handles.roi_trace{handles.assignedR(1)})],'color','r');
    ylim(handles.roi1,[min(handles.roi_trace{handles.assignedR(1)}),max(handles.roi_trace{handles.assignedR(1)})])
end
if isempty(handles.roi_trace{handles.assignedR(2)})
    handles.line(3)=line(handles.roi2,t*[1,1],[0,handles.maxI],'color','r');
else
    handles.line(3)=line(handles.roi2,t*[1,1],[min(handles.roi_trace{handles.assignedR(2)}),max(handles.roi_trace{handles.assignedR(2)})],'color','r');
    ylim(handles.roi2,[min(handles.roi_trace{handles.assignedR(2)}) max(handles.roi_trace{handles.assignedR(2)})])
end
if isempty(handles.roi_trace{handles.assignedR(3)})
    handles.line(4)=line(handles.roi3,t*[1,1],[0,handles.maxI],'color','r');
else
    handles.line(4)=line(handles.roi3,t*[1,1],[min(handles.roi_trace{handles.assignedR(3)}),max(handles.roi_trace{handles.assignedR(3)})],'color','r');
    ylim(handles.roi3,[min(handles.roi_trace{handles.assignedR(3)}),max(handles.roi_trace{handles.assignedR(3)})])
end


guidata(hObject,handles);