folder='Data\105\Planes\';
Opt.Input='file';
flds=dir('A:\Michel\Michel2photon\ImagingAnalysis\Data\105\Planes');
for i=15:length(flds)
    f=flds{i};
    Hash{i} = DataHash([folder,f,'\ROIs\RoiSet.zip'], Opt);
end
