params.nSyllables=5; %specify sillables!
% params.good=[1,3,5,6,20,14,12,10,9,8,7]; %standard: [1,12,7,8,9], see next line for minimal distance;
%there must be the same amount of warp, songRegion and addTif entries
params.Warp=[3,10;
             1,10;
             3,7;
             5,9;
             ];
% params.minWarpDist=6;
%relative to your good point, what audio region should be capture and what
%tiff region should we capture?
params.songRegion(1,:)=[.3,.75]; %standard: [0.3, 1.25]
params.songRegion(2,:)=[.3,.75]; %standard: [0.3, 1.25]
params.songRegion(3,:)=[.3,.75];
params.songRegion(3,:)=[.5,.7];

params.addTif(1,:)=[7,30]; %!Achtung! keep all 3 possibilities the same No. of frames. Frames relative to "good" reference point, standard: [5 ,30]
params.addTif(2,:)=[7,30]; 
params.addTif(3,:)=[7,30];
params.addTif(3,:)=[12,25]; 

params.removePostWarp=[];