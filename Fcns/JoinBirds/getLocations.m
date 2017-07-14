function [real_loc,img_loc,refPlane]=getLocations(F,Onsets,ROIs)

% STEPS
%1) Apply Motion Corrrecton offset to get real X,Y location of the cell
%2) Rotate by 60 degrees to turn X,Y into AP,ML
%3) Apply Offset so that it is relative to michels scope's (0,0,0)

% Get locations of planes
[pLoc,planeN]=xlsread([F,'PlaneLocations.xlsx']);
planes=planeN(2:end,1);

% Get Motion Correction offsets
MotO=nan(length(planes),2);
for p=1:length(planes)
    Fn=[F,'MotC_offset\' strrep(planes{p},'\','_')];
    roisOrig=ReadImageJROI([Fn,'_orig.zip']);
    roisOrig=[roisOrig{:}];
    roisFinal=ReadImageJROI([Fn '_Avg.zip']);
    roisFinal=[roisFinal{:}];
    [xO,yO,xF,yF]=deal(nan(1,3));
    for i=1:3
        [yF(i),xF(i)]=strread(roisFinal(i).strName,'%d-%d');%for some reason they flip the name
        [yO(i),xO(i)]=strread(roisOrig(i).strName,'%d-%d');
    end
    MotO(p,:)=[mean(xO-xF),mean(yO-yF)];
    if range(xO-xF)>15||range(yO-yF)>15
        disp('wrong cells schmuck')
        disp(Fn)
        disp([range(xO-xF),range(yO-yF)])
    end
    if any(MotO(p,:)<-1)
        disp('cant add pixels!')
        disp(Fn)
        disp(MotO(p,:))
    end
end
MotO(MotO<0)=0;
%%
% theta= 61.75;%THIS THE CALCULATED NUMBER. SEE S:\Vigi\Matlab\Sam_SpaceTime\E_Transform Scopes
theta=-112;
R=[cosd(theta), -sind(theta);
    sind(theta) cosd(theta)];
test=zeros(512,512);
testN=imrotate(test,-theta);
shiftN=size(testN)/2;
[real_loc]=deal(nan(length(Onsets),3));
refPlane=cell(length(Onsets),1);%for gut checks
for c=1:length(Onsets)
    rID=Onsets(c).inds(1);%subplanes have same warpings
    rPlane=strrep(ROIs(rID).f,F,'');%Find the plane that the cell is on
    indP=strcmp(rPlane(1:end-1),planes);%Get the index for Motion Correction Offset
    patch=ROIs(rID).patch;%And get it's location
    
    %1) First shift ROIs to orignal location on plane
    real_loc(c,1:2)=mean(patch);
    %2) Then add in the motion correction offset loss. this will be needed
    %later
    real_loc(c,1:2)=real_loc(c,1:2)+MotO(indP,:);
    %3) Flip Y so that large numbers are upwards, and small numbers are at the bottom
    real_loc(c,2)=512-real_loc(c,2);
    %4) Center things to the middle of the image
    real_loc(c,1:2)=real_loc(c,1:2)-256;
    %5) Then rotate them so that X and Y now refers to ML-AP
    real_loc(c,1:2)=(R*real_loc(c,1:2)')';
    %6) Then shift them so that they are now in the center of the image
    %again
    real_loc(c,1:2)=real_loc(c,1:2)+shiftN;
    %7) Now shift them to Michel's global (& relative!) coordinates
    real_loc(c,1)=real_loc(c,1)+pLoc(indP,1);%Positive Movements are lateral, making the number bigger
    real_loc(c,2)=real_loc(c,2)+pLoc(indP,2);%Positive Movments are Anterior, making the number larger
    %8) D-V
    real_loc(c,3)=pLoc(indP,3);%This is easy, just by definition
    %store the plane we used
    refPlane{c}=rPlane(1:end-1);
end
real_loc=real_loc-repmat(mean(real_loc),length(real_loc),1);
real_loc=round(real_loc);
% Flip it back into img frame for gut check
img_loc=real_loc;
% img_loc
% shift=