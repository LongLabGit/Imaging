function Motif=WarpMotifsPL(folder,Motif,params,ds,split)
close all
good=params.good;
rmLine=params.rmLine;
%remove any that didnt warp well
if isfield(params,'removePostWarp');
    Motif(params.removePostWarp)=[];
end
ticC=zeros(length(Motif),3);%make tics black
%% Unwarped
if 1%set to 0 for debugging
    %at this stage we cannot do secondary alignment because we dont know where the second point is 
    %note that this will cause the motifs to be screwey
    for i=1:length(Motif)
        if mod(i,split)==1
            figure;hold on;
        end
        %extract the info we need
        af=strrep(Motif(i).audioF,'192','192\All\');
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
    if mod(i,split)==1%if its the first of a new set
        figure;hold on;
    end
    %extract the info we need
%     af=strrep(Motif(i).audioF,'192','192\All\');
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
    lines=Motif(i).EguiTimes;
    tics=Motif(i).frameTimes;
    %up until here it was the same, but now we are going to multiply t and
    %lines by a factor r, which represents length(median)/length(this
    %segment)
    %here we need to update its Times if it had a bad 1st reference (if
    %it has two bad first ones we throw it out
    %make sure we didnt change it already (if we did and we want to
    %change it differently we have to regenerate it)
    %calculate r
    pts=sort(Motif(i).alignPts);
    all_len=diff(eGUIlocs(pts,:));
    l_mean=nanmean(all_len,2)';%the average length of all the motifs corresponding segment
    l_curr=diff(lines(pts));%the length in samples of the current motif's segment
    r=l_mean./l_curr;
%   r=1;%if we are doing solenoid stuff
    %if r is large, that means that this motif is short and we need to
    %lengthen its time vector
    
    if length(r)==1
        o=0;
        t=t*r;%shorten/elongate it by its factor. 
        lines=lines*r;
        tics=tics*r;
    elseif length(r)==2
        o=[max(l_curr(1),0),min(l_curr(2),0)];
        %PEICEWISE LINEAR
        tCenter=lines(pts(2));%we warp differently depending on the center line, independent if it is ref or not
        t1=t;lines1=lines;tics1=tics;
        t(t1<=tCenter)=(t(t1<tCenter)-o(2))*r(1)+o(2)*r(2);
        t(t1>tCenter)=(t(t1>tCenter)-o(1))*r(2)+o(1)*r(1); 

        lines(lines1<=tCenter)=(lines(lines1<=tCenter)-o(2))*r(1)+o(2)*r(2);
        lines(lines1>tCenter)=(lines(lines1>tCenter)-o(1))*r(2)+o(1)*r(1); 

        tics(tics1<=tCenter)=(tics(tics1<tCenter)-o(2))*r(1)+o(2)*r(2);
        tics(tics1>tCenter)=(tics(tics1>tCenter)-o(1))*r(2)+o(1)*r(1); 
    end
    Motif(i).warpFactor=r;
    Motif(i).warpOffset=o;

    
    
    
    %WRONG REFERNCE FRAME
    %add the time AFTER you warp, otherwise you'll warp your 2nd point away
    %from where it should be
    if Motif(i).alignPts(1)==good(2)
        %add on location of the secondary point (it will be negative if
        %the second point is before the first
        all_len=diff(eGUIlocs(good(1:2),:));
        ScndPt=nanmean(all_len);%the average length of all the motifs corresponding segment
        tics=tics+ScndPt;
        lines=lines+ScndPt;
        t=t+ScndPt;
    elseif Motif(i).alignPts(1)==good(3)
        %add on location of the secondary point (it will be negative if
        %the second point is before the first
        all_len=diff(eGUIlocs(good([1,3]),:));
        ScndPt=nanmean(all_len);%the average length of all the motifs corresponding segment
        tics=tics+ScndPt;
        lines=lines+ScndPt;
        t=t+ScndPt;
    end
    
    %PLOT STUFF
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
%     Motif(i).audioTimesWARP=[t(1),t(end)];
    Motif(i).EguiTimesWARP=lines;
    Motif(i).frameTimesWARP=tics;
%     Motif(i).TimeSingingWARP=Motif(i).TimeSinging*r;
end
%% Collapsed
% [~,mSel]=min(abs(all_len-l_mean));
% Motif(mSel).MeanMotif=1;
% motifs2plot=1:length(Motif);
% if plotFull
%     figure(3)
%     lines=Motif(mSel).EguiTimesWARP;
%     meanMotif=audioread(Motif(mSel).audioF);
%     t=linspace(Motif(mSel).audioTimesWARP(1),Motif(mSel).audioTimesWARP(2),length(meanMotif));
%     plot(t,meanMotif)
%     hold on
%     % put on the lines at each segment
%     for l=1:2:length(lines)
%         line(lines(l)*[1,1],[-.5,.5],'Color','g','LineWidth',2)
%     end
%     for l=2:2:length(lines)
%         line(lines(l)*[1,1],[-.5,.5],'Color','r','LineWidth',2)
%     end
%     %     put the tiff lcos on
%     for i=1:length(motifs2plot)
%         tics=Motif(motifs2plot(i)).frameTimesWARP;
%         for t=1:length(tics)
%             plot(tics(t)*[1,1],[-.1,+.1],'Color',ticC(i,:),'LineWidth',.01)
%         end
%     end
%     axis tight
%     xlabel('Time')
%     ylabel('Motif #')
%     title('Collapsing all images')
%     set(gca,'TickDir','out')
% end
%% bins
% xloc=vertcat(Motif(:).frameTimesWARP);
% perc=[.04,.02,.01,.005];
% nbins=1./perc;
% binLength=(max(xloc)-min(xloc))*perc*1e3;
% if plotFull
%     figure(4)
%     for i=1:4
%         subplot(2,2,i)
%         a=hist(xloc,nbins(i));
%         hist(xloc,nbins(i));
%         title([num2str(binLength(i),2),' ms, ',num2str(mean(a),3),' avg size'])
%         axis tight
%     end
% end
%% overwrite ABF_ouput, now with xlocs
save([folder,'ABF_Final.mat'],'Motif','params')
disp('Finished Saving')