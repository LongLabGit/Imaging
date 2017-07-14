% trial = 1;
% 
% for cell = 1 : 26
%     
%     if ~isfield(trace{trial}{cell}, 'noise')
%         continue;
%     end
%     
%     max_signal = max(trace{trial}{cell}.df * (0 + trace{trial}{cell}.C_df));
% %     mean_signal = mean(trace{trial}{cell}.df * (1 + trace{trial}{cell}.C_df));
%     noise = trace{trial}{cell}.noise;
%     snr(cell) = max_signal / noise;
% %     snr(cell) = mean_signal / noise;
% 
% end

% [best, best_inds] = sort(snr, 'descend');

% [~, cell] = max(snr);

% figure();
% plot(trace{trial}{cell}.raw, 'k--');
% hold on;
% plot(trace{trial}{cell}.df * (1 + trace{trial}{cell}.C_df), 'k'); 
% plot(ones(1, 70) * trace{trial}{cell}.df, 'b--');
% plot(ones(1, 70) * trace{trial}{cell}.df + (2*trace{trial}{cell}.noise), 'r--');
% plot(ones(1, 70) * trace{trial}{cell}.df - (2*trace{trial}{cell}.noise), 'r--');
% legend('raw', 'extracted', 'baseline', 'noise+', 'noise-', 'location', 'best');
% 
% % plot(trace{trial}{cell}.df * (trace{trial}{cell}.C_df), 'k');
% % plot(trace{trial}{cell}.df * (1 + trace{trial}{cell}.C_df), 'k'); 
% % plot(ones(1, 70) * (trace{trial}{cell}.noise), 'r--');
% % legend('raw', 'extracted', 'extracted + baseline', 'noise', 'location', 'best');
% 
% title(sprintf('cell %d, SNR = %.3d', cell, snr(cell)));

trial = 1;
cell = 12;
figure();
raw = trace(trial, cell).raw;
baseline = trace(trial, cell).df;
extracted = trace(trial, cell).C_df;
% background = trace{trial}{cell}.background;
noise = trace(trial, cell).noise;
plot(raw, 'k--');
hold on;
plot(extracted * baseline, 'k');
plot(raw - extracted * baseline);
plot(ones(1, length(raw)) * trace(trial, cell).df, 'b--');
% plot(background);
plot(ones(1, length(raw)) * trace(trial, cell).df + (trace(trial, cell).noise), 'r--');
plot(ones(1, length(raw)) * trace(trial, cell).df - (trace(trial, cell).noise), 'r--');
legend('raw', 'extracted', 'raw - extracted', 'baseline', 'noise-', 'noise+', 'location' ,'best'); %'noise+', 'noise-', 'location', 'best');

title(sprintf('cell %d, SNR = %.2d', cell, trace(trial, cell).SNR));





