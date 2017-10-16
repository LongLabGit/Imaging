function [wav,fs,imgT]=alignAudioImgs(abfF,imgF)
%this will output the audio captured only during imaging, the samplign
%rate, and the corresponding image times
[d,si,~]=abfload(abfF); %loads the file
%d1=frame, d2=audio, d3=glass opened
fs=round(1/(si*1e-6));%get the sampling rate
wav=d(:,2)/max(abs(d(:,2)));%get the audio, normalize to 1

%use this info to find tiff numbers
imgT=getTiffInds(d(:,1),imgF);
imgT=imgT/fs;
wavT=(1:length(wav))/fs;
wav=wav(wavT>imgT(1)&wavT<imgT(end));%cut audio
imgT=imgT-imgT(1);%set 0 mark