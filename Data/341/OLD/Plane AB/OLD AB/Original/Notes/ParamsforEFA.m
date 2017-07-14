params.nSyllables=10; %specify sillables!
params.good=[1,3,5,6,20,14,12,10,9]; %standard: [1,12,7,8,9], see next line for minimal distance;
params.minWarpDist=6;
%relative to your good point, what audio region should be capture and what
%tiff region should we capture?
params.songRegion(1,:)=[0.3,2.0]; %standard: [0.3, 1.25]
params.songRegion(2,:)=[.4,1.9];
params.songRegion(3,:)=[.5,1.8];
params.addTif(1,:)=[10,40]; %frames relative to "good" reference point, standard: [5 ,30]
params.addTif(2,:)=[12,35];
params.addTif(3,:)=[15,30];
params.removePostWarp=[];