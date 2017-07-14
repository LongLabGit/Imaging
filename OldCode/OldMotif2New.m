%This file is to convert ABF_first step from legacy to new
clear;clc;
folder='Data\102\Efty2\';
if ~isdir([folder,'motifwavs'])
    mkdir([folder,'motifwavs'])
end
%%
load([folder,'ABF_FirstStep.mat'])
m_old=Motif;%save just in case
for m=1:length(Motif)
    mname=strtok(Motif(m).name,'.');
%     audiowrite([folder,'motifwavs\',mname,'.wav'],m_old(m).audio,4e4)
    Motif(m).audioF=[folder,'motifwavs\',mname,'.wav'];%replace it with location
    Motif(m).audioTimes=[m_old(m).audioTimes(1),m_old(m).audioTimes(end)];
    Motif(m).audioTimesWARP=[m_old(m).audioTimesWARP(1),m_old(m).audioTimesWARP(end)];
end
Motif=rmfield(Motif,'audio');
% Motif=orderfields(Motif,[2,12,3,6,10,1,4,5,7,8,9,11]);
save([folder,'ABF_Output.mat'],'Motif');