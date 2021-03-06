function tiffInd=getTiffInds(galvo,t_file)

tiffSig=galvo/max(galvo);%d(:,1) holds the frame onset offset
tiffSig=tiffSig>.1;
ts1=diff([0;tiffSig]);

startInd=find(ts1==1);%the sample number of the start of the Nth tiff
stopInd=find(ts1==-1);%the sample number of the end of the Nth tiff
tiffInd=(startInd+stopInd)/2;

%do a bit of gutchecking
abfN=length(tiffInd);
i=Tiff(t_file,'r');
try 
    i.setDirectory(length(tiffInd));
catch
    tiffN=length(imfinfo(t_file));
    disp(['tiff is too short!, expected ',num2str(abfN),' got ',num2str(tiffN)])
end
if ~i.lastDirectory&&(tiffN>abfN)%i.e. we have more than expected images. 
    abfN=length(tiffInd);
    tiffN=length(imfinfo([folder,'\1-Orig\',fname,'.tif']));
    disp(['tiff is too long, expected ',num2str(abfN),' got ',num2str(tiffN)])
end

%Ocassionally shit happens. the code below was supposed to compensate for
%it,. but i dont want to do that anymore. collect better data you asshole


% if stopInd(1)<startInd(1)
%     stopInd(1)=[];
% end
% if length(startInd)>length(stopInd)
%     startInd(end)=[];
%     disp('the last frame on the galvo didnt finish, removing it')
%     if mode(stopInd-startInd)/Fs>.04||mode(stopInd-startInd)/Fs<0
%         error('Unable to find tiff times accurately')
%     end
% end

%here we need to account for the fact that michel likes to randomly
%image the plane. so we need to onnly take the imaging block that has
%glass within it. but he also might start imaging after glass. so we
%look for the start that is closest to the start of the glass
%breaks will be
% deltaI=diff(tiffInd/Fs);
% breaks=find(deltaI>2)+1;%account for times in which he stops imaging for a bit and then starts again
% if ~isempty(breaks)
%     %turn it into a set of groups
%     groups=zeros(length(breaks)+1,2);
%     groups(1,1)=1;%obviously it needs to start at one
%     %for each break make the previous image the end of the last group and
%     %the first image the beginning of the next
%     for b=1:length(breaks)
%         groups(b,2)=breaks(b)-1;
%         groups(b+1,1)=breaks(b);
%     end
%     groups(length(breaks)+1,2)=length(startInd);%it then needs to end at the end
%     glass=glass/max(glass);
%     glassOn=find(glass>.2,1,'first');%when the glass turns on
%     imagingOn=startInd(groups(:,1));%start of each group of possible images that correspond to the tiff
%     [~,ind]=min(abs(imagingOn-glassOn));%find the closest region
%     tiffInd=tiffInd(groups(ind,1):groups(ind,2));
%     startInd=startInd(groups(ind,1):groups(ind,2));
%     stopInd=stopInd(groups(ind,1):groups(ind,2));
%     deltaI=diff(tiffInd/Fs);
% end
%The period varies slightly. this will never be output, but you can
%always gutcheck it here
% P=unique(deltaI);