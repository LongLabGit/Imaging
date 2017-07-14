function ef=genEfilt(tau,T)
normalize=1;
%if it is 1 it will make the filter height independent of the taus. was a
%problem before that the filter hegith was going to zero
if normalize==0
%     h = exp(-(0:T)/tau(2)) - exp(-(0:T)/tau(1));
    ef_d = exp(-(0:T)/tau(2));

    ef_h = -exp(-(0:T)/tau(1));

%     ef = {ef_h/max(h) ef_d/max(h)};
    ef = {ef_h ef_d};
else
    % new new way
    ef_d = exp(-(0:T)/tau(2));
    ef_h = -exp(-(0:T)/tau(1));
    %compute maximum:
    to = (tau(1)*tau(2))/(tau(2)-tau(1))*log(tau(2)/tau(1)); %time of maximum
    max_val = exp(-to/tau(2))-exp(-to/tau(1)); %maximum
    ef = {ef_h/max_val ef_d/max_val};
end
