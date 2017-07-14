function dat2=dist2loc(f,planes,X,Y,mpp,append)
% rank(X)
x = LSdist(X);%converts distance matrix to position by LS 
y = LSdist(Y);
%anything in Z planes will be assigned an x and y
[~,~,dat]=xlsread([f,'Z planes.xlsx']);
z=[dat{2:end,2}]';%their location in z
planesOrig=dat(2:end,1);
planesOrig=cellfun(@num2str,planesOrig,'UniformOutput',0);
rm=isnan(z);%remove the extra cells
z(rm)=[];
planesOrig(rm)=[];
[~,Locb] = ismember(planes',planesOrig);%where each plane is in planesOrig
xls=nan(size(planesOrig));
yls=nan(size(planesOrig));
xls(Locb)=x;
yls(Locb)=y;
MPP=ones(size(planesOrig))';
MPP(Locb)=mpp;


%We should be theoretically done. however, it would be silly to need every
%subplane's location, so we just say that it is the average of all other
%subplanes

%find subplanes
a=regexp(planesOrig,'\');
groups=planesOrig(~cellfun(@isempty,a));
subplanes=unique(strtok(groups,'\'));
%for each subplane,
for s=1:length(subplanes)
    IndAr=regexp(planesOrig,strrep([subplanes{s},'\'],'+','\+'));
    inds=find(cellfun(@isequal,IndAr,num2cell(ones(size(IndAr)))));
    xSub=xls(inds);%find anything that is in that subplane
    %any nans replace with the mean of other suff
    if range(xSub)>20
        disp('Your subplanes are not in the same location')
        subplanes{s}
    end 
    xls(inds(isnan(xSub)))=nanmean(xSub);
    ySub=yls(inds);
    if range(ySub)>20&&range(xSub)>=20
        disp('Your subplanes are not in the same location')
        subplanes{s}
    end
    yls(inds(isnan(ySub)))=nanmean(ySub);
end
dat2=[planesOrig,num2cell(z),num2cell(xls),num2cell(yls),num2cell(MPP')];
if ~append
    dat2(isnan(xls),:)=[];%remove the extras in Z
else
    indExtra=find(isnan(xls));
    dat2(indExtra,3:4)=dat(indExtra+1,3:4);
end
dat2=[{'plane','z','x','y','MPP'};dat2];
% if exist([f,'XYZ.xlsx'],'file')
%     delete([f,'XYZ.xlsx'])
% end
xlswrite([f,'XYZ.xlsx'],dat2);

%if we wanted to incorporate uncertainty
% W =  1./(sX + 1);
% W(isnan(W)) = 1.0;
% xw = LSdist(X, W);
% W =  1./(sY + 1);
% W(isnan(W)) = 1.0;
% yw=LSdist(Y, W);

%an alternative method
% [xl,yl,xlS,ylS]=iterativeLoc(f,X,Y,planes);%turn distances into locations. _lS is relative to your Z list 

%then align to our previous list