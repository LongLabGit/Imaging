%In this function you will start the entire process. The first step is to
%extract the audio from your abf files so that you can deliniate when a
%motif occurs
clear; clc;
addpath('Fcns\WavFcns');
folder='348\';%here set your wav file
folder=['Data\',folder];
%% Make Wav (folder + files)
files=dir([folder,'ABF\*.abf']);%findall the files in the work space
files={files.name};
audioStart=makeWavs(folder,files,5);
%at this stage, go into electro gui and label everything