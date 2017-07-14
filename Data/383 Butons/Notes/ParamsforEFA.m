params.nSyllables=4; %specify sillables!
% params.good=[1,3,5,6,20,14,12,10,9,8,7]; %standard: [1,12,7,8,9], see next line for minimal distance;
%there must be the same amount of warp, songRegion and addTif entries
params.Warp=[1,8;
             1,5;
             3,8;
             ];
% params.minWarpDist=6;
%relative to your good point, what audio region should be capture and what
%tiff region should we capture?
params.songRegion(1,:)=[.1,1.1]; %standard: [0.3, 1.25]
params.songRegion(2,:)=[.1,1.1]; %standard: [0.3, 1.25]
params.songRegion(3,:)=[.4,.8];
params.addTif(1,:)=[7,30]; %!Achtung! keep all 3 possibilities the same No. of frames. Frames relative to "good" reference point, standard: [5 ,30]
params.addTif(2,:)=[7,30]; 
params.addTif(3,:)=[15,22]; 
params.removePostWarp=[];