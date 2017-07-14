%% For a specific plane, take a look at the cells you demarcated
clear; clc; close all;
addpath Fcns\ROIFcns
%% Take a look at a single plane the first time
f='\Data\182\10-13\';
load([f,'ROIs\ABF_Concat'],'Motif')%load in Motif %% *
% Extract Info
Cell=ExtractF2(f,Motif,1);%CHANGE THIS TO UPDATED CODE
%%
load([f,'CellF.mat'],'Cell');%if step1 and  2 are already done
plotF(Cell,[],0); %if you want to plot every cell and not only the selected ones use this:[]
%% For all planes, take a look at selected ROIs
close all;clc;clear;
addpath('Fcns\ROIFcns')
set(0,'DefaultFigureWindowStyle','docked')
folder='Data\316\';

[~,~,xlsx]=xlsread([folder,'SelectedCells.xlsx']);
cellN=cell2mat(xlsx(2:end,2));
planesList=cellfun(@num2str,xlsx(2:end,1),'UniformOutput',0);
[planes,ia,ic]=unique(planesList,'stable');
for p=1:length(planes)
    pln=planes{p};
    cells=unique(cellN(ic==p));
%     load([folder,pln,'\ROIs\ABF_Concat.mat'],'Motif')
    load([folder,pln,'\ROIs\CellF.mat'],'Cell');
    plotF(Cell,cells,0) %% here choose 1 or 0 to print the traces or not
end
disp('Done')