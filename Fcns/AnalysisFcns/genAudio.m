function [wav,t,ts,S,T,F]=genAudio(f,locAll,gteWAV)

if exist([f,locAll,'ABF_Final.mat'],'file')
    load([f,locAll,'ABF_Final.mat'],'Motif');
else
    load([f,locAll,'ABF_Output.mat'],'Motif');
end
ind=strcmp(strtok({Motif.name},'.'),gteWAV);
Motif=Motif(ind);

if ~isempty(regexp(f,'131','once'))||~isempty(regexp(f,'193','once'))||~isempty(regexp(f,'192','once'))
    audf=Motif.audioF;
    indS=regexp(audf,'\');
    audn=audf(indS(end)+1:end);
    wav=audioread([f,locAll,'motifWavs\',audn]);
elseif ~isempty(regexp(f,'105','once'))
    wav=audioread(Motif.audioF);%make the master with the minimum warp
else
    wav=Motif.audio;
end


F=linspace(500,10000,2^10);
w=Motif.warpFactor;
t=[Motif.audioTimesWARP(1),Motif.audioTimesWARP(end)];
ts=Motif.TimeSingingWARP;
[~,F,T,P]=spectrogram(wav,512,384,F,4e4);%make it
T=[t(1)+T(1)/w,t(end)+(T(end)-length(wav)/4e4)/w];%update time vector
S=10*log10(P);