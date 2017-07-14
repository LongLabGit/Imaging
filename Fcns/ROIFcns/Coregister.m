function Coregister(F,subs)
%PuT IN CODE TO NOT RUN TWICE
for s=1:length(subs)
    sub=subs{s};
    folder=[F,sub,'\'];
    planes=dir(folder);
    planes(~[planes.isdir])=[];
    planes={planes.name};
    planes=setdiff(planes(3:end),{'All','old'})';
    rmField={'vnRectBounds','nPosition','vnPosition','strType','nStrokeWidth','nStrokeColor','nFillColor','bSplineFit'};
    [~,~,keep]=xlsread([F,'SelectedCells.xlsx']);
    planeK=cellfun(@num2str,keep(:,1),'UniformOutput',0);%
    rm=strcmp(keep(:,3),'no');
    % generate the list of ROIs
    A=zeros(512,512,length(planes));
    ROI=struct([]);
    for f=1:length(planes)
        rois=ReadImageJROI([folder,planes{f},'\ROIs\RoiSet.zip']);
        rois=cell2mat(rois);
        rois=rmfield(rois,rmField);
        sel=strcmp(planeK,[sub,'\',planes{f}])&~rm;
        indKeep=cell2mat(keep(sel,2));
        rois=rois(indKeep);
        for i=1:length(rois)
            mn=rois(i).mnCoordinates;
            BW = poly2mask(mn(:,1), mn(:,2), size(A,1), size(A,2));
            rois(i).inds=find(BW);
            rois(i).plane=f;
            rois(i).cInd=indKeep(i);
            rois(i).done=0;
            A(:,:,f)=A(:,:,f)+BW;
        end
        if ~isempty(rois)
            ROI=[ROI,rois];
        end
    end
    backup=ROI;
    % For each ROI find a parallel
    ROI=backup;
    U=zeros(512,512,length(planes));
    planeID=[ROI.plane];
    chart=[];
    chartI=1;
    for c=1:length(ROI)
        if ~ROI(c).done%if we havent done it yet
            ROI(c).done=1;
            chart(chartI,ROI(c).plane)=ROI(c).cInd;
            mn=ROI(c).mnCoordinates;
            BW = poly2mask(mn(:,1), mn(:,2), size(A,1), size(A,2));
            U(:,:,ROI(c).plane)=U(:,:,ROI(c).plane)+BW;
            for f=(ROI(c).plane+1):length(planes)%then check all the other planes
                p=find(planeID==f);
                overlap=zeros(size(p));
                for pInd=1:length(p)
                    overlap(pInd)=length(intersect(ROI(c).inds,ROI(p(pInd)).inds));
                end
                [m,ind]=max(overlap);%find the cell that overlaps with it the most
                %vigi changed code here to make minimum 5 pixels but never check it. 
                %make sure that it works
                if m>5%make sure it overlaps with at least 5 pixels (we can increase this)
                    ROI(p(ind)).done=1;
                    chart(chartI,f)=ROI(p(ind)).cInd;
                end
            end
            chartI=chartI+1;
        end
    end
    % write it out
    for p=1:length(planes)
        if p==1
            imwrite(uint16(U(:,:,p)),[folder,'Unique.tiff'],'TIF','compression','none')
            imwrite(uint16(A(:,:,p)),[folder,'All.tiff'],'TIF','compression','none')
        else
            imwrite(uint16(U(:,:,p)),[folder,'Unique.tiff'],'TIF','WriteMode','append','compression','none')
            imwrite(uint16(A(:,:,p)),[folder,'All.tiff'],'TIF','WriteMode','append','compression','none')
        end
    end
    if size(chart,2)==1
        chart=[chart,zeros(length(chart),length(planes)-1)];
    end
    chartC=num2cell(chart);
    chartC=[planes';chartC];
    xlswrite([folder,'LookUpTable.xlsx'],chartC);
end