function [Onsets,ROIs]=concatenateOnsets(F,planes)
[indR,indO]=deal(0);
for p=1:length(planes)
    load([F planes{p} '\InitialC.mat']);
    R=load([F planes{p} '\allROIs.mat']);
    for c=1:length(InitialC)
        InitialC(c).inds=InitialC(c).inds+indR;
        InitialC(c).cID=InitialC(c).cID+indO;
    end
    if strcmp(F,'Data\383\')
        for r=1:length(R.ROIs)
            %get rid of PA/PB
            R.ROIs(r).f=strrep(R.ROIs(r).f,' PA','');
            R.ROIs(r).f=strrep(R.ROIs(r).f,' PB','');
            %remove spaces
            R.ROIs(r).f=strrep(R.ROIs(r).f,' ','');
        end
    end
    %concatenate them
    if p==1
        Onsets=InitialC;
        ROIs=R.ROIs;
    else
        Onsets=[Onsets,InitialC];
        ROIs=[ROIs,R.ROIs];
    end
    indR=length(ROIs);
    indO=max([Onsets.cID]);
end
Onsets=rmfield(Onsets,{'rmsub','creationT','paramOD','time','traces'});