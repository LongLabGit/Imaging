function ind=pc2ind(f,pD,cD,fs,cs)

ind=zeros(size(pD));
pD2=strcat(f,pD,{'\'});
for i=1:length(pD)
    foo=find(strcmp(fs,pD2{i})&cs==cD(i));
    if ~isempty(foo)
        ind(i)=foo;
    end
end
ind=sort(ind(ind>0));