clear; clc;
addpath('A:\Felix\Imaging\Fcns\WavFcns');
set(0,'DefaultFigureWindowStyle','docked')
folder='Data\402\';
threshold=.9;%for template matching
%% Make Wav (folder + files)
makeWavs(folder,5,threshold); %...,5,... add 5 seconds from curtain down on
%% make template
addpath(genpath('A:\Felix\MotifFinder'))
run('MotifEditor.m')

%% Convert raw data into manageable motif times
[Motif,params]=Abf2Motif(folder,'s'); % Will automatically save
