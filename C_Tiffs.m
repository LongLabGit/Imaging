% %% load in your data
clear; clc; close all;
addpath(genpath('Fcns\TiffFcns'));
addpath Fcns\RoiFcns;
folder='Data\383 Butons\';
%% Make One tiff per motif
% Cut up tiffs into Individual Motifs
load([folder,'ABF_Warped'], 'Motif')%Late
CutUpTiffs(folder,Motif);
%% Motion Correct within those tifs
maxShift=12;%in pixels, 5
ref=[];%leave empty if you want to use all
MotCMotifs(folder,Motif,ref,maxShift);%check them!!
%% Motion Correct across those tifs
resizeANDjoin(folder, Motif, 480);%change the progress report on this one
%% Take a break
%here you need to check 4-avgs, AVg.tif
%It will tell you two things: 1) if the cells are blurry, it means that
%MotCMotifs was bad 2) check the maximum distance (in pixels) that you
%think it will need
%% Motion correct across motifs
maxShift=10;ref=8;%choose brightest sharpest plane for ref, 20px max shift is standard
MotC_AVGs(folder,Motif,maxShift,ref);
save([folder,'ABF_Used.mat'],'Motif')%if you remove some motifs manually (like Motifs(1:5)=[]), then you need to save the updated one
%% Draw ROIs
%At this point, you need to draw rois on the motc avg'd files