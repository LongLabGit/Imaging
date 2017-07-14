function y=norm01(y,normstyle)
if nargin<2||normstyle==1
    y=(y-min(y(:)))/range(y(:));
elseif normstyle==2
    for i=1:size(y,1)
        s=y(i,:);
        fo=mean(s(1:5));
        s=(s-fo)/fo;
        y(i,:)=s;
    end
end