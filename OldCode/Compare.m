clear;clc;close all;
F={'Data\102\CorrectedPlanes\','Data\105\Planes\','Data\131\All\','Data\193\','Data\192\Planes\'};
%%
origT=[];
newT=[];
origS=[];
newS=[];
for indF=1:4%5
    clear bO bN
    f=F{indF};%set your bird 
    load([f,'OnsetsUpdate.mat'],'Onsets');
    load([f,'FinalC_Complete.mat'],'FinalC');
    bi=rmfield(Onsets,{'inds','rmsub','cut','rmDn','Bidx'});
    ind=0;
    for i=1:length(bi)
        if size(bi(i).t,1)==size(FinalC(i).bursts,1)
            ind=ind+1;
            %t
            [bO(ind).t,inds]=sort(nanmean(FinalC(i).bursts,2));
            bN(ind).t=nanmean(bi(i).t,2);
            %std
            bO(ind).s=nanmean(FinalC(i).Sburst,2);
            bO(ind).s=bO(ind).s(inds);
            bN(ind).s=nanmean(bi(i).s,2);
            if sum(abs(bN(ind).t-bO(ind).t)>.1)
                disp(f)
                disp(i)
                sum(abs(bN(ind).t-bO(ind).t)>.1)
            end
        end
        if any(isnan(bN(ind).t))
            disp(f)
            disp(i)
        end 
    end
    origT=[origT;vertcat(bO.t)];
    newT=[newT;vertcat(bN.t)];
    origS=[origS;vertcat(bO.s)];
    newS=[newS;vertcat(bN.s)];
end
%%
subplot(1,2,1)
plot(origT,newT,'.')
xlabel('original time')
ylabel('new time')
line([-.5, 1],[-.5,1])
xlim([-.5,1])
ylim([-.5,1])
axis square
subplot(1,2,2)
plot(origS,newS,'.')
hold on
plot(origS,polyval(p,origS),'r')
line([0, .035],[0,.035])
axis square
xlim([0,.035])
ylim([0,.035])
xlabel('original std')
ylabel('new std')
