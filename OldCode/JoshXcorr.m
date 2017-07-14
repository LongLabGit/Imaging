clear;
load('ImagingFinal.mat')

%%%%%%%%%%%%%%%%
% Average over birds 
%%%%%%%%%%%%%%%%
averageOverBirds = zeros(5,21);
resampledC = cell(1,5);

for birdIndx = 1:5
    G2 = unique(Bird(birdIndx).gtes);
    %agreggate data
    bT = [];
    bS = [];
    for i = 1:length(Bird(birdIndx).Info)
        bT = [bT; Bird(birdIndx).Info(i).t]; 
        bS = [bS; Bird(birdIndx).Info(i).s];
    end
    %restrict to song
    bT = bT-.02;
    bT(bT>max(G2)) = [];
    bT(bT<min(G2)) = [];
    nBursts = length(bT);
    %generate histograms 
    bin_step = .01;
    edges = -.4:bin_step:1; %sec
    nt = histc(bT,edges);
    ng = histc(G2,edges);
    
    [c lag] = xcorr(nt,ng,10,'unbiased');

    averageOverBirds(birdIndx,:) = c;
    
    nBursts = length(bT);

    % repeatedly scramble the inter-burst intervals and recompute the xcorrs
    resampledC{birdIndx} = [];
    bT_intervals = diff([min(G2) sort(bT)' max(G2)]);%get the intervals
    for i = 1:1e3%do it 1000x
        % sampled from reshuffling of intervals
        tmp =cumsum(bT_intervals(randperm(length(bT_intervals)))) + min(G2);%randomize them, accumulate, offset my min G2
        sampledBursts = tmp(1:(end-1));%remove last one
        
        nts = histc(sampledBursts,edges);
        [rc rlag] = xcorr(nts,ng,10,'unbiased');
        resampledC{birdIndx} = [resampledC{birdIndx}; rc];
    end

end

% compute average across birds per resample
averages_across_birds = zeros(length(resampledC{1}),21);
for j = 1:5
    averages_across_birds = averages_across_birds + resampledC{j};
end
averages_across_birds = averages_across_birds./5;

%% plot it
for j = 1:5
    if j == 1
        plot(lag*bin_step*1e3, (averageOverBirds(j,:) - mean(resampledC{j}))./std(resampledC{j}),'color','r') %subtract baseline
    else
        plot(lag*bin_step*1e3, (averageOverBirds(j,:) - mean(resampledC{j}))./std(resampledC{j}),'color',.7*[1 1 1]) %subtract baseline
    end
    hold on
end
plot(lag*bin_step*1e3, (mean(averageOverBirds) - mean(averages_across_birds))./std(averages_across_birds),'k','linewidth',2) %subtract baseline
plot(lag*bin_step*1e3, 3*ones(21,1),'k--','linewidth',2)
plot(lag*bin_step*1e3, -3*ones(21,1),'k--','linewidth',2)
hold off
ylim([-4 10]) %normalized

ylabel('cross-correlation')
xlabel('time offset (ms)')
title(['cross-correlation (GTEs with burst onsets), all birds'])