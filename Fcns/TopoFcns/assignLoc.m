function [InitialC,Rxyz]=assignLoc(InitialC,ROIs)

Rxyz=zeros(length(InitialC),3);
for c=1:length(InitialC)
    inds=InitialC(c).inds;
    loc=vertcat(ROIs(inds).xyz);
    InitialC(c).xyz=nanmean(loc,1);
    Rxyz(c,:)=range(loc,1);
    if any(range(loc(:,1:2),1)>30)
        disp(['large range in #' num2str(c)])
    end
end