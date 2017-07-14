params.nSyllables=10; %specify sillables!
% params.good=[1,3,5,6,20,14,12,10,9,8,7]; %standard: [1,12,7,8,9], see next line for minimal distance;
%there must be the same amount of warp, songRegion and addTif entries
params.Warp=[9,20;
             9,12;
             10,20;
             4,11
             3,8;
             1,5;
             4,12;
             ];
% params.minWarpDist=6;
%relative to your good point, what audio region should be capture and what
%tiff region should we capture?
params.songRegion(1,:)=[1.0,1.5]; %standard: [0.3, 1.25]
params.songRegion(2,:)=[1.0,1.5]; %standard: [0.3, 1.25]
params.songRegion(3,:)=[1.0,1.5];
params.songRegion(4,:)=[.5,2.0];
params.songRegion(5,:)=[.5,2.0];
params.songRegion(6,:)=[.5,20.8];
params.songRegion(7,:)=[.5,2.0];
params.addTif(1,:)=[20,30]; %!Achtung! keep all 3 possibilities the same No. of frames. Frames relative to "good" reference point, standard: [5 ,30]
params.addTif(2,:)=[20,30]; 
params.addTif(3,:)=[20,30]; 
params.addTif(4,:)=[15,35];
params.addTif(5,:)=[10,40];
params.addTif(6,:)=[10,40];
params.addTif(7,:)=[15,35];
params.removePostWarp=[];