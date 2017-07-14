function CellInfo=MakeFParams(folder)
CellInfo=struct('cellID',{},'rmMotif',{},'baseStart',{},'baseLen',{}); 
run([folder,'ROIs\ParamsforF'])%this will bring up all the parameters that are saved
for c=1:length(cells)
    CellInfo(c).cellID=cells(c);
    CellInfo(c).rmMotif=BadMotifs{c};
    CellInfo(c).baseStart=baseOn(c);
    CellInfo(c).baseLen=baseLen(c);
end
    
save([folder,'ROIs\CellInfo.mat'],'CellInfo');