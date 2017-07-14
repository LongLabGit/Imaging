function JoinABFs(folder)
%This function is for when we have different number of syllables

%Delete it if it was already made since we are remaking it


allOptions=dir([folder,'ABF*.mat']);
allOptions={allOptions(:).name};
if length(allOptions)>1
    if exist ([folder,'ABF_Output.mat'],'file')
        delete([folder,'ABF_Output.mat'])
    end
    for i=1:length(allOptions)
        a=load([folder,allOptions{i}]);
        if exist('Motif','var')
            Motif=[Motif,a.Motif];
        else
            Motif=a.Motif;
        end
        S(i)=a.params.nSyllables;%DONT DO THIS, COMBINE BAD
    end
    %params will be the same for all, just the number of syllables will be
    %different
    params=a.params;
    params.nSyllables=unique(sort(S));
    save([folder,'ABF_Output.mat'],'Motif','params')
else
    disp('You have nothing to combine')
end