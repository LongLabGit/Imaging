% This will start the final stages of our analysis 
% We want to get onsets for each cell. Unfortunately, we have ROIs, not
% cells. So we need to make a list of ROIs and determine which ones belong
% together.
clear; clc; close all;
addpath Fcns\ROIFcns   
addpath Fcns\TopoFcns
f='Data\316\';
needTopo=0;
%% get offsets between each plane in X and Y
%Michel needs to make SameCells.xlsx and put it in the folder. One column
%per plane, one row per cell
%If there is more than one zoom, you need to make an excel spreadsheet
%called PlaneID. 
if needTopo
    %In here we need to remove cells that are at a different zoom
    [N,planes,cells,MPP]=initializeTopo(f);% intialize the planes that we can analyze (i.e. in samecells )
    %turn same cells into distances. first number=1 at a time, 
    %second number=index to check. if first number is 0, will tell you all
    [X,Y,sX,sY]=makeDistMat(f,N,planes,cells,MPP,0,0);
    dat=dist2loc(f,planes,X,Y,MPP,0);%set to 1 if you want to include xy from Z planes
    Zplanes=makeZStack(f,planes,cells,dat,1,1);%first is where to start, second is to include all in dat
    %Now Check Zstack
%     dat=updateDat(f,dat);%this is if you have to fix things manually
else 
    dat=[];
end    
%% make ROIs, note which ones are the same
[plane,cellN,planeIDs,subplanes]=getSelectedROIs(f);%get Michel's notes
ROIs=makeROIs(f,planeIDs,plane,dat,cellN,0);% make ROIs
% Coregister(f,subplanes);%coregister all the subplanes. only need to do once
 %at this point you need across planes. you can make two, one for joining
%brainC and another 
if needTopo
    ROIs=joinSP(f,ROIs,subplanes);
    ROIs=joinAP(f,ROIs);%join across planes
    % unlike coregister sp this will not by definition assign things. it will
    % suggest and then you have to tell it yes or no
    [prob,UniB]=CoregisterAP(f,ROIs,[10,10,100]);
end
%%
save([f,'allROIs.mat'],'ROIs')