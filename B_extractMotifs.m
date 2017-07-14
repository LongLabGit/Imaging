clear; clc;
addpath('Fcns\WavFcns');
set(0,'DefaultFigureWindowStyle','docked')
folder='Data\383 Butons\';
if ~isdir([folder,'Notes'])
    mkdir(folder,'Notes')
end
%% Make Wav (folder + files)
files=dir([folder,'ABF\*.abf']);%findall the files in the work space
files={files.name};
makeWavs(folder,files,5);
%% at this stage, go into electro gui and label everything
%% Convert raw data into manageable motif times
[Motif,params]=Abf2Motif(folder,'s'); % Will automatically save
Motif=WarpMotifs(folder,Motif,params,100,100); % Align and warp time points