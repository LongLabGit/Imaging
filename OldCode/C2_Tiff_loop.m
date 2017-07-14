%% load in your data
clear; close all;
addpath(genpath('TiffFcns'));
f='Data\105\Planes\';
planes=dir(f);planes={planes(3:end).name}';
for p=4:length(planes)
    folder=[f,planes{p},'\'];
    load([folder,'ABF_Final.mat'])%load in Motif
    MotifsKept=resizeANDjoin(folder,Motif,480);%change the progress report on this one
    maxShift=30;
    ref=[];
    MotC_AVGs(folder,Motif,maxShift,ref);
    %before we go on, manually confirm motion correction
    % make movie
    [tiffIDs,mTimes]=makeMovieTif(folder,[],'avg',Motif);
    %even though it is more efficient to do them together, i split it because
    %you will want to do it in different times
    %this code isnt done yet
    ccTimes=concatenateM(folder,Motif);
    save([folder,'ABF_Concat.mat'],'Motif');
end
