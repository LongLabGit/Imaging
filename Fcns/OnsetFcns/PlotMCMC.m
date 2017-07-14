function PlotMCMC(CaF,trials,mcmc,time,burnIn)

% Once you have your data, then go ahead and plot it
figure(1);clf;
ntrials = size(CaF,1); 
final_cal_var = zeros(1,ntrials);
% nBins = cellfun(@length,CaF);
for ti = 1:ntrials
    %ML - DOF, init, baseline and each burst amplitude
    SSE=sum((CaF{ti}-trials.curves{end}{ti}).^2);
    n=numel(trials.curves{end}{ti})-(2+mcmc.N_sto(end)); 
    final_cal_var(ti) = SSE/n;%standard error
end
%
final_cal_std = sqrt(final_cal_var);
m=4;
n=max(floor(ntrials/m),1);%as many levels as we can make divisible by 4, with a minimum of 1
n=min(n,4);%dont do more than 16. it gets too crowded
nPlots=min(n*m,ntrials);
%it will be nxm
for traceInd=1:nPlots
    subplot(n,m,traceInd)
    t=time(traceInd,:);
    t=t(~isnan(t));
    modelledTrace = [];
    hold on
    for i = burnIn:10:length(trials.curves)
        modelledTrace = [modelledTrace;trials.curves{i}{traceInd}];
        plot(t,trials.curves{i}{traceInd},'r');
        xlabel('time (ms)')
        axis tight
    end
    plot(t(~isnan(t)),CaF{traceInd},'ko','linewidth',2); 
    MTm = mean(modelledTrace);
    MTs = std(modelledTrace);%estimation noise
    plot(t,MTm,'r--');
    %Liams idea: posterior uncertaubnty which is the sum of uncertainty in
    %Ca signal + inherent noise of calcium signal
    plot(t,MTm+2*(final_cal_std(traceInd)+MTs),'r--'); 
    plot(t,MTm-2*(final_cal_std(traceInd)+MTs),'r--'); 
    hold off
    axis tight
end