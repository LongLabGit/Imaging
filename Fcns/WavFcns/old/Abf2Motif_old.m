function [Motif,WrongNumSyll]=Abf2MotifPL(folder,params,syllID)

%INPUT
    %folder: where all your data is located
    %params: 
    %syllID: sometimes we have different syllables in one audio file (e.g. s for
    %syllable, w for sollenoid) in that case we need to tell the program
    %what to look for 

%OUTPUT
    %nothing is output, but it saves a file that has all the parameters 
    %Motif has all the data on the individual motifs
    %params has everything we input to calculate those data in motif

if nargin<3||isempty(syllID)
    syllID='s';
end
WrongNumSyll={};
%extract paramters
fnms=fieldnames(params); 
for assign_i=1:1:length(fnms) 
    eval([fnms{assign_i} '=params.(fnms{assign_i});' ]); 
end 
if ~exist([folder,'motifWavs\'],'dir')
    mkdir([folder,'motifWavs\'])
end
load([folder,'Notes\Exp.mat']);%has in it files and audioStart
eGUI=load([folder,'Notes\','E_GUI.mat']);
eGUI=eGUI.dbase;
if isfield(params,'rmFiles')
    ind=ismember({eGUI.SoundFiles(:).name},params.rmFiles);
    eGUI.SoundFiles(ind)=[];
    eGUI.SegmentTimes(ind)=[];
    eGUI.SegmentTitles(ind)=[];
end
egFile={eGUI.SoundFiles(:).name};

%go through each tagged wav file, extract the info from abf
motifInd=1;%index of the motif
mF=1;%use this for gut checking the EGUI folder
for trialInd=20%1:length(egFile)
    %get motif labels
    sylls=eGUI.SegmentTitles{1,trialInd};
    ss=find(strcmp(sylls,syllID));%everywhere there is an s (or w or whatever)
    %gut check-instead of throwing an error, this will save th motifs that
    %did not have the right number of syllables, but where not highlighted
    %in the notes
    noted=sum(strcmp([noGap.Files,noSyll.Files],egFile{trialInd}));
    if mod(length(ss),nSyllables) && ~noted
        WrongNumSyll{mF}=egFile{trialInd};
        mF=mF+1;
        go=0;
    else
        go=1;
    end
    if ~isempty(ss)&&go%make sure that we have something and no problem with it
        fprintf(num2str(trialInd));
        %find the name of the corresponding abf-use for offset and abf laoding
        fname=strtok(egFile{trialInd},'.');
        abf=[fname,'.abf'];%turn it into an abf file name
        offset=audioStart(strcmp(files,abf));%find out which offset it corresponds to
        [d,si,~]=abfload([folder,'ABF\',abf]); %loads the file
        %d1=frame, d2=audio, d3=glass opened
        Fs=round(1/(si*1e-6));%get the sampling rate
        audio=d(:,2)/max(d(:,2)) ;%get the audio, normalize to 1

        %use this info to find tiff numbers
        [~,stopInd,tiffInd]=getTiffInds(d(:,1),d(:,3),Fs);
        i=Tiff([folder,'\1-Orig\',fname,'.tif'],'r');
        try 
            i.setDirectory(length(tiffInd));
            %sometimes it is longer than the actual tiff. if this happens
            %its ok, we just use the first couple
        catch
            abfN=length(tiffInd);
            tiffN=length(imfinfo([folder,'\1-Orig\',fname,'.tif']));
            disp(['tiff is too short!, expected ',num2str(abfN),' got ',num2str(tiffN)])
        end
        if ~i.lastDirectory
            abfN=length(tiffInd);
            tiffN=length(imfinfo([folder,'\1-Orig\',fname,'.tif']));
            disp(['tiff is too long, expected ',num2str(abfN),' got ',num2str(tiffN)])
        end
        %reshape it into individual motifs
        %create indices that correspond to ss's beginnings and ends of motifs
        %get eGUI index
        Seg_Times=eGUI.SegmentTimes{trialInd}+offset;
        m=1;%the index of the motif for the current file
        while length(ss)>1%while we still have syllables left
            %write down the name of the file so that we do not take from the
            %wrong location
            abfF=strtok(abf,'.');%remove the ending
            Motif(motifInd).Origname=[abfF,'.tif'];
            Motif(motifInd).name=[abfF,'_',num2str(m),'.tif'];%the name of the tiff file that will be created
            %get the indices of ss
            %however, there are two reasons that a syllable might be
            %missing: either it is a gap that was bridged (so missing the
            %end and beginning), or a syllable was missing (so it is
            %missing a beginning and an end)
            indNSS=[];indNGG=[];
            %check for a missing syllable
            if ~isempty(noSyll)
                indNSF=find(strcmp(noSyll.Files,egFile{trialInd}));%do we match a file?
                if ~isempty(indNSF)
                    indNSM=noSyll.Motifs{indNSF};%if we do, do we match a motif?
                    indNSS=noSyll.Sylls{indNSF}(indNSM==m);%if we do, what syllable is missing?
                end
            end
            %check for a missing gap
            if ~isempty(noGap)
                indNGF=find(strcmp(noGap.Files,egFile{trialInd}));
                if ~isempty(indNGF)
                     indNGM=noGap.Motifs{indNGF};
                     indNGG=noGap.Gaps{indNGF}(indNGM==m);
                end
            end
            %first just know that your syllables will be shortened
            selS=1:(nSyllables-(length(indNSS)+length(indNGG)));
            singing=ss(selS);
            if length(unique(diff(singing)))>1
                error(['Missed notes in motif #',num2str(m),', nSyll=',num2str(length(singing))])
            end
            ss(selS)=[];%remove those now that we used them
            %index of onset/offset of the syllables
            onsets=Seg_Times(singing,1)';
            offsets=Seg_Times(singing,2)';
            %now we need to put in the missing values as NaNs
            if sum(indNGG)%put in the gaps
                for g=indNGG%needed to flip this to be a row vector. weird. 
                    onsets=[onsets(1:g),NaN,onsets(g+1:end)];
                    offsets=[offsets(1:g-1),NaN,offsets(g:end)];
                end
            end
            if sum(indNSS)%put in the lack of syllables
                inds=true(nSyllables,1);
                inds(indNSS)=false;
                onsets2=nan(nSyllables,1);offsets2=nan(nSyllables,1);
                onsets2(inds)=onsets;onsets=onsets2;
                offsets2(inds)=offsets;offsets=offsets2;
            end
            
            
            %interleave them.
            for nm=1:nSyllables
                lineLocs(nm*2-1:nm*2)=[onsets(nm),offsets(nm)];
            end
            
            %some lines are wrong. we dont care unless they are part of
            %"good"
            if ~isempty(rmLine)
                badLineMotif=strcmp(rmLine.Motifs,Motif(motifInd).name);
                if sum(badLineMotif)
                    goodM=good(~ismember(good,rmLine.Lines(badLineMotif)));
                else
                    goodM=good;
                end
            else
                goodM=good;
            end
            %goodM is good that we are keeping
            refLocOpts=lineLocs(goodM);%get all the options
            goodM=goodM(~isnan(refLocOpts));%throw out the nans
            refLocOpts=refLocOpts(~isnan(refLocOpts));%remove the NaNs
            refLoc=refLocOpts(1);%take the first option that is a real number
            %EVERYTHING CENTERS AROUND SHIFT. THIS IS OUR ONLY REFERENCE
            %POINT
            
            %find the first option that is more than minWarpDist away
            %need to align and warp
            align=good(lineLocs(good)==refLoc);%find which point we are aligning to
            %get first warp point
            Wp1=goodM(abs(goodM-align)>=minWarpDist);%finds anything that is more than minWarp away
            if ~isempty(Wp1)
                Wp1=Wp1(1);
            end
            Wp2=goodM((abs(goodM-Wp1)>=minWarpDist)&(abs(goodM-align)>=minWarpDist));%needs to be far enough frmo both
            if ~isempty(Wp2)
                Wp2=Wp2(1);
            end
            if ~isempty(Wp1)%need to have at least two good points
                taken=find(lineLocs(good)==refLoc);%which number of good did we end up taking?
                %inds for audio
                inds=(refLoc-songRegion(taken,1)*Fs):(refLoc+songRegion(taken,2)*Fs);
                %now find the images from the tiff
                refFrame=sum(stopInd<refLoc)+1;%what frame is our ref point in the middle of?
                if mode(diff(tiffInd))/4e4<.02;
                    mult=2;
                else
                    mult=1;
                end
                f=refFrame-addTif(taken,1)*mult;
                l=refFrame+addTif(taken,2)*mult;
                if sum(ismember(1:length(tiffInd),[f,l]))==2%make sure that it had imaging during singing
                    %note: every "time" will always be relative to the first good line
                    wav2save=audio(inds);%the audio
                    fName=strtok(Motif(motifInd).name,'.');%remove the tiff
                    fName=[folder,'motifWavs\',fName,'.wav'];%the file name 
                    audiowrite(fName,wav2save/2,4e4);%make it lower audio
                    Motif(motifInd).audioF=fName;
                    %times for the audio
                    t=(inds-refLoc)/Fs;%make an index
                    Motif(motifInd).audioTimes=[t(1),t(end)];
                    %frames we want to take out & their time
                    Motif(motifInd).frames=[f,l];%frame numbers within the trial tiff, extended a bit before and after
                    Motif(motifInd).frameTimes=(tiffInd(f:l)-refLoc)/Fs;%the original number

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
                    Motif(motifInd).alignPts=[align,sort([Wp1,Wp2])];
                    Motif(motifInd).syllMiss=indNSS;
                    motifInd=motifInd+1;
                else
                    disp(['skipped #',num2str(m),' due to lack of imaging data'])
                end
            else
                disp(['no warp points for ',Motif(motifInd).name])
                motifInd=motifInd+1;
            end
           m=m+1;%increase the index of the motif in this file
           %remove the points from ss that we used
        end
    end
end
%now create a structure with all the little details that we will need
params.Fs=Fs;
%arrange them in temporal order
%currently they are arranged according to the electrogui file, which might
%not be in order
names={Motif(:).name};
for trialInd=1:length(names)
    name=names{trialInd};
    month(trialInd)=str2num(name(1:2));
    day(trialInd)=str2num(name(4:5));
    trial(trialInd)=str2num(name(7:9));
    motifNum(trialInd)=str2num(name(end-4));
end
[~,index] = sortrows([month;day;trial;motifNum]');
Motif=Motif(index);

save([folder,'ABF_FirstStep.mat'],'Motif','params')
if mF>1
    disp('here are the files that have the incorrect number of syllables in EGUI')
    disp(WrongNumSyll)
end
disp(['Done, total motifs=',num2str(motifInd-1)])