clear; clc; close all;
addpath(genpath('Fcns\TiffFcns'));
folder='Data\';

fileName='Composite.tif';
maxShift=5;
refFrame=[];
is = imageSeries([folder,fileName]);
is.motionCorrect('savePath',[folder,'Mot',fileName],'referenceFrame',refFrame,'maxShift',maxShift);