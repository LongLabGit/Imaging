addpath fcns\motcorr
folder='';
is = imageSeries([folder,imgF]);
newimgF=[folder,'motC_' imgF];
is.motionCorrect('savePath',newimgF,'referenceFrame',1:10,'maxShift',maxShift);
