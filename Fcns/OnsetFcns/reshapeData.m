function [CaF,tau,offsets,rescalings,period,time,inds]=reshapeData(time,traces)

tinit=time(:,1);
[~,inds]=sort(tinit,'descend');
% reoirder time and traces such that the first one starts the latest
traces=traces(inds,:);
time=time(inds,:);
% trial 1 is a reference -- bursts can't be outside the time length of this trial
period = diff(time(:,1:2),1,2)';%frame period. only look at the first ones, will be the same throughout

rescalings=period(1)./period;
offsets = ((time(:,1)-time(1,1))/period(1))';%the units are percentage of a bin size
%assume taus
tau = [.05 .1]/mean(period);
tau(1) = max(0.05,tau(1)+(rand-.5)*6);%randomize answer
tau(2)= max(0.2,tau(2)+(rand-.5)*6);
if tau(2)<tau(1)
    tau(2)=tau(1)+.5;
end
%convert calcium data to a cell array and remove NaNs
CaF=cellfun(@(x)x(~isnan(x)),num2cell(traces,2),'UniformOutput',0);
