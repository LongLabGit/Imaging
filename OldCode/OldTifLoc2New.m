%This file is to convert ABF_first step from legacy to new
folder='Data\102\102samefocalplanesameday\';
if ~isdir([folder,'motifwavs'])
    mkdir([folder,'motifwavs'])
end
load([folder,'ABF_OutputTL.mat'])
for m=1:length(tiffLocs)
    mname=strtok(tiffLocs{m,2},'.');
    audiowrite([folder,'motifwavs\',mname,'.wav'],motif{m},4e4)
    Motif(m).Origname=[mname(1:end-2),'.tif'];%will break if there is a motif >10
    Motif(m).name=tiffLocs{m,2};
    Motif(m).audioF=[folder,'motifwavs\',mname,'.wav'];%replace it with location
    Motif(m).audioTimes=[m_old(m).audioTimes(1),m_old(m).audioTimes(end)];
    Motif(m).
end
% Motif=rmfield(Motif,'audio');
Motif=orderfields(Motif,[2,12,3,6,10,1,4,5,7,8,9,11]);
save([folder,'ABF_FirstStep.mat'],'Motif','params');
%%
plot(motif{1})
for i=1:12
    line(eGUIlocs(1,i)*[1,1],[-1,1],'color','k')
end