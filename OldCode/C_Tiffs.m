%% load in your data
clear; clc; close all;
addpath(genpath('Fcns\TiffFcns'));
addpath Fcns\RoiFcns;
folder='Data\348\';
load([folder,'ABF_Final.mat'],'Motif')%load in Motif
%% Make your Motifs
% Cut up tiffs into Individual Motifs
par=1;
CutUpTiffs(folder,Motif,par);
% at this stage you will need to take a look at all your motifs. which ones
% need shifts?
%motion correct the individual motifs
%% Motion correction within motifs
% Motif=Motif([56,76,78:84,97,98,114,123,141,144,146:148,150,157,178,180,196,238]);
% Motif=Motif([1:8,10,12:19,21:30]);
% Motif=Motif([5:13,26:30]);
% M=Motif([72,74]);
%save([folder,'ABF_part3.mat'],'Motif')
maxShift=5;
ref=[];%leave empty if you want to use all
MotCMotifs(folder,Motif,ref,maxShift);
% save([folder,'ABF_final.mat'],'Motif')
%% Join Them Together.
%Until this point there is no reason to remove ankky of the motifs, since
%they are all on their own. but now we only want to play with motifs that
%were taken in the same way
%Select only the ones that you want, for example Motif=Motif(7:end);
%This makes a single tiff, each frame is the average of a single motif
%Motif=Motif([1:7]);
% Motif=Motif([114:136,177:182]);
Motif=resizeANDjoin(folder,Motif,480);%change the progress report on this one
% Motif=resizeANDjoinSmall(folder,Motif,180,300);%ONLY  FOR ALL PLANES, NOT
% FOR A SINGLE PLANE
save([folder,'ABF_Avgs.mat'],'Motif')
%% 5-ShiftedMotifMotCAVG
% then motion correct the average of each
% apply that motion correction to all of them
%at this stage open the avg one in  and find out 
%a)what your maxShift you can expect to be and 
%b)which are nice for a reference

%before we go on, manually confirm motion correction
%% make movie
% [tiffIDs,mTimes]=makeMovieTif(folder,[],'avg',Motif);
%even though it is more efficient to do them together, i split it because
%you will want to do it in different times
%this code isnt done yet
% %%
% cTimes=concatenateM(folder,Motif);
% save([folder,'ABF_Concat.mat'],'Motif');*/
%MOVE IT ALL INTO ROIs