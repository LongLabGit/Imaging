clear;load('Final.mat')
figure(2);
D=[];
%% delay betwen a burst and its closest gte
for b=1:8
%     for i=1:1000
        bT=Bird(b).bT'*1e3;
        e=Bird(b).Edges*1e3;
        gtes=Bird(b).gtes*1e3;
        bT(bT<e(1,1)|bT>e(end,end))=[];%remove outside
        bT_intervals = diff([min(gtes) sort(bT) max(gtes)]);%get the intervals
        tmp =cumsum(bT_intervals(randperm(length(bT_intervals)))) + min(gtes);%randomize them, accumulate, offset my min G2
        sampledBursts = tmp(1:(end-1));%remove last one
%         bT=sampledBursts;
        d=zeros(size(bT));
        for bti=1:length(bT)
            dd=bT(bti)-gtes;
            [~,ind]=min(abs(dd));
            d(bti)=dd(ind);
        end
        D=[D,d];
%     end
end
histogram(D,20)
xlim(max(abs(D))*[-1,1])
title('Margoliash, Real Data')
xlabel('distance between a single burst and its closest gte')

%% PSTH
D=[];
for b=1:8
    for i=1:100
        bT=Bird(b).bT'*1e3;
        e=Bird(b).Edges*1e3;
        gtes=Bird(b).gtes*1e3;
        bT(bT<e(1,1)|bT>e(end,end))=[];%remove outside
        bT_intervals = diff([min(gtes) sort(bT) max(gtes)]);%get the intervals
        tmp =cumsum(bT_intervals(randperm(length(bT_intervals)))) + min(gtes);%randomize them, accumulate, offset my min G2
        sampledBursts = tmp(1:(end-1));%remove last one
        bT=sampledBursts;
        d=zeros(length(gtes),length(bT));
        for gi=1:length(gtes)
            dd=gtes(gi)-bT;
            d(gi,:)=sort(dd);
        end
        d2=d(:);
        D=[D;d2(d2>-150&d2<150)];
    end
end
histogram(D,-100:10:100)
axis tight
title('PSTH, Random Data')
xlabel('\DeltaT')
ylabel('Number of Bursts')
