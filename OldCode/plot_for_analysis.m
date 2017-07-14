function [] = plot_for_analysis(file_to_load, roi_num, trial_num)

fprintf('load data');
z = tic;
load(file_to_load); % will be 'extracted_Ca'
fprintf('%d seconds to load data\n', toc(z));

set(figure(), 'Position', [200 100 1400 800]);

%% plot ROI
subplot(2, 3, 1);

%% overlay all traces - raw and extracted
all_trials = trace(:, roi_num);

for i = 1 : numel(all_trials)
    
    % raw
    subplot(2, 3, 2);
    raw_baseline(i) = min(all_trials(i).raw);
    plot(all_trials(i).raw - raw_baseline(i)); 
    if i == 1
        hold on
    end
    
    % extracted (without baseilne)
    subplot(2, 3, 3);
    extract_baseline(i) = min(all_trials(i).C_df);
    plot(all_trials(i).C_df - extract_baseline(i)); 
    if i == 1
        hold on
    end
    
end

%% plot traces for current trials
subplot(2, 3, 5);
plot((all_trials(trial_num).C_df - extract_baseline(trial_num)) * all_trials(trial_num).df); hold on;
plot(all_trials(trial_num).raw - raw_baseline(trial_num));


