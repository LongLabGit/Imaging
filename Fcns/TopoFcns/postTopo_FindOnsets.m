clear;
f='Data\102\CorrectedPlanes\';
load([f,'FinalC_AutoUpdate2.mat'])
load([f,'allRoisJoint4.mat'])

redobIDs=[148,154,354];%based on looking it up if it isnt the first one

rdInd=ismember([FinalC_Update.bID],redobIDs);
FinalC_Redo3=FinalC_Update(rdInd);
bIDList=[brainC.bID];%brainIDs
bIDFCU=[FinalC_Update.bID];%old ones
%%
for i=1:length(FinalC_Redo3)
    FinalC_Redo3(i).bursts=nanmean(FinalC_Redo3(i).bursts,2);
    FinalC_Redo3(i).Sburst=nanmean(FinalC_Redo3(i).Sburst,2);
    bID=FinalC_Redo3(i).bID;
    inds=find(bID==bIDList);
    indFC=find(ismember(bIDFCU,inds));%find every time we did it before. 
    old=[];
    rmsuball=[];
    for n=1:length(indFC)
        rmsub=FinalC_Update(indFC(n)).rmsub;
        for r=1:size(rmsub,1)
            rmsub{r,1}=rmsub{r,1}+length(old);
        end
        rmsuball=[rmsuball,rmsub];
        temp=FinalC_Update(indFC(n)).inds;
        old=[old,temp];
        
    end
    FinalC_Redo3(i).inds=old;
    FinalC_Redo3(i).rmsub=rmsuball;
end
%%
%NOTE: THE TIME AND TRACES WILL BE WRONG
save([f,'FinalC_Redo4.mat'],'FinalC_Redo3')

%%
i=1;
indFC=find(ismember(bIDFCU,inds));
