%%
for c=1:length(Cell)
    x(c)=mean(Cell(c).patch(:,2));
    y(c)=mean(Cell(c).patch(:,1));
end
z=[Cell(:).z];
t=[Cell(:).tOnset];
rm=t<tSing(1)|t>tSing(2);
z(rm)=[];
x(rm)=[];
y(rm)=[];
t(rm)=[];
% [b,bint,r,rint,stats]=regress(t',[ones(150,1),x,y,z']);
[b,bint,r,rint,stats]=regress(t',[ones(length(x),1),a1(:,1)]);
scatter3(x,y,t,'filled')
hold on
xfit = min(x):1:max(x);
yfit = min(y):1:max(y);
% zfit = min(z):.2:max(z);
[xMesh,yMesh] = meshgrid(xfit,yfit);
tFit = b(1) + b(2)*xMesh + b(3)*yMesh;
mesh(xMesh,yMesh,tFit)
xlabel('x')
ylabel('y')
zlabel('t')
view(90,0)%y
view([0,-90,0])%x
%%
figure(2)
plot3(times,x,y,'.','MarkerSize',10)
xlabel('Time')
ylabel('X Location')
zlabel('Y Location')
view([0,90])
yl=ylim;
zl=zlim;
patch([tSing(1),tSing(1),tSing(2),tSing(2)],[yl(1),yl(2),yl(2),yl(1)],'c','FaceAlpha',.3)

figure(3)
plot3(times,x,y,'.','MarkerSize',10)
view([0,-90,0])
xlabel('Time')
ylabel('X Location')
zlabel('Y Location')
patch([tSing(1),tSing(1),tSing(2),tSing(2)],[yl(2),yl(1),yl(1),yl(2)],[zl(1),zl(2),zl(2),zl(1)],'c','FaceAlpha',.3)
