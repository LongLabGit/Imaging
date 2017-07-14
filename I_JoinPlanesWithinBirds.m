reboot;
addpath Fcns\JoinBirds
bird='383';
F=['Data\' bird '\'];
%% Reorder InitialC and ROIs
planes={'PlaneA','PlaneB'};
[Onsets,ROIs]=concatenateOnsets(F,planes);
save([F 'Onsets.mat'],'Onsets')
save([F 'allROIs.mat'],'ROIs')
%% Warp Songs to the same warpings
F=['Data\' bird '\'];
[o,warp,Motif,planes]=getWarpings(F,Onsets,ROIs);
[loc,refPlane]=getLocations(F,Onsets,ROIs);
%Make Canonical Edges
%Warp times to it.
for c=1:length(Onsets)
    Onsets(c).bursts=(Onsets(c).bursts-o(c))*warp(c);
    Onsets(c).Sburst=Onsets(c).Sburst.^2*warp(c);
    Onsets(c).ML_PA_DV=loc(c,:);
end
save([F,'Onsets.mat'],'Onsets','Motif');
plot3(loc(:,1),loc(:,2),loc(:,3),'o')