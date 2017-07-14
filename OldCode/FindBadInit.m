clear; clc; close all;
addpath Fcns\OnsetFcns
F={'Data\102\CorrectedPlanes\','Data\105\Planes\','Data\131\All\','Data\193\','Data\192\Planes\'};
f=F{1};
load([f,'InitialC2.mat'],'InitialC');
%% Run the Sampler to find your Posterior.
for c=1:length(InitialC)
    cID=InitialC(c).cID; %select the cell you want to analyze. this is its brainID
    y=mean(InitialC(c).bursts,2)';
    if any(isnan(y)) 
        load([f,'OnsetData\', num2str(cID)],'Dat')
        disp(vertcat(Dat.BinGuess))
    end
end