function loadROIS(hObject)

handles=guidata(hObject);
if ~isempty(handles.roiF)
    rois=ReadImageJROI([handles.roiF]);
    rois=cell2mat(rois);
    h=waitbar(0,'Extracting ROIs');
    for r=1:length(rois)
        handles.patch{r}=rois(r).mnCoordinates;
        handles.roiCents(r,1:2)=mean(rois(r).mnCoordinates,1);
        BW = poly2mask(handles.patch{r}(:,1),handles.patch{r}(:,2),size(handles.Img,1),size(handles.Img,2));
        for i=1:length(handles.imgT)
            img=handles.Img(:,:,i);
            handles.roi_trace{r}(i)=mean(img(BW));
        end
        handles.roi_plot(r)=plot(handles.imgAxes,handles.patch{r}(:,1),handles.patch{r}(:,2),'y');
        waitbar(r/length(rois))
    end
    axis(handles.imgAxes,'tight');
    axis(handles.imgAxes,'off');
    guidata(hObject,handles)
    delete(h)

end