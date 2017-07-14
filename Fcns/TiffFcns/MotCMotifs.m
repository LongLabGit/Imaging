function MotCMotifs(folder,Motif,ref,maxShift)
%Now we will motion correct the individual motifs. we are using the entire
%motif as a refernece so if we know that there is a lot of movement we
%should only take a part of it. 
%note: this takes about 1 minute per motif.
% parpool
if ~exist([folder,'3-MotifsMotC\'],'dir')
    mkdir([folder,'3-MotifsMotC\'])
end
numM=length(Motif);
if length(Motif)>2
    try %if we have the aparallel toolbox
        canpar=1;%note that we did parallel
        parfor m=1:numM
            if isempty(ref)
                r=1:Motif(m).numI;
            else
                r=ref;
            end
            is = imageSeries([folder,'2-Motifs\',Motif(m).name]);
            is.motionCorrect('savePath',[folder,'3-MotifsMotC\',Motif(m).name],'referenceFrame',r,'maxShift',maxShift);
        end
        delete(gcp)
    catch
        canpar=0;
    end
else
    canpar=0;
end
if ~canpar%if we are not doing parallel, do a forloop
    indReport=unique(floor((.1:.1:1)*numM));
    for m=1:numM
        if isempty(ref)
            r=1:Motif(m).numI;
        else
            r=ref;
        end
        is = imageSeries([folder,'2-Motifs\',Motif(m).name]);
        is.motionCorrect('savePath',[folder,'3-MotifsMotC\',Motif(m).name],'referenceFrame',r,'maxShift',maxShift);
        if sum(indReport==m)
            fprintf([num2str(m/numM,1),','])
        end
    end
end

disp('Finished motion correcting individual motifs');
