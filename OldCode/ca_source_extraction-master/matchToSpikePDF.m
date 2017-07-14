function dots = matchToSpikePDF(traces)

for cell = 1 : size(traces, 2)

    curr_trials = vertcat(traces(:, cell).S_df);
    pdf = sum(curr_trials, 1);
    pdf_norm = pdf / norm(pdf);
    norms = sqrt(sum(curr_trials.^2, 2));
    dots(cell, :) = curr_trials * pdf_norm' ./ norms;
    
end

dots(isnan(dots)) = 0;

end
