function dLdT(BI,ts)

%expand into bursts
t=[];xyz=[];
%make an array of bursts
for c=1:length(BI)
    for ind=1:size(BI(c).t,1)
        tN=BI(c).t(ind,:);
        lN=BI(c).xyz(1:2);
        rm=tN<ts(1)|tN>ts(2);
%         rm=zeros(size(tN));
        t=[t,tN(~rm)];
        xyz=[xyz;lN(~rm,:)];
    end
end
%%
figure(6);clf;
dL = pdist(xyz);
dT = pdist(t');
%remove same cell
dT(dL==0)=[];
dL(dL==0)=[];
plot(dL,dT,'o','MarkerSize',2);
hold on;
mdl = fitlm(dL,dT);
rs=mdl.Rsquared.Ordinary;
p=polyfit(dL,dT,1);
lBins=linspace(0,max(dL),500);
plot(lBins,polyval(p,lBins),'k','linewidth',2);
ylabel('distance in burst onset (s)')
xlabel('distance in 2D space (um)')
title(['Single Dot is a Pair of 2 Cells; R^2=',num2str(rs,2)])
figure(8)
histogram(dT,1000)
%% 
figure(7);clf;
subplot(2,1,1)
a=(dT/range(ts));
rm=a<.05;
ad=dL(~rm)./a(~rm);
histogram(ad,100)
xlabel('song velocity (mm/s)')
ylabel('number of pairs')
subplot(2,1,2)
aR=a(randperm(length(a)));
dLF=dL(randperm(length(a)));
rm=aR<.05;
ad=dLF(~rm)./aR(~rm);
histogram(ad,100)
xlabel('assumed distance')
ylabel('number of pairs')
%%

% figure(2);
% mdl.plot
% figure(1);clf;hold on;
% for i=1:length(t)
%     for j=1:length(t)
%         dTM(i,j)=t(j)-t(i);
%         dLM(i,j)=pdist([xyz(i,:);xyz(j,:)]);
%     end
%     if 1%ismember(i,1:10)
%         plot(dTM(i,:),dLM(i,:),'o')
%     end
% end
% xlabel('dT')
% ylabel('dL')
% for i=1:length(t)
%     c(i)=corr(dTM(:,i),dLM(:,i));
% end
% m1=dT(dL<100);
% m2=dT(dL>100);