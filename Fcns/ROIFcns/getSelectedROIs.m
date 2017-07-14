function [plane,cellN,planeIDs,subplanes]=getSelectedROIs(folder)

[~,~,dat]=xlsread([folder,'SelectedCells.xlsx']);
dat=dat(2:end,1:2);
plane=cellfun(@num2str,dat(:,1),'UniformOutput',0);%
cellN=[dat{:,2}];
for i=1:length(plane)
    if strcmp(plane{i}(end),'\')
        plane{i}=plane{i}(1:end-1);%Michel sometimes adds a '\' at the end. take it off 
    end
end
planeIDs=unique(plane);
%anything with a backslash is a subplane
a=regexp(plane,'\');
groups=plane(~cellfun(@isempty,a));
subplanes=unique(strtok(groups,'\'));