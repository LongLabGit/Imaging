function P = estimate_noise(P, raw_data, noise_frames)
% our method for estimating noise: take STD of raw trace in noise frames

% raw data will be [Xpixels Ypixels num_frames]
rel_frames = raw_data(:, :, noise_frames);
norm_flag = 0; % normalize std by N or N-1? 0 means by N (default)
noise = std(rel_frames, 0, 3);
P.sn = reshape(noise, [numel(noise) 1]);

end