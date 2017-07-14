close all;
subplot(2,2,1)
h = findobj(gca,'Type','line');
a=mean(h(1).YData);