%%Step1 load the file and the ABFoutput
% clear; clc; close all;
% set(0,'DefaultFigureWindowStyle','docked');
folder='102\CorrectedPlanes\11\';%load the file
folder=['Data\',folder];
load([folder,'ABF_Output.mat'])%load in Motif
close all;
%%%Step2 plot on the same figure
set(0,'DefaultFigureWindowStyle','docked');
for i=([35 48 45 35 34 21 20 18 17 15 7 4 3 2 1])
 figure(i)
 plot(Motif(1).frameTimesWARP,data1(:,i)); hold on %data is the calcium traces
 plot(Motif(2).frameTimesWARP,data2(:,i),'r'); 
 plot(Motif(3).frameTimesWARP,data3(:,i),'k')
%  ylim([-1 2]);
end
