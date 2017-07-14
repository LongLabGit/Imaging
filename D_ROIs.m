clear;clc;close all;
addpath('Fcns\TiffFcns\');
addpath('Fcns\ROIFcns\');
set(0,'DefaultFigureWindowStyle','docked')
folder='Data\348\';
%% Run Extraction
% Extract all planes (SUBPLANES TOO), piecewise
load([folder,'ABF_Used.mat'],'Motif')%if you remove some motifs manually (like Motifs(1:5)=[]), then you need to save the updated one
Cell=ExtractF_notconcat(folder,Motif);%extract the signal from the concat%% *step2
cells=[];%cells to plot. leave empty to plot all
plotF(Cell,cells,0); %print 1, don't print 0
%% Make selected cells
% here you jump out of matlab again, making an excel spreadsheet withh the
% active rois (cells you want to analyze further) manually
%% Once that is done, make ROIs. Be sure to use active to throw out bad ones
f='Data\383 PB\';
[plane,cellN,uniquePlanes,subplanes]=getSelectedROIs(f);%get selected cells
ROIs=makeROIs(f,plane,cellN);% make ROIs. this a list of active cells
ROIs=joinSP_nonTOPO(f,ROIs,subplanes);%this is a backup if motion
save([f,'allROIs.mat'],'ROIs')
%Now you're ready!!