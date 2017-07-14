figs=dir('Data\102\CorrectedPlanes\AutoFigures');
figs=figs(~[figs.isdir]);
%%
indTS=regexp({figs.name},'tSpike');
ts=~cellfun(@isempty,indTS);
figs=figs(ts);
indTS=[indTS{ts}];
fn={figs.name};
t=[figs.datenum];
bID=str2double(strtok(fn,'_'));
a={FinalC_Update.creationT};
tFig=[figs.datenum];
for i=1:length(a)
    if ~isempty(a{i})
        dT(i)=tFig(bID==FinalC_Update(i).bID)-datenum(a{i});
    end
end
stem(dT)
c=find(dT>.02)