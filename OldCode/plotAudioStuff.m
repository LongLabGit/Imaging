[a,fs]=audioread(Motif(3).audioF);
t=linspace(Motif(3).audioTimesWARP(1),Motif(3).audioTimesWARP(2),length(a));
plot(t,a);
axis tight;
line(InitialC(4).bursts+[-2,2]*InitialC(4).Sburst,[1,1]*.1)