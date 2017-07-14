%This should evolve into the code that is done after we annotate all files,
%doing motion correction again and then splitting everything
clear; clc; close all;
addpath(genpath('TiffFcns'));
folder='Data\122\ALL\';
load([folder,'ABF_Final.mat'],'Motif')%load in Motif
MotifOrig=Motif;
[~,~,notes]=xlsread([folder,'122 planeID\PlaneID2.xlsx']);
notes(:,1)=strrep(notes(:,1),'''','');
%% move stuff around
p=notes(:,3);%original planes
a=cellfun(@isnan,p,'UniformOutput',false);
b=~cellfun(@(v) v(1),a);%remove nans
p=p(b);
a=cellfun(@isnumeric,p);
p(a)=cellfun(@num2str,p(a),'UniformOutput',false);
p=strtrim(p);
planes=unique(p);
planes=setdiff(planes,{'bad','Plane ID'});
p2=notes(:,3);
p2(~b)={' '};
p2(b)=p;
OrigFs={Motif.name};
%%
for i=15:length(planes)
    if ~isdir(['Data\122\Planes\',planes{i}])
        mkdir(['Data\122\Planes\',planes{i}])
        mkdir(['Data\122\Planes\',planes{i},'\3-MotifsMotC\'])
    end
    inds=ismember(p2,planes{i});
    Fs=notes(inds,1);
    for f=1:length(Fs)
        copyfile([folder,'3-MotifsMotC\',Fs{f}],['Data\122\Planes\',planes{i},'\3-MotifsMotC\',Fs{f}])
    end
	%now store ABFFinal
    inds=ismember(OrigFs,Fs);
    Motif=MotifOrig(inds);
    save(['Data\122\Planes\',planes{i},'\ABF_Final.mat'],'Motif')%load in Motif
end
%% redo stuff
% remot=strcmp(notes(:,5),'Re-do');
% remotFs=notes(remot,1);
% MotifFs={Motif.name};
% remotInd=ismember(MotifFs,remotFs);
% maxShift=50;
% ref=[];%leave empty if you want to use all
% Motif2=Motif(remotInd);
% MotCMotifs(folder,Motif2,[],maxShift);