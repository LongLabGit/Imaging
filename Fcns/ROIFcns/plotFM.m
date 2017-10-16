function plotFM(Cell,cells,savefigure,Motif)
%'savefigure' (0/1) specifies whether figures are saved
%specify where figures are saved
imagepath = 'A:\Felix\Singers\Celloutput_imaging\';
%specify audio sampling rate
fs=40000;

set(0,'DefaultFigureWindowStyle','docked')
if isempty(cells)
    cells=1:length(Cell);
end

    %get AUDIO
    audiof=Motif(1).audioF;
    audiotimes=Motif(1).audioTimesWARP; 
    
    %OR: enter path manually
    %audiof='Data\383 PA\Plane A\motifWavs\05_23_013_1.wav';  
    
     [dat,fs]=audioread(audiof);     

for i=1:length(cells)%for each cell
    c=cells(i);
    figure;clf;
    f=Cell(c).f;
    Nm=size(Cell(c).t,1);
    col=jet(Nm);
    plane=f;
    for m=1:Nm%for each motif
        h(1)=subplot(3,1,1);
        vigiSpec(dat,fs,[],[],[],[],audiotimes)
        
        h(2)=subplot(3,1,2);hold on
        s1=Cell(c).bin(m,:);
        plot(Cell(c).t(m,:),s1,'color',col(m,:))
        h(3)=subplot(3,1,3);hold on
        s1=s1-nanmin(s1); %to normalized it
        Cell(c).s1(m,:)=s1/nanmean(s1);%idem
        plot(Cell(c).t(m,:),Cell(c).s1(m,:),'color',col(m,:))
    end
    subplot(312)
    title(['Plane ', strrep(plane,'\','\_'),', Cell #',num2str(Cell(c).cellN)])
    subplot(3,1,3)
    T=Cell(c).t(:);        
    F=Cell(c).s1(:);
    rm=isnan(F);
    cfun= fit(T(~rm),F(~rm),'smoothingspline','SmoothingParam',1-1e-4);
    T=sort(T(~rm));
    y = feval(cfun,T);
    plot(T,y,'k','linewidth',2)
    linkaxes(h,'x')
    %axis tight
    xlim(audiotimes)
%     pause;
if savefigure
    
    file_name=['Cell_',num2str(Cell(c).cellN)];
    
    %print(gcf,'-depsc2','-r300',sprintf('%s%s',imagepath,file_name))
     print(gcf,'-djpeg','-r300',sprintf('%s%s',imagepath,file_name))
    
end

end
disp([num2str(length(cells)),'/',num2str(length(Cell)),' cells with ',num2str(Nm),' motifs'])
