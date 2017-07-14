function joinSpecNeuron(folder,inputFPS,motif,linewidth,linecolor,offset,crop,range,frameTimes)
Fs=4e4;
addpath(genpath('\\imaging\public\Vigi\Matlab\Others\Michel\TiffFcns\real2rgb\'));
%now turn it into a movie
fileIn=[folder,'7-Full\Movies\ImageJ\',num2str(inputFPS),'FPS_NoAudio.avi'];
obj = VideoReader(fileIn);
w=get(obj,'Width');
h=get(obj,'Height');
numFrames=get(obj,'NumberOfFrames');%get the number of frames. this doesnt work for the vision reader
clear obj;
vR=vision.VideoFileReader(fileIn);

fileOut=[folder,'7-Full\Movies\SpecNeuron\',num2str(inputFPS),'.avi'];
vW=vision.VideoFileWriter(fileOut);
vW.FrameRate=inputFPS;

% 
% frameTimes=min(xloc):1/inputFPS:max(xloc);
% frameTimes=diff(frameTimes)/2+frameTimes(1:end-1);%get the middle of each
sonogramH=round(h/2);
F=linspace(500,1e4,sonogramH);%frequency range
if ~isempty(crop)
    motif=motif(crop);
end
[~,~,T,P]= spectrogram(motif,384,256,F,Fs);
spec=fliplr(10*log10(abs(P))');
newT1=linspace(min(T),max(T),w);
spec2=interp1(T,spec,newT1);

% h=surf(T,F,spec);
% set(h,'LineStyle','none')
% axis tight;
% view(0,90);
cmap=jet(256);
cmap(1,:)=[0,0,0];%convert the 0 to black
Specrange=max(max(spec))-min(min(spec));
sonogram=real2rgb(spec2',cmap,[min(min(spec))+Specrange*offset(1),min(min(spec))+Specrange*offset(2)]);
newT=newT1-range(1)+crop(1)/Fs;%offset the song by the appropriate amount\
for i=1:length(frameTimes)
    [~,l1]=min(abs(newT-frameTimes(i)));
    if (l1+linewidth-1)<w
        lineLoc(i,:)=l1:(l1+linewidth-1);
    else
        lineLoc(i,:)=(l1-linewidth+1):l1;
    end
end
lineColor=repmat(linecolor,sonogramH,1,linewidth);%make thicker
lineColor = permute(lineColor,[1,3,2]);
for i=1:numFrames
    neuron=step(vR);
    sT=sonogram;%recreate the sonogram
    sT(:,lineLoc(i,:),:)=lineColor;
    a=cat(1,sT,neuron);
    step(vW,a);
end
release(vR)
release(vW);