function FindROIs(folder)
addpath \\IMAGING\Public\software\fiji-win64\Fiji.app\scripts
file = [folder,'6-Full\Concatenated.tif'];
Y = tiff_reader_new(file,0,0);
% Y=Y(1:350,100:350,:);%can cut it down, but youll need to remember to
%% normalize and reshape data
[d1,d2,T] = size(Y);  
d = d1*d2;
nn = min(Y(:));
mm = max(Y(:)); 
Y = (Y-nn)/(mm-nn);     % normalize data to 0-1
Yr = reshape(Y,d,T);
%% fast initialization of spatial components
nr = 40;                % number of components to be found
params.gSiz = 16;       % maximum size of neuron in pixels
params.gSig = 4;        
[basis, ~, center, ~] = greedyROI2d(reshape(Yr,d1,d2,T), nr, params);
Ain = sparse(reshape(basis,d,nr));    
% sY = reshape(std(Yr,[],2),d1,d2);
% Cn = correlation_neighborhood(Yr,d1,d2);
% axis equal; axis tight; hold all;
% scatter(center(:,2),center(:,1),'ko');
% title('Center of ROIs found from initialization algorithm');

ff = find(sum(Ain,2));
mY = mean(Yr,2);
mY(ff) = 0;
ff2 = setdiff(1:d,ff);
Cm2 = mean(Yr(ff2,:));   % time varying neuropil component
% estimate time constants and noise level
P = arpfit(Yr(ff,:),2);       % estimate time constant, noise levels.
P = arpfit(Yr,2,P.g);
%% run matrix factorization
Coor.x = kron(ones(d2,1),(1:d1)');
Coor.y = kron((1:d2)',ones(d1,1));
Coor.dist = 2.5;      % limit each ROI to an ellipse x times the variance
P.d1 = d1;
P.d2 = d2;
P.neuropil = Cm2;
[A,C,b,f] = NMF_foopsi_patch_local_motifs(Yr,nr,P,Coor,Ain);
%% visualize spatial components
nr = size(A,2);
figure(1);
back=full(reshape(b,d1,d2));
axis equal; axis tight;
L=zeros(d1,d2);
for i = 1:nr
    x=full(reshape(A(:,i),d1,d2));
    x1=reshape(x,1,d1,d2);
    W = squeeze(smooth3(x1));
    [B,L1]=bwboundaries(W,'noholes');
    L=L+L1;
    bounds{i}=B{1};
    [r,c]=find(x);
    linearInd = sub2ind([d1,d2],r, c);
    back(linearInd)=10;
end
figure(1)
L=logical(L);
imshow(label2rgb(L, @jet, [.5 .5 .5]));hold on;
for i=1:nr
    hold on;plot(bounds{i}(:,2), bounds{i}(:,1), 'r', 'LineWidth', 2)
end
% imagesc(back)
axis equal; axis tight;
%%
% javaaddpath 'C:\Program Files\MATLAB\R2013b\java\jar\mij.jar'
% javaaddpath 'C:\Program Files\MATLAB\R2013b\java\jar\ij.jar'
Miji();
str=strrep(file,'\','\\');
path=['path=[A:\\Michel\\Michel2photon\\ImagingAnalysis\\',str,']'];
MIJ.run('Open...', path);
%put into for loop
for i=1:length(bounds)
    a=[bounds{i}(:,2),bounds{i}(:,1)]';
%     if hasarea
        MIJ.setRoi(a,2)%each one is a vertex- 
        %comet(a(1,:),a(2,:))%test it out in a figure
        MIJ.run('Add to Manager');
%     end
end
IJ=ij.IJ();
if ~isdir(['\\IMAGING\Public\Michel\Michel2photon\ImagingAnalysis\',folder,'ROIs\'])
    mkdir(['\\IMAGING\Public\Michel\Michel2photon\ImagingAnalysis\',folder,'ROIs\'])
end
macroStr=['roiManager(''save'', ''\\\\IMAGING\\Public\\Michel\\Michel2photon\\ImagingAnalysis\\',strrep(folder,'\','\\'),'ROIs\\ROIsAlg.zip'');'];
ij.IJ().runMacro(java.lang.String(macroStr));
MIJ.run('Close All')
MIJ.exit