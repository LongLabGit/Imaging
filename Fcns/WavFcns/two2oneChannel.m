function two2oneChannel(folder)

dataF=[folder, '1-Orig\'];
addpath(dataF)
files=dir([dataF,'*.tif']);
ALLfiles={files(:).name};

for f=1:length(ALLfiles)

file=ALLfiles{f}; %file that needs to be loaded

if f<10
    newT_name=[dataF file(1:11) file(14) '.tif']; %name of the new file
end
if f>9 && f<100
    newT_name=[dataF file(1:10) file(13:14) '.tif']; %name of the new file
end
if f>99
    fprintf('check your tif file-names')
end

info=imfinfo(file); %load meta data (following for loop will run faster!)

fprintf(['writing file ' file '\n'])

for i=1:2:length(info)
    imageData=imread(file,i,'Info',info);
    if i==1
                imwrite(uint16(imageData),newT_name,'TIF','compression','none')
            else
                imwrite(uint16(imageData),newT_name,'TIF','WriteMode','append','compression','none')
    end
end

end

end