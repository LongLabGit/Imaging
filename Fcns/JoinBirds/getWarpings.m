function [o_C,r_C,Edges,planes]=getWarpings(F,Onsets,ROIs)
try
    rids=[Onsets.inds];
catch
    rids=vertcat(Onsets.inds);
end
planes=unique({ROIs(rids).f},'stable');
planes=planes';
planesOnly=strrep(planes,F,'');
[masterPlanes,indP]=unique(strtok(planesOnly,'\'),'stable');%THEN ITERATE ON THOSE
planes2check=planes(indP);

%Get all the warpings. Decide that the first one was correct. Warp
%accordingly
M=[];
o=nan(1,length(planes2check));
warp=nan(1,length(planes2check));
planes2check=planes(indP);
for p=1:length(planes2check)
    load([planes2check{p},'ABF_Avgs.mat'])
    r=[Motif.warpFactor];
    inds=1:length(r);
    rm=~cellfun(@isempty,{Motif.syllMiss});
    r(rm)=[];inds(rm)=[];
    [~,i]=min(abs(r-1));
    M=[M,Motif(inds(i))];
    if p==1
        o(p)=0;
        warp(p)=1;
    else
        alignPts=Motif(1).alignPts;
        curr_edge=M(p).EguiTimesWARP(alignPts);
        standard_edge=M(1).EguiTimesWARP(alignPts);
        o(p)=curr_edge(1)-standard_edge(1);
        warp(p)=range(standard_edge)/range(curr_edge);
    end
end
Edges=reshape(M(1).EguiTimesWARP,2,length(M(1).EguiTimesWARP)/2)';
o_C=[];
r_C=[];
for c=1:length(Onsets)
    rID=Onsets(c).inds(1);%subplanes have same warpings
    rPlane=ROIs(rID).f;
    indP=strcmp(strtok(strrep(rPlane,F,''),'\'),masterPlanes);
    o_C(c)=o(indP);
    r_C(c)=warp(indP);
end