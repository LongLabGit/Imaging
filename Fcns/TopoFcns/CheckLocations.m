function [rn,cIDn]=CheckLocations(ROIs,maxR)
cIDList=[ROIs.cID];
cID=unique(cIDList);
r=zeros(length(cID),3);
n=zeros(length(cID),1);
for c=1:length(cID)
    inds=cIDList==cID(c);
    loc=vertcat(ROIs(inds).xyz);
    r(c,:)=range(loc,1);
    if any(r(c,:)>maxR)
        disp(['Cell #' num2str(cID(c)) ' has the following values'])
%         disp(loc)
%         disp(find(inds))
    end
    n(c)=size(loc,1);
end
rn=r(n>1,:);
cIDn=cID(n>1)';