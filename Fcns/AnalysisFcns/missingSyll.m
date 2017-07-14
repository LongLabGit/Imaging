function missingSyll(f,FinalC)
for i=1:length(Motif)
    egT(i,:)=Motif(i).EguiTimes-Motif(i).EguiTimes(1);
end
%%
sn=dbase.SegmentTitles;
st=dbase.SegmentTimes;
f=dbase.SoundFiles;
a={Motif.Origname};
for i=1:length(sn)
    ind=strcmp(sn{i},'s');
    t=st{i}(ind,:);
    
    indM=strcmp(a,strrep(f(i).name,'wav','tif'));
    fts=vertcat(Motif(indM).EguiTimes)
    leftover=setdiff(
    nI(i)=round(sum()/6);
end
