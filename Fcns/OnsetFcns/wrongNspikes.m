function [rmDn, ID]=wrongNspikes(burstTimes,useDn)
%remove all that didnt have the correct number of spikes
l=cellfun(@length,burstTimes);
nSpike=mode(l);
rm=find(l~=nSpike);%find all the sweeps that had the wrong number of spikes
rm2=[];
%expand that to the ones nearby
for nRM=1:length(rm)
    rm2=[rm2,max((rm(nRM)-25),1):min((rm(nRM)+25),length(burstTimes))];
end
b1=burstTimes;
b2=burstTimes;
% replace burstTimes with logical indices
if ~isempty(rm2)&&useDn
    for nb=1:length(b1)
        if ismember(nb,rm2)
            b1{nb}=ones(size(b1{nb}));
        else
            b1{nb}=zeros(size(b1{nb}));
        end
    end
    rmDn=cell2mat(b1);
else
    rmDn=zeros(size(cell2mat(burstTimes)));
end
% this is so we can trace it back to its original sweep
for nb=1:length(b2)
    b2{nb}=nb*ones(size(b2{nb}));
end
ID=cell2mat(b2);