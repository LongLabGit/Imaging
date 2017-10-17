clear; clc;
addpath('Fcns\WavFcns');
folder='A:\Felix\ImagingAnalysisFelix\Data\389\20171012_xp109ym183zm31\';
threshold=.9;%for template matching
%% Make Wav (folder + files)
makeWavs(folder,5,threshold); %...,5,... add 5 seconds from curtain down on
%% make template
addpath(genpath('A:\Felix\MotifFinder'))
run('MotifEditor.m')
%% Convert raw data into manageable motif times
Motif=alignTifs(folder);
