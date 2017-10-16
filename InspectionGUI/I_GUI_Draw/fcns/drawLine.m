function drawLine(~,eventdata,hObject)
a=eventdata.IntersectionPoint(1);
putOnLines(hObject,a)
handles=guidata(hObject);
[~,frame]=min(abs(handles.imgT-a));
displayImg(handles,frame)