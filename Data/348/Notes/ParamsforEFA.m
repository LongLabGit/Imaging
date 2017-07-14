params.nSyllables=6;
params.good=[2,12,10,5,9]; %standard: [1,12,7,8,9];
params.minWarpDist=3;
%relative to your good point, what audio region should be capture and what
%tiff region should we capture?
params.songRegion(1,:)=[0.3,1.25];
params.songRegion(2,:)=[1,.1];
params.songRegion(3,:)=[1,.1];
params.addTif(1,:)=[5 ,30];
params.addTif(2,:)=[50,18];
params.addTif(3,:)=[48,20];
params.removePostWarp=[];