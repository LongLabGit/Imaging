function plotF(Cell,cells,savefigure)
%'savefigure' (0/1) specifies whether figures are saved
%specify where figures are saved
imagepath = 'A:\Felix\Singers\Celloutput_imaging\';

set(0,'DefaultFigureWindowStyle','docked')
if isempty(cells)
    cells=1:length(Cell);
end
for i=1:length(cells)%for each cell
    c=cells(i);
    figure;clf;
    f=Cell(c).f;
    Nm=size(Cell(c).t,1);
    col=jet(Nm);
    plane=f;
    for m=1:Nm%for each motif
        h(1)=subplot(2,1,1);hold on
        s1=Cell(c).bin(m,:);
        plot(Cell(c).t(m,:),s1,'color',col(m,:))
        h(2)=subplot(2,1,2);hold on
        s1=s1-nanmin(s1); %to normalized it
        Cell(c).s1(m,:)=s1/nanmean(s1);%idem
        plot(Cell(c).t(m,:),Cell(c).s1(m,:),'color',col(m,:))
    end
    subplot(211)
    title(['Plane ', strrep(plane,'\','\_'),', Cell #',num2str(Cell(c).cellN)])
    subplot(2,1,2)
    T=Cell(c).t(:);        
    F=Cell(c).s1(:);
    rm=isnan(F);
    cfun= fit(T(~rm),F(~rm),'smoothingspline','SmoothingParam',1-1e-4);
    T=sort(T(~rm));
    y = feval(cfun,T);
    plot(T,y,'k','linewidth',2)
    linkaxes(h,'x')
    axis tight
%     pause;
if savefigure
    
    file_name=['Cell_',num2str(Cell(c).cellN)];
    
    %print(gcf,'-depsc2','-r300',sprintf('%s%s',imagepath,file_name))
     print(gcf,'-djpeg','-r300',sprintf('%s%s',imagepath,file_name))
    
end

end
disp([num2str(length(cells)),'/',num2str(length(Cell)),' cells with ',num2str(Nm),' motifs'])
