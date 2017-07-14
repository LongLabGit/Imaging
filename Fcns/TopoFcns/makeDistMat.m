function [X,Y,sX,sY]=makeDistMat(f,N,planes,cells,MPP,fixit,num)
%This will go through each plane and find the cells that it has in common
%with each other plane. It will then use those as triangulation points to
%find the offsets between the two planes

flag=0;
n=1;
for p1=1:length(planes)%for each plane
    if flag
        break
    end
    for p2=1:length(planes)%for all other planes
        c1=cells(:,p1);%the cells in first plane
        c2=cells(:,p2);%the cells in the second plane
        pairs=[c1,c2];%get the pairs
        rm=logical(sum(pairs==0,2));
        pairs=pairs(~rm,:);%only keep those in common
        l1=zeros(size(pairs));
        l2=zeros(size(pairs));
        %pairs are the cells in common between the planes
        for p=1:size(pairs,1)%for each pair
            %compute offset between planes
            n1=N{p1}{pairs(p,1)};
            n2=N{p2}{pairs(p,2)};
            %remove the '0001' part. super sketchy code but it works
            if length(n1)==14
                n1=n1(6:end);
            end
            if length(n2)==14
                n2=n2(6:end);
            end
            l1(p,:)=[str2double(n1(1:4)),str2double(n1(6:9))]*MPP(p1);
            l2(p,:)=[str2double(n2(1:4)),str2double(n2(6:9))]*MPP(p2);
        end
        if size(l1,1)>1
            xy=nanmean(l1-l2,1);
            X(p1,p2)=xy(1);
            Y(p1,p2)=xy(2);
            sxy=range(l1-l2);%range of offsets
            sX(p1,p2)=sxy(1);
            sY(p1,p2)=sxy(2);
            if sum(sxy>10)&&p1<p2
                if fixit&&n==num
                    disp(['planes:' planes{p1},' & ',planes{p2}]);
                    disp('The following pairs')
                    disp(pairs)
                    disp('Have respective offsets of')
                    disp(round(l1-l2))
                    flag=1;
                    break
                elseif fixit
                    n=n+1;
                else
                    disp(['planes:' planes{p1},' & ',planes{p2}]);
                    m=nanmedian(l1-l2,1);
                    bad=sum(((l1-l2)-repmat(m,length(l1),1))>4,2);
                    disp(pairs(logical(bad),:));
                end
            end
        else
            xy=nanmean(l1-l2,1);
            X(p1,p2)=xy(1);Y(p1,p2)=xy(2);
            sX(p1,p2)=NaN;
            sY(p1,p2)=NaN;
        end
    end
end
save([f,'topo.mat'],'X','Y','sX','sY','planes')%here s is the Range
if sum(sX(:)>10)||sum(sY(:)>10)
    disp('You might have an error, range is above 10u for some planes. Check sX and sY')
end