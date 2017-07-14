%The purpose of this code is to standardize how we name the files, so we
%can put them all in the same folder.
%the format will be mm_dd_ttt.ext. you can change it if you want, just
%change the downstream code too
clear;clc;close all;
doit=1;%set to 0 for testing
dataF='Data\383\ABF\';
dataM='Data\383\1-Orig\';

%% ABF
files=dir([dataF,'*.abf']);
ABFfiles={files(:).name};
for f=1:length(ABFfiles)
    currF=ABFfiles{f};
    currF=strtok(currF,'.');
    ttt=currF(end-2:end);%EDIT THESE LINES
    mm=currF(1:2);
    dd=currF(4:5);
    newFname=[mm,'_',dd,'_',ttt,'.abf'];
    if doit
        movefile([dataF,ABFfiles{f}],[dataF,newFname]);
    else
        disp([dataF,ABFfiles{f},'-->',dataF,newFname])
    end
    fprintf([num2str(f/length(ABFfiles)),','])
end
%% TIF
TIFfiles=dir([dataM,'*.tif']);
TIFfiles={TIFfiles(:).name};
for f=1:length(TIFfiles)
    currF=TIFfiles{f};
    currF=strtok(currF,'.');
    ttt=currF(end-2:end);%EDIT THESE LINES
    mm=currF(1:2);
    dd=currF(4:5);
    testTIF=[mm,'_',dd,'_',ttt,'.tif'];
    newFname=[mm,'_',dd,'_',ttt,'.tif'];
    if doit
        movefile([dataM,TIFfiles{f}],[dataM,newFname]);
    else
        disp([dataM,TIFfiles{f},'-->',dataM,newFname])
    end
    fprintf([num2str(f/length(TIFfiles)),','])
end
