clear;clc;close all;
F={'Data\102\CorrectedPlanes\',...
    'Data\105\Planes\',...
    'Data\131\All\',...
    'Data\193\',...
    'Data\192\Planes\',...
    'Data\105Ex\'};
bird={'102','105','131','193','192'};
% ts(1,:)=[-0.215    0.5659];%cahange this to gte times
% ts(2,:)=[-.162 .6436];
% ts(3,:)=[0 .6478];
% ts(4,:)=[-.2475 .247];
% ts(5,:)=[0 .956];
%%
clc;
n=[2,2,2,2,4];%this was how we checked for a problematic SNR
for indF=5
    f=F{indF};%set your bird 
    load([f,'OnsetsUpdate.mat'],'Onsets');
    if indF<5
        load([f,'FinalC_Complete.mat'],'FinalC');
    else
        load([f,'InitialC.mat'],'InitialC');
    end
    burstInfo=rmfield(Onsets,{'rmsub','cut','rmDn','Bidx'});
    rmSNR=xlsread('Data\CheckSNR.xlsx',bird{indF});
    rmSNRid=rmSNR(logical(rmSNR(:,3)),1);
    for i=1:length(burstInfo)
        t=nanmean(burstInfo(i).t,2);
        s=nanmean(burstInfo(i).s,2);
        tau=nanmean(burstInfo(i).tau,2);
        SNR=nanmean(burstInfo(i).SNR,2)*400;
        
        %find out if we might want to remove SNR
        to = (tau(1)*tau(2))/(tau(2)-tau(1))*log(tau(2)/tau(1)); %time of maximum
        
        
        if indF<5
            time=FinalC(i).time;
        else
            time=InitialC(i).time;
        end
    	lastT=time(:,end);lastT(lastT<0)=[];lastT=median(lastT);
        burstInfo(i).nTrials=repmat(size(time,1),length(t),1);
        
        burstInfo(i).t=t;
        burstInfo(i).s=s;
        burstInfo(i).tau=tau;
        burstInfo(i).SNR=SNR;
        if ismember(burstInfo(i).cID,rmSNRid)
            burstInfo(i).SNR(end)=NaN;
        end
        if sum(burstInfo(i).nTrials>100 & burstInfo(i).s>.025)
            disp(f)
            disp(burstInfo(i).cID)
        end
    end

    %192 needed to remove some in post because they were curropted by
    %axon/dendrites
    if indF==5
        cID=[burstInfo.cID];
        rm=ismember(cID,[164,137,16,13,244,14]);
        burstInfo(rm)=[];
    end    
%     save([f,'burstInfo.mat'],'burstInfo');
end
%% Prep for Columbia
clear;clc;close all;
F={'Data\102\CorrectedPlanes\',...
    'Data\105\Planes\',...
    'Data\131\All\',...
    'Data\193\',...
    'Data\192\Planes\'};
bird={'102','105','131','193','192'};
for b=1:length(bird)
    f=F{b};
    load([f,'burstInfo.mat'],'burstInfo');
    info=rmfield(burstInfo,{'inds','xyz'});
    load(['Gabo\Data\' bird{b} ,'GTEs.mat'],'gtes','newG');
    Bird(b).bird=bird{b};
    Bird(b).Info=info;
    gtes=sort(unique([gtes,reshape(newG,[1,length(newG)])]));
    t=vertcat(info(:).t);%DONT DO -.02
    Bird(b).gtes=gtes;
    nB(b)=sum(t>gtes(1)&t<gtes(end));
end
save('ImagingFinal.mat','Bird')