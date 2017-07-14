function JoinABFs(folder)
allOptions=dir([folder,'ABF*.mat']);
allOptions={allOptions(:).name};
for i=1:length(allOptions)
    