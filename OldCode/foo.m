clc;clear;
figure(1);
clf;
load(['Data\222 BOS\InitialC.mat']);%if we havent run final yet
kept=ones(12,59);
for i=1:12
    kept(i,InitialC(i).rmsub{1,2})=0;
end
imagesc(kept)
colormap gray
axis equal
axis tight
set(gca,'ydir','normal')
xlabel('Motif #')
ylabel('Cell #')