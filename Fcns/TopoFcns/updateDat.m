function dat=updateDat(f,dat)

%#3 is y, #4 is x
%First, take a look at Zstack. Any planes that are off, look up their names
%in z plane.
%Then find the index in dat, and modify it there
%Then run dist2loc and updateDat again.
if strcmp(f,'Data\105\Planes\')
    %this one is weirdly shifted down
    dat{(strcmp(dat(:,1),'12bis')),3}=-180;
    
    for i=41:44
        dat{i,3}=dat{i,3}-10;
        dat{i,4}=dat{i,4}+10;
    end
    %remove the last two
    for i=(size(dat,1)-1):size(dat,1)
        dat{i,3}=NaN;
        dat{i,4}=NaN;
    end
elseif strcmp(f,'Data\192\Planes\')
    dat{11,3}=dat{11,3}-20;
    for i=2:9
        dat{i,3}=0;
        dat{i,4}=0;
    end
    for i=12:22
        dat{i,3}=0;
        dat{i,4}=0;
    end
end

xlswrite([f,'XYZb.xlsx'],dat);
save([f,'topo.mat'],'dat','-append')