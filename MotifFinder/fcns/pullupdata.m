function pullupdata(hObject)
handles=guidata(hObject);
load fcns\StandardPaths.mat
prompt = {'Folder Name','Template File','Threshold'};
dlg_title = 'Load Data';
defaultans = {folder,...                         %Change this to last path
              template,...
                threshold};
answer = inputdlg(prompt,dlg_title,[1,70],defaultans);
if ~isempty(answer)
    F=answer{1};
    template=answer{2};
    thresh=str2num(answer{3});
    if ~strcmp(F(end),'/')
        F=[F,'/'];
    end
    files=dir([F,'*.wav']);
    if isempty(files)
        error('Have you tried giving me a folder with wav files in it YOU DUMKOPF?')
    end
    if ~strcmp(template(end-3:end),'.wav')
        error('maybe next time give me a wave file for a template, ya?')
    end
    files={files.name};

    folder=F;
    threshold=answer{3};

    prevAnalysis=[F,'MotifTimes.mat'];
    if exist(prevAnalysis,'file')
        button = questdlg('You already analyzed this. Redo?','Ack!','Redo','Load Prev','Load Prev');
        if strcmp(button,'Load Prev')
            analyze=0;
        else
            analyze=1;
        end
    end

    if analyze
        for f=1:length(files)
            [start,stop,center,warp]=findMotifs([F,files{f}],template,thresh);
            Motif(f).start=start;
            Motif(f).stop=stop;
            Motif(f).center=center;
            Motif(f).warp=warp;
            Motif(f).thresh=thresh;
        end
        save([F,'MotifTimes_FirstPass.mat'],'Motif');
    else
        load(prevAnalysis) 
    end
    
    info = audioinfo([F,files{1}]);
    handles.currF=1;
    handles.F=F;
    handles.fs=info.SampleRate;
    handles.files=files;
    handles.template=template;
    handles.Motif=Motif;
    info=audioinfo(template);
    handles.tempLength=info.Duration;
    save fcns\StandardPaths.mat threshold folder template
    guidata(hObject,handles);
else
    error('no file provided')
end