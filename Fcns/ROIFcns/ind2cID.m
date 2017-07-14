function [rmcID,redocID]=ind2cID(alteredInds,cID,InitialC)

%this will convert your inds into the information that oyu need to change
redocID=unique(cID(alteredInds));%this is simple. basically the cID of the inds that you altered

%what have you done already
a={InitialC.inds};
rmcID=[];
for i=1:length(a)
    if any(ismember(a{i},alteredInds))
        rmcID=[rmcID,i];
    end
end