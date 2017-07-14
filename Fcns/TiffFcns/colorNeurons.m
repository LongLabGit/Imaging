function colorNeurons(folder,planes,zlocs,specParams,opts)

%create your cell structure
Cell=struct;
for p=1:length(planes)
    Cell=getCells(folder,planes{p},zlocs(p),Cell);
end

%%
aviName=[folder,'ZStack_',[planes{:}],'_sono.avi'];
camorbit(60,-60);
times=[Cell(:).tOnset];
cuts=min(times):1/60:(max(times)+1/60);
%when is the bird singing
a=vertcat(Motif(:).TimeSingingWARP);%load a motif. doesnt really matter which one
tSing=mean(a,1);

numIms=1:(length(cuts)-1);
imSinging=find((cuts>=tSing(1))&cuts<=tSing(2));
col=jet(length(imSinging));
%%
[~,b]=min(abs([Motif(:).warpFactor]-1));
audio=Motif(b).audio;
t=Motif(b).audioTimesWARP;
timeS=Motif(b).TimeSingingWARP;
goodInds=(t>=(timeS(1)-.01))&(t<(timeS(2)+.01));
audio2=audio(goodInds);
t2=t(goodInds);
plot(t2,audio2)
fs=diff(t2);
fs=1/fs(1);
%%
F=linspace(500,1e4,200);%frequency range
[~,~,T,P]= spectrogram(audio2,384,256,F,fs);
spec=fliplr(10*log10(abs(P))');
newT1=linspace(min(T),max(T),560);
spec2=interp1(T,spec,newT1);
newT1=newT1+t2(1);
cmap=jet(256);
cmap(1,:)=[0,0,0];%convert the 0 to black
Specrange=max(max(spec))-min(min(spec));
sono=real2rgb(spec2',cmap,[min(min(spec))+Specrange*specParams.offset(1),min(min(spec))+Specrange*specParams.offset(2)]);
% imagesc(sonogram)
%%
% vW=vision.VideoFileWriter(aviName);
% vW.FrameRate=60;
h=figure(1);clf;
axis([0 512 0 512 -40 40])
xlabel('x')
ylabel('y')
zlabel('z')
for im=numIms
    %make the spectrogram, put the line in the appropriate location
    %find all the new patches that we need to place
    %then step through each frame, find out which cells have fired since the
    %last frame (in which plane too) and put in a patch
    inIt=find((times>=cuts(im))&(times<cuts(im+1)));
    for c=1:length(inIt)
        i=inIt(c);
        y=Cell(i).patch(:,1);
        x=Cell(i).patch(:,2);
        z=Cell(i).z*ones(size(Cell(i).patch(:,2)));
        if sum(im==imSinging)
            patch(x,y,z,col(im+1-imSinging(1),:),'EdgeColor','none')
        else
            patch(x,y,z,[.5,.5,.5],'EdgeColor','none')
        end
    end
    camorbit(0.2,-0.2);
    title(num2str(cuts(im),3))
    a=getframe(h);
    image=a.cdata;
        %add the cursor to the sonogram
    if im==1
        [sT,sono1]=remakeSono(sono,newT1,(cuts(im)+cuts(im+1))/2,im+1-imSinging(1),col);
    else
        [sT,sono1]=remakeSono(sono1,newT1,(cuts(im)+cuts(im+1))/2,im+1-imSinging(1),col);
    end
%     a=cat(1,image,sT);
%     step(vW,a);
end
% release(vW);