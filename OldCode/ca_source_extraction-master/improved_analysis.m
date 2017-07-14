clear; clc;

%% first run

%% set paths, constants ; load Motif struct
addpath(genpath('utilities'));
base_path = '..\Data\222 BOS\';
motif_name = 'ABF_Final';
concat_path = [base_path '6-Full\'];
single_path = [base_path '5-FinalMotifs\'];
% single_name_base = '03_01_';

% n_trials = 22;

load([base_path motif_name]);
Motif = Motif(1:20); % just the first 20 motifs here

debug = 0; % 0 - no output; 1 - plot components with activity; 2 - same as 1, but with 'waitforkeypress' each time around

%% load file that will be used to initialize ROI for all analysis on this plane

base_file = 'Concatenated.tif';

nam = [concat_path base_file];        % insert path to tiff stack here
sframe=1;						% user input: first frame to read (optional, default 1)
num2read=[];					% user input: how many frames to read   (optional, default until the end)

Y = bigread2(nam,sframe,num2read);
Y = Y - min(Y(:)); 
if ~isa(Y,'double');    Y = double(Y);  end         % convert to double

[d1,d2,T] = size(Y);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels

%% Set parameters for ROI detection/CNMF analysis

K = 25;                                           % number of components to be found
tau = 8;                                          % std of gaussian kernel (size of neuron in pixels) 
p = 2;                                            % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
merge_thr = 0.8;                                  % merging threshold

options = CNMFSetParms(...                      
    'd1',d1,'d2',d2,...                         % dimensions of datasets
    'search_method','ellipse','dist',3,...      % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                    % merging threshold
    'gSig',tau...
    );

%% Data pre-processing

[P,Y] = preprocess_data(Y,p);

%% fast initialization of spatial components using greedyROI and HALS

[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options);  % initialize

% display centers of found components
Cn =  reshape(P.sn,d1,d2); %correlation_image(Y); %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)

%% look at and (optionally) manually refine components
refine_components = true;  % flag for manual refinement
if refine_components
    [Ain,Cin,center] = manually_refine_components(Y,Ain,Cin,center,Cn,tau,options);
end

contour_threshold = 0.95;                       % amount of energy used for each component to construct contour plot
figure;
[Coor,json_file] = plot_contours(Ain,reshape(P.sn,d1,d2),contour_threshold,1); % contour plot of spatial footprints

%% which ROI do you actually want to use?
% USE ALL for now
% roi_to_use = 1 : size(Cin, 1);

%% now, use these ROI to look at each trial individually

files = dir([single_path '*.tif']);
n_trials = min(numel(files), numel(Motif));

for trial_num = 1 : n_trials
    
    %% read file and preprocess new data
%     curr_file = files(trial_num).name;
    curr_file = Motif(trial_num).name;
    nam = [single_path curr_file];        % insert path to tiff stack here
    sframe=1;						% user input: first frame to read (optional, default 1)
    num2read=[];					% user input: how many frames to read   (optional, default until the end)

    Y = bigread2(nam,sframe,num2read);
    Y = Y - min(Y(:)); 
    if ~isa(Y,'double');    Y = double(Y);  end         % convert to double

    [d1,d2,T] = size(Y);                                % dimensions of dataset
    d = d1*d2;                                          % total number of pixels

    noise_frames = 1 : Motif(trial_num).Tiffsinging(1) - 1; % one back from first Tiff frame of singing
    
    options = CNMFSetParms(...                      
    'd1',d1,'d2',d2,...                         % dimensions of datasets
    'search_method','ellipse','dist',3,...      % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                    % merging threshold
    'gSig',tau,...
    'noise_method', 'paul',...
    'noise_range', noise_frames...              % PAUL 5.12.2016
    );
    
    [P,Y] = preprocess_data(Y,p);        
    % re-estimate noise my way
    P = estimate_noise(P, Y, noise_frames);

    fprintf('\ttrial %d loaded\n', trial_num);

    %% update temporal, then spatial components
    fprintf('***first temporal + spatial update***\n');
    Yr = reshape(Y,d,T);
    clear Y;
    [Cin,fin,P,~] = update_temporal_components(Yr, Ain, [], [], [], P, options); % we pass blank for spatial background and current calcium signal/noise estimates
    [A,b,Cin] = update_spatial_components(Yr,Cin,fin,Ain,P,options);

    %% update temporal components
    fprintf('***second temporal update***\n');
    [C,f,P,S] = update_temporal_components(Yr,A,b,Cin,fin,P,options);

    %% merge found components
%     fprintf('***merge***\n');
%     [Am,Cm,~,merged_ROIs,P,Sm] = merge_components(Yr,A,b,C,f,P,S,options); % ~ was K_m, but not plotting --> don't need yet

    %% repeat
    fprintf('***final temporal + spatial update***\n');
    [A2,b2,Cm] = update_spatial_components(Yr,C,f,A,P,options);
% took out because different inputs (Cm vs. C): [A2,b2,Cm] = update_spatial_components(Yr,Cm,f,Am,P,options);
    [C2,f2,P,S2] = update_temporal_components(Yr,A2,b2,Cm,f,P,options);

    %% finalize things and store
    fprintf('***extract signal and store***\n');
    [C_df,df,S_df, raw, background] = extract_DF_F(Yr,[A2, b2],[C2; f2],S2,[]); % extract DF/F values
    maskSum = sum(A2, 1);
    
    for roi_num = 1 : size(S_df, 1) % roi_to_use

        trace(trial_num, roi_num).C_df = C_df(roi_num, :);
        trace(trial_num, roi_num).df = df(roi_num);
        trace(trial_num, roi_num).S_df = S_df(roi_num, :);
        trace(trial_num, roi_num).raw = raw(roi_num, :);
%         trace{trial_num, roi_num}.noise = P.neuron_sn{roi_num};
        trace(trial_num, roi_num).background = background(roi_num, :);
        trace(trial_num, roi_num).mask_sum = maskSum(roi_num);
        signal = (trace(trial_num, roi_num).df * (trace(trial_num, roi_num).C_df));
        trace(trial_num, roi_num).noise = std(trace(trial_num, roi_num).raw(noise_frames));
        trace(trial_num, roi_num).max_signal = range(signal);
        trace(trial_num, roi_num).SNR = trace(trial_num, roi_num).max_signal / trace(trial_num,roi_num).noise;
        trace(trial_num, roi_num).time = Motif(trial_num).frameTimes;
    
    end

    %% optionally, plot
    if debug == 1 || debug == 2

        figure();
        contour_threshold = 0.95;                       % amount of energy used for each component to construct contour plot
        [Coor,json_file] = plot_contours(A2,reshape(P.sn,d1,d2),contour_threshold,1);
        title('unordered components');
        
        if debug == 2
           pause; fprintf('...paused...\n'); 
        end

    end

end

% save everything, please
fprintf('***save***\n');
save([base_path 'extracted_CA'], 'trace');
save([base_path 'for_plots'], 'Yr', 'A2', 'C2', 'b2', 'f2', 'Cn', 'P', 'options');

%% space invaders!
% first, get stuff for "matchtoSpikePDF"
dots = matchToSpikePDF(trace);

fprintf('***SPACE INVADERS***\n');

num_trials = size(trace, 1);
num_roi = size(trace, 2);

space_invaders = nan(num_roi, num_trials);

for trial_num = 1 : num_trials
    
    curr_trial = trace(trial_num, :);
    curr_roi = numel(curr_trial);
    
    for roi_num = 1 : curr_roi
        
        if isfield(curr_trial(roi_num), 'noise')
                      
            sigz(roi_num, trial_num) = trace(trial_num, roi_num).max_signal;
            noiz(roi_num, trial_num) = trace(trial_num, roi_num).noise;
            space_invaders(roi_num, trial_num) = trace(trial_num, roi_num).SNR;
            
        end
        
    end
    
end
%%
figure(); hold on;
for i = 1:3
    plot(space_invaders(category==i), dots(category==i), 'o');
end
legend('great', 'almost good', 'bad');

find(category==3&space_invaders>8&dots>.8)

figure(); subplot(1,4,1)
cla;hold on;
for i=1:3
    histogram(space_invaders(category==i),0:1:20,'DisplayStyle','stairs','normalization','pdf');
end
legend('great', 'almost good', 'bad');

subplot(1,4,2)
cla;hold on;
for i=1:3
    histogram(sigz(category==i),'DisplayStyle','stairs','normalization','pdf');
end
legend('great', 'almost good', 'bad');

subplot(1,4,3)
cla;hold on;
for i=1:3
    histogram(noiz(category==i),'DisplayStyle','stairs','normalization','pdf');
end
legend('great', 'almost good', 'bad');

subplot(1, 4, 4)
cla;hold on;
for i=1:3
    histogram(dots(category==i),'DisplayStyle','stairs','normalization','pdf');
end
legend('great', 'almost good', 'bad');
% for i=1:3
%     plot(space_invaders(category==i),match2pdf(category==i),'o')
% end
%%
% loglog(all_noize, all_snr, '+'); xlabel('noise level (a.u.)'); ylabel('snr');

set(figure(), 'Position', [200 100 1500 800]);
subplot(1, 3, 1);
imagesc(space_invaders); xlabel('trial'); ylabel('roi'); title('space invaders - SNR'); colorbar();
subplot(1, 3, 2);
imagesc(sigz); xlabel('trial'); ylabel('roi'); title('signal'); colorbar();
subplot(1, 3, 3);
imagesc(noiz); xlabel('trial'); ylabel('roi'); title('noise'); colorbar();

%% optional

plot_components_GUI(Yr,A2,C2,b2,f2,Cn,options)


