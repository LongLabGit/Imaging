%nSyllables: number of syllables per motif
%good: the index of the line in eGUI (onset and offset combined)
%songRegion: go back -songRegion(1) seconds and forwards +songRegion(2)
%seconds
%addTif: after the end of the audio, how many more tifs should we add?
nSyllables=4;
good=[5,8,1,6];
minWarpDist=2;
songRegion(1,:)=[.5,.3];
songRegion(2,:)=[.1,.7];
addTif=[1,15];%how many frames to go back and ahead. REFERENCED TO THE AUDIO START AND END