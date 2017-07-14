function Effect2Roi(ROIf,IMGf,t,cell)%% put on tiff

sROI=ReadImageJROI(ROIf);
sROI=[sROI{:}];
img=double(imread(IMGf));
img=(img-min(img(:)))/range(img(:))*9;
img(img>1.2)=1.2;
subplot(1,5,1:4)
imagesc(img)
colormap gray

colors=jet(256);
wi=round((t-min(t))/range(t)*255+1);
for i=1:length(wi)
    r=cell(i);
    numInList=sum(find(cell==r)<=i);
    offset=(numInList-1)*5;
    x=sROI(r).mnCoordinates(:,1)+offset;
    y=sROI(r).mnCoordinates(:,2);
    c=colors(wi(i),:);%do a transformation here if you;d like
    patch(x,y,c,'EdgeColor','none');
    text(x(1),y(1),num2str(find(sort(t)==t(i))),'color','r')
end
axis square
subplot(1,5,5)
y=(256:-1:1)/256*range(t)+min(t);
imagesc(1,y,flipud(reshape(colors,256,1,3)))
ylabel('Time of Burst')
set(gca,'xtick',[])