function plotSteps3D(FinalC,db)
figure(5);clf;
%expand into bursts
t=[];cI=[];cID=[];s=[];xyz=[];
%make an array of bursts
for c=1:length(FinalC)
    if size(FinalC(c).bursts,1)==1||~db
        for ind=1:size(FinalC(c).bursts,1)
            t1=nanmean(FinalC(c).bursts(ind,:));
            s1=nanmean(FinalC(c).Sburst(ind,:));
            t=[t,t1];
            s=[s,s1];
            xyz=[xyz;FinalC(c).xyz];
            cID=[cID;FinalC(c).cID];
            cI=[cI,c];
        end
    end
end
[~,inds]=sort(t);
l2=xyz(inds,:);
clf;hold on;
cols=jet(length(t));
for i=1:length(t)-1
    h(i)=plot3(l2(i,1),l2(i,2),l2(i,3),'o','color',cols(i,:),'markersize',15,'MarkerFaceColor',cols(i,:));
%     h(i)=plot3(l2(i:i+1,1),l2(i:i+1,2),l2(i:i+1,3),'color',cols(i,:));
    xlim([0,600]);
    ylim([0,600]);
    zlim([-100,100]);
end
xlabel(['location z (um)'])
ylabel(['location in y (um)'])
zlabel(['location in z (um)'])
colormap jet;
colorbar;
title('ordered firing as a function of location')