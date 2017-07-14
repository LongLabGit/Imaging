%here is a technique to quantify how well we matched up

%inds needs to be the same for everyone
%base it on the first one, because why not
t=sort([0,Motif(1).eGUIlocs(good(2))];%fix this
inds=Motif(1).audiotimesWARP>t(1)&Motif(1).audiotimesWARP<t(2);
for m=1:length(Motif)
    audio(m,:)=Motif(m).audio(inds
end
%now that you have it, 