function ExtractFromAbf(folder,params,Vary,syllID)

%INPUT
    %folder: where all your data is located
    %params: 
    %vary:if you have multiple syllables
    %syllID: sometimes we have different syllables in one audio file (e.g. s for
    %syllable, w for sollenoid) in that case we need to tell the program
    %what to look for 

%OUTPUT
    %nothing is output, but it saves a file that has all the parameters 
    %Motif has all the data on the individual motifs
    %params has everything we input to calculate those data in motif

if nargin<4||isempty(syllID)
    syllID='s';
end
%extract paramters
fnms=fieldnames(params); 
for assign_i=1:1:length(fnms) 
    eval([fnms{assign_i} '=params.(fnms{assign_i});' ]); 
end 
%extract bad stuffs
fnms=fieldnames(Bad); 
for assign_i=1:1:length(fnms) 
    eval([fnms{assign_i} '=Bad.(fnms{assign_i});' ]); 
end 
if ~exist([folder,'MotifAudio\'],'dir')
    mkdir([folder,'MotifAudio\'])
end
load([folder,'Notes\Exp.mat']);%has in it files and audioStart
if ~Vary
    eGUI=load([folder,'Notes\','E_GUI.mat']);
else
    eGUI=load([folder,'Notes\','E_GUI',num2str(Vary),'.mat']);
end
eGUI=eGUI.dbase;
egFile={eGUI.SoundFiles(:).name};

%go through each tagged wav file, extract the info from abf
motifInd=1;
mF=1;
for i=1:length(egFile)
    %find the name of the corresponding abf-use for offset and abf laoding
    abf=strtok(egFile{i},'.');
    abf=[abf,'.abf'];%turn it into an abf file name
    offset=audioStart(strcmp(files,abf));%find out which offset it corresponds to
    [d,si,~]=abfload([folder,'ABF\',abf]); %loads the file
    %d1=frame, d2=audio, d3=glass opened
    Fs=round(1/(si*1e-6));%get the sampling rate
    audio=d(:,2)/max(d(:,2)) ;%get the audio, normalize to 1
    
    %use this info to find tiff numbers
    tiffSig=d(:,1)/max(d(:,1));%d(:,1) holds the frame onset offset
    tiffSig=tiffSig>.1;
    ts1=diff(tiffSig);ts1=[0;ts1];

    startInd=find(ts1==1);%the sample number of the start of the Nth tiff
    stopInd=find(ts1==-1);%the sample number of the end of the Nth tiff
    %here we need to account for the fact that michel likes to randomly
    %image the plane. so we need to onnly take the imaging block that has
    %glass within it. but he also might start imaging after glass. so we
    %look for the start that is closest to the start of the glass
    %breaks will be
    deltaI=diff(startInd/Fs);
    breaks=find(deltaI>2)+1;%account for times in which he stops imaging for a bit and then starts again
    if ~isempty(breaks)
        breaks=[1;breaks;length(startInd)];%breaks represents the end points of regions within imaging
        glass=d(:,3)/max(d(:,3));
        glassOn=find(glass>.2,1,'first');%when the glass turns on
        imagingOn=startInd(breaks);%when the glass turns on
        [~,ind]=min(abs(imagingOn-glassOn));%find the closest region
        keep=breaks(ind:ind+1);
        startInd=startInd(keep(1):keep(2));
        stopInd=stopInd(keep(1):keep(2));
    end
    P=unique(deltaI);%it varies slightly
    
    %get motif labels
    sylls=eGUI.SegmentTitles{1,i};
    ss=find(strcmp(sylls,syllID));%everywhere there is an s (or w or whatever)
    %if 
    if mod(length(ss),nSyllables) && ~sum(strcmp(probFiles,egFile{i}))
        WrongNumSyll{mF}=egFile{i};
        mF=mF+1;
        go=0;
    else
        go=1;
    end
    if ~isempty(ss)&&go%make sure that we have something
        %reshape it into individual motifs
        %create indices that correspond to ss's beginnings and ends of motifs
        change=diff(ss);%NOTE: this will fail if there are no intervening syllables
        syllStarts=[1,1+find(~(change==1))];%it will of course always include the first one
        syllEnds=[syllStarts(2:end)-1,length(ss)];
        singing=nan(length(syllStarts),nSyllables);
        for m=1:length(syllStarts)
            inds=syllStarts(m):syllEnds(m);
            singing(m,1:length(inds))=ss(inds);
        end
        %get eGUI index
        Seg_Times=eGUI.SegmentTimes{i}+offset;
        %make sure that there are no problems
        if sum(strcmp(probFiles,egFile{i}))
            MissingGapM=find(strcmp(probFiles,egFile{i}));
            probs=probMotifs{MissingGapM};
        else 
            probs=[];
        end
        for m=1:size(singing,1)
            %write down the name of the file so that we do not take from the
            %wrong location
            abfF=strtok(abf,'.');%remove the ending
            Motif(motifInd).Origname=[abfF,'.tif'];
            if ~Vary
                Motif(motifInd).name=[abfF,'_',num2str(m),'.tif'];%the name of the tiff file that will be created
            else
                Motif(motifInd).name=[abfF,'_s',num2str(nSyllables),'_',num2str(m),'.tif'];%the name of the tiff file that will be created
            end
            st=singing(m,:);
            st=st(~isnan(st));
            onsets=Seg_Times(st,1)';
            offsets=Seg_Times(st,2)';
            %here we need to place some nan's between offsets and onsets
            p=ismember(probs,m);
            if sum(p)
                gapsMissed=probGaps{MissingGapM}(p);
                for g=gapsMissed%needed to flip this to be a row vector. weird. 
                    onsets=[onsets(1:g),NaN,onsets(g+1:end)];
                    offsets=[offsets(1:g-1),NaN,offsets(g:end)];
                end
            end
            %interleave them. 
            for nm=1:nSyllables
                lineLocs(nm*2-1:nm*2)=[onsets(nm),offsets(nm)];
            end
            %here use diff definitions to grab motif
            %if it is present and it is not a member of bad shift,
            %here ,make it smarter by setting a parameter shift that will be
            %equal to the first member of good that isnt a NaN in lineLocs and
            %isnt under the restrictions of badShift;
            %if it is a bad shfit, dont use its first point, but rather use the
            %second
            badLineMotif=strcmp(badMotifs,Motif(motifInd).name);
            if sum(badLineMotif)
                goodM=good(~ismember(good,badLines(badLineMotif)));
            else
                goodM=good;
            end
            refLocOpts=lineLocs(goodM);%get all the options
            goodM=goodM(~isnan(refLocOpts));%throw out the nans
            refLocOpts=refLocOpts(~isnan(refLocOpts));%remove the NaNs
            refLoc=refLocOpts(1);%take the first option that is a real number
            %EVERYTHING CENTERS AROUND SHIFT. THIS IS OUR ONLY REFERENCE
            %POINT
            
            %find the first option that is more than minWarpDist away
            %need to align and warp
            align=good(lineLocs(good)==refLoc);%find which point we are aligning to
            warpOpts=goodM(abs(goodM-align)>=minWarpDist);
            if ~isempty(warpOpts)%need to have at least two good points
                taken=find(lineLocs(good)==refLoc);%which number of good did we end up taking?
                %inds for audio
                inds=(refLoc-songRegion(taken,1)*Fs):(refLoc+songRegion(taken,2)*Fs);
                %now find the images from the tiff
                refFrame=sum(stopInd<refLoc)+1;%what frame is our ref point in the middle of?
                f=refFrame-addTif(taken,1);
                l=refFrame+addTif(taken,2);
                
                %note: every "time" will always be relative to the first good line
                wav2save=audio(inds);%the audio
                fName=strtok(Motif(motifInd).name,'.');
                fName=[fName,'.wav'];%the file name 
                audiowrite(fName,wav2save,4e4)
                Motif(motifInd).audio=
                %times for the audio
                Motif(motifInd).audioTimes=(inds-refLoc)/Fs;%make an index
                %frames we want to take out & their time
                Motif(motifInd).frames=[f,l];%frame numbers within the trial tiff, extended a bit before and after
                Motif(motifInd).frameTimes=((startInd(f:l)+stopInd(f:l))/2-refLoc)/Fs;%the orignal number

                %lineLocs starts as referenced to the beginning of the audio.
                %subtract off the reference point (good(1))so it is at 0
                Motif(motifInd).EguiTimes=(lineLocs-lineLocs(goodM(1)))/Fs;
                Motif(motifInd).numI=diff(Motif(motifInd).frames)+1;


                %frame numbers within the trial tiff, corresponding to when the 
                %bird was actually singing. ONLY use this for gut check,
                lineLocs=lineLocs(~isnan(lineLocs));
                startFrame=sum(stopInd<lineLocs(1))+1;%first frame with singing in it
                stopFrame=sum(stopInd<lineLocs(end))+1;%last frame with singing in it   
                %store
                Motif(motifInd).ABFsinging=[startFrame,stopFrame];%subtract one from the second
                Motif(motifInd).Tiffsinging=Motif(motifInd).ABFsinging-Motif(motifInd).frames(1)+1;%subtract one from the first
                Motif(motifInd).TimeSinging=([lineLocs(1),lineLocs(end)]-refLoc)/Fs;
                %use to set timing
                Motif(motifInd).alignPts=[align,warpOpts(1)];
                motifInd=motifInd+1;
            else
                disp(['no warp points for ',Motif(motifInd).name])
            end
            
        end
    end
end
%now create a structure with all the little details that we will need
params.Fs=Fs;
%arrange them in temporal order
names={Motif(:).name};
for i=1:length(names)
    name=names{i};
    month(i)=str2num(name(1:2));
    day(i)=str2num(name(4:5));
    trial(i)=str2num(name(7:9));
    motifNum(i)=str2num(name(end-4));
end
[~,index] = sortrows([month;day;trial;motifNum]');
Motif=Motif(index);

if ~Vary
    save([folder,'ABF_FirstStep.mat'],'Motif','params')
else
    save([folder,'ABF_FirstStep',num2str(Vary),'.mat'],'Motif','params')
end
if mF>1
    disp('here are the files that have the incorrect number of syllables in EGUI')
    disp(WrongNumSyll)
end
disp(['Done, total motifs=',num2str(motifInd-1)])