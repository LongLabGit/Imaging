function [N,planes,cells,MPP]=initializeTopo(f)
fxs=[f,'SameCells.xlsx'];
[~,~,raw]=xlsread(fxs);
planes=cellfun(@num2str,raw(1,:),'UniformOutput',0);
cells=cell2mat(raw(2:end,:));
cells(isnan(cells))=0;%remove nans
rm=sum(cells,2)==0;
cells(rm,:)=[];
rm2=sum(cells,1)==0;
cells(:,rm2)=[];
planes(rm2)=[];
%remove data that is in the wrong zoom. we will not have a location for
%these cells, their will inherit 
zl2mpp=[2,3,4,5;...
    1.417,1,.826,.66];
RES=ones(size(planes));%standard is to assume resolution of 1 (i.e. no mult factor)
ZL=3*ones(size(planes));%standard is to assume zoom level of 3
if exist([f,'Plane ID.xlsx'],'file')
    [~,~,raw]=xlsread([f,'Plane ID.xlsx'],'plane and zoom');
    raw=raw(2:end,:);
    zoomP=cellfun(@num2str,raw(:,1),'UniformOutput',0);
    zl=[raw{:,2}]';
    res=[raw{:,3}]';
    [~,Locb] = ismember(strtok(planes,'\'),zoomP);%the strtok is to say subplanes have the same resoluts
    b=Locb(Locb>0);
    RES(Locb>0)=res(b);
    ZL(Locb>0)=zl(b);
    [~,Locb] = ismember(ZL,zl2mpp(1,:));%use lookuptable
    mpp=zl2mpp(2,Locb);%cannot have zeros
    %now remove stuff
    MPP=mpp.*RES;
else
    MPP=ones(size(planes));
end
N=cell(size(planes));
for s=1:length(planes)%for each plane, 
    Frois=[f,planes{s},'\ROIs\RoiSet.zip'];
    if exist(Frois,'file')
        roi=ReadImageJROI(Frois);
        roi=[roi{:}];
        N{s}={roi.strName};
    else
        disp(['You dont have plane ' planes{s}])
    end
end
