function [results,params] = performPcaIca(obj,varargin)


p = inputParser;
p.addParamValue('nPCs',150);
p.addParamValue('mu',0.5);
p.addParamValue('nICs',150);
p.addParamValue('maxRounds',1000);
p.addParamValue('smwidth',3);
p.addParamValue('thresh',3);
p.addParamValue('arealims',20);
p.addParamValue('PCuse',[],@(x)length(x)==numel(x) && all(x>0) && all(round(x)==x) );
p.addParamValue('downsampleX',1);
p.addParamValue('downsampleTime',1);
p.addParamValue('dataClass','double');
p.addParamValue('rng',11111);
parse(p,varargin{:});



    
startTime = now;

    
% put data into convenient names
ims = squeeze(obj.images);

% set data class
eval(sprintf('ims = %s(ims);',p.Results.dataClass))

% downsample if desired


% downsample in time
if p.Results.downsampleTime > 1
    % note number of images (used later)
    nImages = size(ims,3);
    
    D = p.Results.downsampleTime;
    imsDS = ims(:,:,1:end-mod(size(ims,3),D));
    X = size(imsDS,2);
    Y = size(imsDS,1);
    T = size(imsDS,3);
    imsDS = squeeze(sum(reshape(imsDS,Y,X,D,T/D),3));
    
    ims = imsDS;
    clear imsDS
end


% downsample in X
if p.Results.downsampleX > 1;
    % note number of X pixels (used later)
    nX = size(ims,2);
    
    D = p.Results.downsampleX;
    imsDS = permute(ims,[1 3 2]);
    imsDS = imsDS(:,:,1:end-mod(size(imsDS,3),D));
    X = size(imsDS,2);
    Y = size(imsDS,1);
    T = size(imsDS,3);
    imsDS = sum(reshape(imsDS,Y,X,D,T/D),3);
    imsDS = permute(squeeze(imsDS),[1 3 2]);
    
    ims = imsDS;
    clear imsDS
end

% compute dF/F
%ims = ims./repmat(mean(ims,3),[1 1 size(ims,3)]);


% set random number generator
rng(p.Results.rng)


% PCA
switch 1
    case 1
        [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(...
            ims,...
            [],... flims
            p.Results.nPCs,...
            [],...dsamp
            []);% badframes
    case 2
        [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA_orig(...
            imagePath,...
            [],... flims
            p.Results.nPCs,...
            [],...dsamp
            dataPath,...outputdir
            []);% badframes
        
end



% select PCs to use
if isempty(p.Results.PCuse)
    figure
    [PCuse] = CellsortChoosePCs(ims, mixedfilters);
else
    PCuse = p.Results.PCuse;
end

% note how many PCs there are
nPCs = length(PCuse);

% plot used PCs
%figure;
%CellsortPlotPCspectrum(imagesPath, CovEvals, PCuse)

% ensure nICs is not greater than nPCs
if p.Results.nICs > nPCs
    fprintf('Only %d PCs are available, will compute %d ICs (%d ICs requested).\n',nPCs,nPCs,p.Results.nICs)
    nICs = nPCs;
else
    nICs = p.Results.nICs;
end

% ICA
[ica_sig, ica_filters, ica_A, numiter] = ...
    CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, ...
    p.Results.mu,nICs,...
    [],... ica_A_guess
    [],... termtol
    p.Results.maxRounds);% maxrounds


% segment

[ica_segments, ~, segcentroid] = CellsortSegmentation(ica_filters,...
    p.Results.smwidth,...
    p.Results.thresh,...
    p.Results.arealims,...
    1);


% apply to data

cell_sig = CellsortApplyFilter(ims,...
    ica_segments,...
    [],...  flims
    [],...  movm % computed within the function
    1); % subtractmean




% set outputs
results.pcaTime = mixedsig;
results.pcaSpace = permute(mixedfilters,[1 2 4 3]);
results.CovEvals = CovEvals;
results.covtrace = covtrace;
results.movm = movm;
results.movtm = movtm;

results.icaTime = ica_sig;
results.icaSpace = permute(ica_filters,[2 3 4 1]);
results.ica_A = ica_A;
results.numiter = numiter;

results.segTime = cell_sig;
results.segSpace = permute(ica_segments,[2 3 4 1]);
results.segCentroid = segcentroid;

params = p.Results;
params.pcUse = PCuse;



% correct for downsampling

% temporal downsampling
if p.Results.downsampleTime > 1
    ds = p.Results.downsampleTime;
    % identify how many frames should be made by replication and how many extra
    nRep = floor(nImages/ds);
    nExtra = mod(nImages,ds);
    assert(nImages == nRep*ds+nExtra)
    
    results.pcaTime = imresize(results.pcaTime,[size(results.pcaTime,1) nRep*ds],'nearest');
    results.pcaTime = [results.pcaTime repmat(results.pcaTime(:,end),[1 nExtra])];
    
    results.icaTime = imresize(results.icaTime,[size(results.icaTime,1) nRep*ds],'nearest');
    results.icaTime = [results.icaTime repmat(results.icaTime(:,end),[1 nExtra])];
    
    results.segTime = imresize(results.segTime,[size(results.segTime,1) nRep*ds],'nearest');
    results.segTime = [results.segTime repmat(results.segTime(:,end),[1 nExtra])];
end


if isfield(params,'downsampleX') && params.downsampleX > 1
    ds = params.downsampleX;
    % identify how many frames should be made by replication and how many extra
    nRep = floor(nX/ds);
    nExtra = mod(nX,ds);
    assert(nX == nRep*ds+nExtra)
    
    results.pcaSpace = matrixScaleUp(results.pcaSpace,[1 ds 1 1]);
    results.pcaSpace = [results.pcaSpace repmat(results.pcaSpace(:,end,:,:),[1 nExtra])];
    
    results.icaSpace = matrixScaleUp(results.icaSpace,[1 ds 1 1]);
    results.icaSpace = [results.icaSpace repmat(results.icaSpace(:,end,:,:),[1 nExtra])];
    
    results.segSpace = matrixScaleUp(results.segSpace,[1 ds 1 1]);
    results.segSpace = [results.segSpace repmat(results.segSpace(:,end,:,:),[1 nExtra])];
    
end

% remove baseline

% scale to dF/F (based on first chunk of frames)



fprintf('\n***** Finished in %0.2f min *****\n',(now-startTime)*24*60)


% plot results
%resultsPcaIca.segTime = reshape(repmat(permute(resultsPcaIca.segTime,[1 3 2]),[1 2 1]),[size(resultsPcaIca.segTime,1) size(resultsPcaIca.segTime,2)*2]);
