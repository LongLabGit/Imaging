%Non changing cell

frames3={[322,374];[537,588];[750,801]};
frames5={[191,243];[363,414];[394,445];[541,593];[576,627]};
close all;
figure(1)
for i=1:length(frames3)
    a=cell5(frames3{i}(1)-1:frames3{i}(2)+10,1);
    trac3(i,:)=a(1:63);
    plot(a)
    hold on
end
for i=1:length(frames5)
    a=cell5(frames5{i}(1)-1:frames5{i}(2)+10,2);
    trac5(i,:)=a(1:63);
    plot(a,'r')
    hold on
end
title('Cell 5')
%changing cell?
%remember to confirm by abg for 05
plot(mean(trac3,1),'color','b','linewidth',2.5)
plot(mean(trac5,1),'color','r','linewidth',2.5)
%%
figure(2)
for i=1:length(frames3)
    a=cell27(frames3{i}(1)-1:frames3{i}(2)+10,1);
    trac3(i,:)=a(1:63);
    plot(trac3(i,:))
    hold on
end
for i=1:length(frames5)
    a=cell27(frames5{i}(1)-1:frames5{i}(2)+10,2);
    trac5(i,:)=a(1:63);
    plot(trac5(i,:),'r')
    hold on
end
title('Cell 27')
plot(mean(trac3,1),'color','b','linewidth',2.5)
plot(mean(trac5,1),'color','r','linewidth',2.5)