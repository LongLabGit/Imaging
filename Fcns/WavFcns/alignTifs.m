function Motif=alignTifs(folder)

%INPUT
    %folder: where all your data is located

%OUTPUT
    %Motif has all the data on the individual motifs, aligning the Tifs
if ~exist([folder,'motifWavs\'],'dir')
    mkdir([folder,'motifWavs\'])
end
load([folder,'eguiWavs\MotifTimes.mat'],'Motif');%has in it files and audioStart
%store template file here
load([folder,'eguiWavs\Exp.mat']);%has in it files and audioStart
info = audioinfo([folder,'eguiWavs\template\template.wav']);
tempLength=info.Duration;
songRegion=tempLength*2;
songRegion=[1,1]*songRegion/2;
TrialTimes=Motif;%swap names for my mental health. Motif previosly was based on files, now it is based on individual motifs
Motif=struct('Origname',{},'name',{},'audioF',{},'audioTimes',[],'audioTimesWARP',[],...
    'frames',[],'frameTimes',[],'frameTimesWARP',[],'imagingPWARP',[],'warpFactor',[],'imagingP',[],'numI',[],...
    'ABFsinging',[],'Tiffsinging',[],'TimeSinging',[],'missingS',[]);
motifInd=1;
figure(1);clf;hold on;
cols=lines(length(TrialTimes));
for trial=1:length(TrialTimes)
    %get motif labels
    fprintf(num2str(trial));
    fname=strtok(TrialTimes(trial).file,'.');
    
    %find the name of the corresponding abf-use for offset and abf laoding
    abf=[fname,'.abf'];%turn it into an abf file name
    indAS=strcmp(files,abf);
    offset=audioStart(indAS);%find out which offset it corresponds to
    if sum(indAS)~=1
        disp(abf)
        error('You dont have this file, check to make sure that Notes\Exp is correct')
    else
        [d,si,~]=abfload([folder,'ABF\',abf]); %loads the file
    end
    
    %d1=frame, d2=audio, d3=glass opened
    Fs=round(1/(si*1e-6));%get the sampling rate
    audio=d(:,2)/max(abs(d(:,2)));%get the audio, normalize to 1

    %use this info to find tiff numbers
    [~,stopInd,tiffInd,imagingPeriod]=getTiffInds(d(:,1),Fs,folder,fname);    
    tifRegion=ceil(songRegion/(imagingPeriod/Fs));

    %reshape it into individual motifs
    start=TrialTimes(trial).start*Fs+offset;
    stop=TrialTimes(trial).stop*Fs+offset;
    center=TrialTimes(trial).center*Fs+offset;
    warp=TrialTimes(trial).warp;
    for m=1:length(center)
        Motif(motifInd).Origname=[fname,'.tif'];
        Motif(motifInd).name=[fname,'_',num2str(m),'.tif'];%the name of the tiff file that will be created
        %inds for audio
        inds=(center(m)-songRegion(1)*Fs):(center(m)+songRegion(2)*Fs);
        %now find the images from the tiff
        refFrame=sum(stopInd<center(m))+1;%what frame is our ref point in the middle of?
        f=refFrame-tifRegion(1);
        l=refFrame+tifRegion(2);
        if sum(ismember(1:length(tiffInd),[f,l]))==2%make sure that it had imaging during singing
            %note: every "time" will always be relative to the first good line
            wav2save=audio(inds);%the audio
            audioF=[folder,'motifWavs\',fname,'_' num2str(m) '.wav'];
            audiowrite(audioF,wav2save/2,4e4);%make it lower audio
            Motif(motifInd).audioF=audioF;
            %times for the audio
            t=(inds-center(m))/Fs;%make an index
            Motif(motifInd).audioTimes=[t(1),t(end)];
            %frames we want to take out & their time
            Motif(motifInd).frames=[f,l];%frame numbers within the trial tiff, extended a bit before and after
            Motif(motifInd).frameTimes=(tiffInd(f:l)-center(m))/Fs;%the original number
            
            Motif(motifInd).imagingP=imagingPeriod/Fs;
            %lineLocs starts as referenced to the beginning of the audio.
            %subtract off the reference point (good(1))so it is at 0
            Motif(motifInd).numI=diff(Motif(motifInd).frames)+1;


            %frame numbers within the trial tiff, corresponding to when the 
            %bird was actually singing. ONLY use this for gut check,
            startFrame=sum(stopInd<start(m))+1;%first frame with singing in it
            stopFrame=sum(stopInd<stop(m))+1;%last frame with singing in it   
            %store
            Motif(motifInd).ABFsinging=[startFrame,stopFrame];%subtract one from the second
            Motif(motifInd).Tiffsinging=Motif(motifInd).ABFsinging-Motif(motifInd).frames(1)+1;%subtract one from the first
            Motif(motifInd).TimeSinging=([start(m),stop(m)]-center(m))/Fs;
            %Warp
            Motif(motifInd).audioTimesWARP=Motif(motifInd).audioTimes/warp(m);
            Motif(motifInd).frameTimesWARP=Motif(motifInd).frameTimes/warp(m);
            Motif(motifInd).TimeSingingWARP=Motif(motifInd).TimeSinging/warp(m);
            Motif(motifInd).imagingPWARP=Motif(motifInd).imagingP/warp(m);
            Motif(motifInd).warpFactor=warp(m);
            tWarp=linspace(Motif(motifInd).audioTimesWARP(1),Motif(motifInd).audioTimesWARP(2),length(wav2save));
%             t=linspace(Motif(motifInd).audioTimes(1),Motif(motifInd).audioTimes(2),length(wav2save));
            plot(tWarp,wav2save+motifInd,'color',cols(trial,:))
            line(Motif(motifInd).frameTimesWARP*[1,1],motifInd+[-.5,.5],'color','k');
            %use to set timing
            motifInd=motifInd+1;
        else
            disp(['skipped #',num2str(m),' due to lack of imaging data'])
        end
    end
    drawnow;
end
axis tight;
% names={Motif(:).name};
% for trial=1:length(names)
%     name=names{trial};
%     month(trial)=str2num(name(1:2));
%     day(trial)=str2num(name(4:5));
%     trial(trial)=str2num(name(7:9));
%     motifNum(trial)=str2num(name(end-4));
% end
% [~,index] = sortrows([month;day;trial;motifNum]');
% Motif=Motif(index);
save([folder,'ABF_Extracted.mat'],'Motif')
disp(['Done, total motifs=',num2str(motifInd-1)])