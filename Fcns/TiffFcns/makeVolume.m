function makeVolume(f)
[L,~,dat]=xlsread([f,'XYZ.xlsx']);
planes=cellfun(@num2str,dat(2:end,1),'UniformOutput',0);
ZXY=L(:,2:4);
[~,inds]=sort(ZXY(:,1),'descend');
ZXY=ZXY(inds,:);
planes=planes(inds);
morX=ceil(range(ZXY(:,2)));
morX=morX+abs((mod(morX,2)-1));
morY=ceil(range(ZXY(:,3)));
morY=morY+abs((mod(morY,2)-1));
proto=zeros(512+morX,512+morY);
filename='Zstack.tif';
%%
for p=1:length(planes)
    fprintf([num2str(p/length(planes),2),', '])
    if ~exist([f,planes{p},'\6-Full\Avg.tif'],'file')
        Y=tiff_reader_new([f,planes{p},'\6-Full\Concatenated.tif']);
        avg=mean(Y,3);
        imwrite(uint16(avg),[f,planes{p},'\6-Full\Avg.tif'],'TIF','compression','none')
    else
        avg=tiff_reader_new([f,planes{p},'\6-Full\Avg.tif']);
    end
    A=proto;
    [x,y]=size(avg);
    off=ZXY(p,2:3);
    xind=(1:x)+round(off(1)+abs(min(ZXY(:,2))));%start with a vector of all indices. add in the offset of the minumum
    yind=(1:y)+round(off(2)+abs(min(ZXY(:,3))));
    A(xind,yind)=avg;
    %Because three-dimensional data is not supported for GIF files, call rgb2ind to convert the RGB data in the image data, im, to an indexed image, A, with a colormap, map. C
	if p == 1;
      imwrite(uint16(A),filename,'TIF','compression','none')
% 		imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(uint16(A),filename,'TIF','WriteMode','append','compression','none')
% 		imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
	end
end