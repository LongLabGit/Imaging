folder='102\CorrectedPlanes\Plane9\';
folder=['Data\',folder];
load([folder,'ABF_Output.mat'],'Motif')
allDays={Motif(:).Origname};
[a,~,inds]=unique(allDays);

binSize=[];%how large do we want the bins, in seconds
groupOpt='avg';
Selectmotif=[];%leave empty if you want all of them
for i=4:length(a)
    M=Motif(inds==i);
    [tiffIDs,mTimes]=makeMovieTifDay(folder,binSize,groupOpt,Selectmotif,M,num2str(i));
end