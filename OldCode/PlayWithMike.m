%%
figure(2);clf;hold on;
for cii=1:size(traces,1)
    timeCurr=time(cii,:);
    start=find(timeCurr>-.2,1,'first');
    stop=find(timeCurr<0,1,'last');
    df=mean(traces(cii,start:stop));
    DF(cii,:)=(traces(cii,:)-df)/df;
    plot(time(cii,:),(traces(cii,:)-df)/df,'.','color','b')
    ff(cii)=std(traces(cii,:))/mean(traces(cii,:));
end
bw=.02;
bins=-.4:bw:1.6;
md=zeros(length(bins)-1,1);
[T,order]=sort(time(:));
df=DF(:);
df=df(order);
for i=1:(length(bins)-1)
    inds=T>bins(i)&T<=bins(i+1);
    md(i)=prctile(df(inds),80);
end
cfun= fit(time(:),DF(:),'smoothingspline','SmoothingParam',1-1e-6);
y = feval(cfun,T);
% y=(y-min(y)/range(y);
plot(T,y,'r','linewidth',2)
plot(bins(1:end-1)+bw/2,md,'k','linewidth',2)
% figure(3);clf;
% % histogram(ff,50,'DisplayStyle','stairs')
% plot(ff,max(DF,[],2),'o')
% xlabel('Fano Factor')
% ylabel('Max \DeltaF/F')