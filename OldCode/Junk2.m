addpath Fcns\ROIFcns
for i=1:3
    Cell=ExtractF_SingleTif(['C:\Users\Michel\Desktop\sleep_0000' num2str(i) '.tif'],...
        'C:\Users\Michel\Desktop\RoiSet.zip',1);
    save(['Cell' num2str(i) '.mat'],'Cell')
end
%%
i=3;%0,1, or 2
load(['Cell' num2str(i) '.mat'],'Cell')
set(0,'DefaultFigureWindowStyle','docked')
for c=1:29,
    figure(c);clf;
    plot(Cell(c).t,Cell(c).bin);
    title(['Exp #' num2str(i) ', Cell #',num2str(c)])
end