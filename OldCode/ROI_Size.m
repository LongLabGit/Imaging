clear;clc;close all;
addpath Fcns\ROIFcns
F={'Data\102\CorrectedPlanes\','Data\105\Planes\','Data\131\All\','Data\193\','Data\192\Planes\'};
%% write the images
for indF=1:length(F)
    f=F{indF};
    disp([f,': '])
    load([f,'InitialC2.mat'])
    load([f,'allROIs.mat'])
    load([f,'topo.mat'],'dat')
    for c=1:length(InitialC)
        writeROIs(f,InitialC(c).cID,ROIs(InitialC(c).inds),dat)
    end
    fprintf('Done')
end
%% load the cell data
%These numbers were found by 
ts(1,:)=[-0.215    0.5659];
ts(2,:)=[-.162 .6436];
ts(3,:)=[0 .6478];
ts(4,:)=[-.2475 .247];
ts(5,:)=[0 .956];
allA=[];
allBN=[];
allSNR=[];
tau=[];
birdID=[];
rm=[];
for indF=1:length(F)
    f=F{indF};
    load([f,'burstInfo.mat'])
    area=[];
    r=[];
    nBurst=[];
    rmID=[];
    snr=[];
    rmList=xlsread('Data\ROIs\Comment on drawing ROIs.xlsx',f(6:8));
    for c=1:length(burstInfo)
        cID=burstInfo(c).cID;
        roi=ReadImageJROI(['Data\ROIs\' f(6:8) ,'\',num2str(cID) '.roi']);
        coord=roi.mnCoordinates;
        BW = poly2mask(coord(:,1), coord(:,2), 81,81);
        area(c)=sum(BW(:));
%         r(c,:)=range(coord);
        nBurst(c)=sum(burstInfo(c).t>ts(indF,1)&burstInfo(c).t<ts(indF,2));
    end
end
        rmID(c)=ismember(cID,rmList);
        s=burstInfo(c).SNR*400;
        s(s>10)=[];
        snr(c)=mean(s);
    end
    allA=[allA,area];
    allBN=[allBN,nBurst];
    allSNR=[allSNR,snr];
    tau=[tau,zscore([burstInfo.tau]')'];
    birdID=[birdID,repmat(indF,length(nBurst),1)'];
    rm=[rm,logical(rmID)];
end
%
allA=allA(~rm);
allBN=allBN(~rm);
allSNR=allSNR(~rm);
tau=tau(:,~rm);
birdID=birdID(~rm);
%%
figure(1);clf;
subplot(2,2,1)
d=sqrt(allA/pi)*2;
hg=histogram(allA,20);
xlabel('Area (um)')
ylabel('number of cells')
title('Distribution of Area')
%
subplot(2,2,2); hold on;
plot(allA,allBN,'o');
xlabel('Area (um2)')
ylabel('# of bursts during song')
set(gca,'ytick',1:3)

subplot(2,2,3); hold on;
plot(tau(1,:),allBN+.05,'o');
plot(tau(2,:),allBN-.05,'ro');
legend('onset','offset')
ylim([.5,2.5])
set(gca,'ytick',1:3)
xlabel('z score of tau')
ylabel('# of bursts during song')

subplot(2,2,4); hold on;
plot(allSNR,allBN,'o');
ylim([.5,2.5])
set(gca,'ytick',1:3)
xlabel('SNR')
ylabel('# of bursts during song')