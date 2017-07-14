function makeWavs(folder,files,addT)
%This function will create the wav files for eGUI to select the syllables
%INPUT: list of ABF files and where they are located
%OUTPUT: it's main 
if ~exist([folder,'eguiWavs\'],'dir')
    mkdir([folder,'eguiWavs\'])
else
    files2rm=dir([folder,'eguiWavs\*.wav']);
    for f=1:length(files2rm)
        delete([folder,'eguiWavs\' files2rm{f}]);
    end
end
audioStart=zeros(1,length(files));
for i=1:length(files)
    [d,si,~]=abfload([folder,'ABF\',files{i}]); %loads the file
    glass=d(:,3);
    glass=glass/max(glass);
    lookat=glass>.2;
    stop=min((find(lookat,1,'last')+round(1/(si*1e-6))*addT),size(d,1));
    lookat=find(lookat,1,'first'):stop;
    wav=d(lookat,2);%only care about when the glass is open
    y=wav/max(abs(wav));
    a=strtok(files{i},'.');
    name=[a,'.wav'];
    audiowrite([folder,'eguiWavs\',filesep,name],y,round(1/(si*1e-6)));
    audioStart(i)=find(glass>.2,1,'first');
end
save([folder,'Notes\Exp.mat'],'files','audioStart');
disp('done')