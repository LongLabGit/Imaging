%% Initialize parameters
clear; clc;
%There are two stages to this code: write the wav files so that Michel can
%then go in and label the syllables in eGUI and then writing down the tiff
%times. 
%plotgut check allows you to view it and change your parameters
addpath('WavFcns');
%here set your wav file
% folder='102\All2\'; 
folder='131sol\';
folder=['Data\',folder];
%% Extract the tiff locations and the motifs

params=MakeParams(folder);%/Notes should have MissingGaps.xlsx,BadLines.xlsx, E_GUI, and ParamsforEFA
ExtractFromAbf(folder,params,0,'w');
% JoinABFs(folder);
%% Plot everything
% motifs2plot=[1,4,6,7,8];
%
motifs2plot=[];%set it to empty if you want all of them
rainbow=0;%do you want to make every line a different color
plotFull=0;%put this in because it takes too long to plot them
WarpMotifs(folder,motifs2plot,rainbow,plotFull,1);%took out the removeMotifs thing