clear;clc;close all;
f='Data\102\CorrectedPlanes\';
load ([f,'topo.mat'],'X','Y','sX','sY','planes')
%%
mat=X;
rel1=mat(1,:);
for i=1:length(rel1)
    if isnan(rel1(i))%if we do not have a relative position to 1
        offsets=mat(:,i)';%but we do have rleative positions to oithers
        offsets(i)=NaN;
        rel_to_1=~isnan(rel1);%do those others have a relative position to 1?
        keep=rel_to_1&~isnan(offsets);%find those in common
        locs=rel1(keep)+offsets(keep);%these will be an estimate of offsets from those other locations
        s(i)=range(locs);%make sure that they arent disparate
        rel1(i)=mean(locs);
    end
end
%%
mat=X;
rel2=mat(1,:);
figure(1);clf;hold on
for n=1:1e4
    for i=1:length(rel2)
        offsets=X(:,i)';%these are the options
        offsets(i)=NaN;
        rel_to_1=~isnan(rel2);
        keep=rel_to_1&~isnan(offsets);
        loc=mean(rel2(keep)+offsets(keep));
        rel2(i)=loc;
    end
    plot(1:23,rel2,'.')
end