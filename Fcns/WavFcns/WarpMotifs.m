function M=WarpMotifs(folder,Motif,params,ds,split)
close all
Warp=params.Warp;
rmLine=params.rmLine;
%remove any that didnt warp well
if isfield(params,'removePostWarp');
    Motif(params.removePostWarp)=[];
end
ticC=zeros(length(Motif),3);%make tics black
%% Unwarped
%at this stage we cannot do secondary alignment because we dont know where the second point is 
%note that this will cause the motifs to be screwey
for i=1:length(Motif)
    if mod(i,split)==1
        figure;hold on;
    end
    %extract the info we need
    af=Motif(i).audioF;
    audio=audioread(af);
    tStart=Motif(i).audioTimes(1);
    tStop=Motif(i).audioTimes(2);
    if ds>1
        [audioMin,audioMax,tStop]=audioBounds(audio,ds,tStop);
        t=linspace(tStart,tStop,length(audioMax))+ds/4e4/2;%add in a shift so that it is centered
%         [y,tRMS] = rms(audio,ds,round(ds/2),0,4e4)%this is an alternative option
        plot(t,audioMax+i,'b')
        plot(t,audioMin+i,'b')
    else
        t=linspace(Motif(i).audioTimes(1),Motif(i).audioTimes(2),length(audio));
        plot(t,audio+i)
    end
    lines=Motif(i).EguiTimes;
    tics=Motif(i).frameTimes;
    %put on the lines at each segment
    for l=1:2:length(lines)
        line(lines(l)*[1,1],[i-.5,i+.5],'Color','g','LineWidth',2)
        line(lines(l+1)*[1,1],[i-.5,i+.5],'Color','r','LineWidth',2)
    end
    %put the tiff lcos on
    for ticNum=1:length(tics)
        line(tics(ticNum)*[1,1],[i-.4,i+.4],'Color',ticC(i,:),'LineWidth',1)
    end
    if mod(i,split)==0||i==length(Motif)
        axis tight
        xlabel('Time')
        ylabel('Motif #')
        title('Unwarped')
        set(gca,'TickDir','out')
    end
end
%% Warped

% occasionally you'll get a bird with different number of syllables
if length(params.nSyllables)==1%if there is only one, reshape it
    eGUIlocs=reshape([Motif(:).EguiTimes],size(Motif(1).EguiTimes,2),length(Motif));%get out all of the lines
else%if not, fill in nans where it is missing 
    maxS=max(params.nSyllables);
    eGUIlocs=nan(maxS,length(Motif));
    for i=1:length(Motif)
        eGUIlocs(1:length(Motif(i).EguiTimes),i)=Motif(i).EguiTimes;
    end
end
%remove any lines that were bad so that they dont influence calculations
names={Motif(:).name};
if ~isempty(rmLine)
    for i=1:length(rmLine.Motifs)
        m=strcmp(names,rmLine.Motifs{i});
        badLines=rmLine.Lines(i);
        eGUIlocs(badLines,m)=NaN;
    end
end


for i=1:length(Motif)
    if mod(i,split)==1
        figure;hold on;
    end
    %extract the info we need
    af=Motif(i).audioF;
    audio=audioread(af);
    tStart=Motif(i).audioTimes(1);
    tStop=Motif(i).audioTimes(2);
    if ds>1
        numCuts=ceil(length(audio)/ds);
        addlen=numCuts*ds-length(audio);
        audio=[audio;zeros(addlen,1)];%zero pad the end
        tStop=tStop+addlen/4e4;%increase this part
        audioBox=reshape(audio',ds,numCuts);
        audioMax=max(audioBox,[],1);
        audioMin=min(audioBox,[],1);
        t=linspace(tStart,tStop,length(audioMax))+ds/4e4/2;%add in a shift so that it is centered
    else
        t=linspace(Motif(i).audioTimes(1),Motif(i).audioTimes(2),length(audio));
    end
    lines=Motif(i).EguiTimes;    tics=Motif(i).frameTimes;  tO=Motif(i).audioTimes;
    %up until here it was the same, but now we are going to multiply t and
    %lines by a factor r, which represents length(median)/length(this
    %segment)
    %here we need to update its Times if it had a bad 1st reference (if
    %it has two bad first ones we throw it out
    %make sure we didnt change it already (if we did and we want to
    %change it differently we have to regenerate it)
    %calculate r
    pts=Motif(i).alignPts;
    all_len=diff(eGUIlocs(pts,:));
    l_mean=nanmean(all_len);%the average length of all the motifs corresponding segment
    l_curr=diff(lines(pts));%the length in samples of the current motif's segment
    r=l_mean/l_curr; %Comment that if you don't want to use warping
    if abs(r-1)>.1
        disp(i)
        disp('somethings fucky, warping is too much. probably misaligned syllables')
    end
%     r=1;%if we are doing solenoid stuff
    Motif(i).warpFactor=r;
    %if r is large, that means that this motif is short and we need to
    %lengthen its time vector
    t=t*r;%shorten/elongate it by its factor. 
    lines=lines*r;
    tics=tics*r;
    tO=tO*r;
    %add the time AFTER you warp, otherwise you'll warp your 2nd point away
    %from where it should be
%     if Motif(i).alignPts(1)==good(2)
%         %add on location of the secondary point (it will be negative if
%         %the second point is before the first
%         all_len=diff(eGUIlocs(good(1:2),:));
%         ScndPt=nanmean(all_len);%the average length of all the motifs corresponding segment
%         tics=tics+ScndPt;
%         lines=lines+ScndPt;
%         tO=tO+ScndPt;
%         t=t+ScndPt;
%     elseif length(good)>2&&Motif(i).alignPts(1)==good(3)
%         %add on location of the secondary point (it will be negative if
%         %the second point is before the first
%         all_len=diff(eGUIlocs(good([1,3]),:));
%         ScndPt=nanmean(all_len);%the average length of all the motifs corresponding segment
%         tics=tics+ScndPt;
%         lines=lines+ScndPt;
%         t=t+ScndPt;
%     end
    
    offsets=diff(eGUIlocs([Warp(1),Motif(i).alignPts(1)],:));
    offset=nanmean(offsets);
    tics=tics+offset;
    lines=lines+offset;
    t=t+offset;
    tO=tO+offset;
    
    if ds>1
        plot(t,audioMax+i,'b')
        plot(t,audioMin+i,'b')
    else
        plot(t,audio+i,'b')
    end
    %put on the lines at each segment
    for l=1:2:length(lines)
        line(lines(l)*[1,1],[i-.5,i+.5],'Color','g','LineWidth',2)
        line(lines(l+1)*[1,1],[i-.5,i+.5],'Color','r','LineWidth',2)
    end
    %put the tiff lcos on
    for ticNum=1:length(tics)
        line(tics(ticNum)*[1,1],[i-.4,i+.4],'Color',ticC(i,:),'LineWidth',1)
    end
    %store all the warped times. note that they stay the same in reference
    %to eachother
    if mod(i,split)==0||i==length(Motif)
        axis tight
        xlabel('Time')
        ylabel('Motif #')
        title('Linearly Warped')
        set(gca,'TickDir','out')
    end
    Motif(i).audioTimesWARP=tO;
    Motif(i).EguiTimesWARP=lines;
    Motif(i).frameTimesWARP=tics;
    Motif(i).TimeSingingWARP=Motif(i).TimeSinging*r+offset;
end

%% overwrite ABF_ouput, now with xlocs
save([folder,'ABF_Warped.mat'],'Motif','params')
disp('Finished Saving')
M=Motif;