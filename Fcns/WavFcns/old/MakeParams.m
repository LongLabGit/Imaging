function params=MakeParams(folder)
%this will give all the paramters thatyou need into the extract from abf
% im doing it like this because it was annoying to do all the birds each
% time
edit([folder,'Notes\ParamsforEFA'])%this is what you are using
clear([folder,'Notes\ParamsforEFA']) ;
run([folder,'Notes\ParamsforEFA']);

% missing gaps
folder=[folder,'Notes\'];
excelFile=[folder,'MissingGaps.xlsx'];
[~,~,All]=xlsread(excelFile);
All=All(2:end,:);
inds=cellfun(@isnan,All(:,3));
All(inds,:)=[];
noGap=struct('Files',{},'Motifs',{},'Gaps',{});
if ~isempty(All)
    FileName=All(:,1);
    Motifs=[All{:,2}];
    Gaps=[All{:,3}];
    names=unique(FileName);
    for n=1:length(names)
        noGap(1).Files{n}=strtrim(names{n});
        mInds=find(strcmp(FileName,names{n}));
        noGap(1).Motifs{n}=Motifs(mInds);
        noGap(1).Gaps{n}=Gaps(mInds);
    end
end

% missing syllables
excelFile=[folder,'Missingsyllables.xlsx'];
[~,~,All]=xlsread(excelFile);
All=All(2:end,:);
inds=cellfun(@isnan,All(:,3));
All(inds,:)=[];
noSyll=struct('Files',{},'Motifs',{},'Gaps',{});
if ~isempty(All)
    FileName=All(:,1);
    Motifs=[All{:,2}];
    Sylls=[All{:,3}];
    names=unique(FileName);
    for n=1:length(names)
        noSyll(1).Files{n}=strtrim(names{n});
        mInds=find(strcmp(FileName,names{n}));
        noSyll(1).Motifs{n}=Motifs(mInds);
        noSyll(1).Sylls{n}=Sylls(mInds);
    end
end

%bad lines
%note: here we do NOT need to know which file it is in, since we remove
%this in the time warping step, not in the abf extraction set
excelFile=[folder,'BadLines.xlsx'];
[~,~,All]=xlsread(excelFile);
All=All(2:end,:);
inds=cellfun(@isnan,All(:,2));
All(inds,:)=[];
rmLine=struct('Motifs',{},'Lines',{});
if ~isempty(All)
    rmLine(1).Motifs=strtrim(All(:,1));
    rmLine(1).Lines=[All{:,2}];
end
%store it
params.noGap=noGap;
params.noSyll=noSyll;
params.rmLine=rmLine;


numFrames=sum(params.addTif,2);
if length(unique(numFrames))>1
    error('Keep all frames the same')
end