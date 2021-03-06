function Motif=calcShift(folder,Motif)
%%
h=waitbar(0,'Recalculating alignment');
for m=1:length(Motif)
    %get image names
    origT=[folder,'1-Orig\' Motif(m).Origname];
    newT=[folder,'5-FinalMotifs\' Motif(m).name];
    newI=double(imread(newT,1));%first frame from new tiff
    minD=min(size(newI));%minimum dimebnsion. THIS IS ONLY FOR CALCULATION NICENESS
    oldI=double(imread(origT,Motif(m).frames(1)));%first indexed frame from old
    Motif(m).totalLines=size(oldI,1);%this will be used to calcualate the fraction of the imaging period
    oldI=oldI(1:minD,1:minD);%IMPORTANT-cut off lower edges only
    newI=newI(1:minD,1:minD);%same thing
    tform=imregcorr(newI,oldI,'translation');%this is where magic happens
    test = imwarp(newI,tform,'OutputView',imref2d([minD,minD]));%this is the test for it

    Motif(m).hor_vert=tform.T(3,1:2);
    Motif(m).shiftScore=corr2(test,oldI);
    if any(Motif(m).hor_vert<-1)||Motif(m).shiftScore<.4%negative pixel loss or low final match 
        subplot(121);imagesc(oldI);axis square;subplot(122);imagesc(test);axis square;%plot for gutcheck
        error('how is that even possible. get Vigi. if you are vigi, do a better job you idiot')
    end
    waitbar(m/length(Motif))
end
delete(h);