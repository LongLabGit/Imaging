function selectROI(hObject,roi)

handles=guidata(hObject);

[x,y]=ginput(1);
d=pdist2(handles.roiCents,[x,y]);
[~,r]=min(d);

oldR=handles.assignedR(roi);
set(handles.roi_plot(oldR),'color','y');%swap out the previous one

handles.roiSel(roi)=r;
handles.curSel=roi;
handles.assignedR(roi)=r;

set(handles.roi_plot(r),'color',handles.C{roi});%color it
guidata(hObject,handles);
plotROI(hObject,roi,r);

