function [samples_s, trials, mcmc,paramOD]  = sampleSpikes2_init(CaF,tau, Tguess,offsets, rescalings,plotit,paramOD)
%parameters
%noise level here matters for the proposal distribution (how much it 
%should trust data for proposals vs how much it should mix based on uniform prior)
%this is accounted for by calciumNoiseVar

calciumNoiseVar_init=.3; %inial noise estimate, michel:.3
p_spike=3/40;%what percent of the bins hacve a spike in then standard:3/40;
proposalVar=1;%likeliness to accept moves
nsweeps=4000; %number of sweeps of sampler, standard: 4000
% if acceptance rates are too high, increase proposal width, 
% if too low, decrease them (for time moves, tau, amplitude)
% tau_std = 1;
tau_std = [.5,.5]; %proposal variance of tau parameters (standard: [2,2])
tau_min=0.05;
tau_max=[15,15]; %5,5
% tau_max=[4,4];
%all of these are multiplied by big A
a_std = .2; %proposal variance of amplitude
a_min = 0;
a_max = 10;
b_std = .3; %propasal variance of baseline
b_min = 0;
b_max = 5;
exclusion_bound = .05;%dont let bursts get within x bins of eachother. this should be in time
maxNbursts =2;%standard: 4; if we want to add bursts, whats the maximum bnumber that we will look for?
minNburst=3;
%doesnt mattera
Dt=1; %bin unit - don't change this
A=400; % scale factor for all magnitudes for this calcium data setup
b=0; %initial baseline value
nu_0 = 5; %prior on shared burst time - ntrials
sig2_0 = .1; %prior on shared burst time - variance
 paramNames={'A';'Dt';'a_max';'a_min';'a_std';'b';'b_max';'b_min';'b_std';...
        'calciumNoiseVar_init';'exclusion_bound';'maxNbursts';'minNburst';...
        'nsweeps';'nu_0';'p_spike';'proposalVar';'sig2_0';'tau_max';'tau_min';'tau_std'};

if ~isempty(paramOD)%if we are trying to pass in paramters, rewrite the old ones
    for pn=1:length(paramNames)
        eval([paramNames{pn},'=paramOD.(paramNames{pn});']);
    end
end


if isempty(paramOD)%if we are starting from scartch, store it
    for pn=1:length(paramNames)
        paramOD.(paramNames{pn})=eval(paramNames{pn});
    end
end

indreport=.1:.1:1;
indreporti=round(nsweeps*indreport);
fprintf('Progress:')


% initialize some parameters
nBins = cellfun(@length,CaF); %for all of this, units are bins and spiketrains go from 0 to T where T is number of bins
ef = genEfilt(tau,nBins);%exponential filter
ntrials = size(CaF,1);%number of motifs

%for each trial
burstBins = cell(ntrials,nsweeps);
samples_a  = cell(ntrials,nsweeps);
%on average
samples_s = cell(1,nsweeps);
samples_c = cell(1,nsweeps);
samples_tau = cell(1,nsweeps);
spi_std = cell(1,nsweeps);%?
N_sto = [];
objective = [];

calciumNoiseVar = ones(ntrials,1)*calciumNoiseVar_init; %separate calcium per trial
init_cond_a = zeros(ntrials,1);
baseline = zeros(ntrials,1);

% intiailize burst train and predicted calcium
%this is based on simply what we tell it. 
% ssi is the shared times
[ssi,ati,sti,st_std,ci,logC,m]=initSC(CaF,ntrials,Tguess,nBins,b,p_spike,A,ef,tau,Dt,offsets,rescalings,a_min);
sti_= sti;
logC_= logC;
N=length(ssi);
if tau(1)>tau_max(1)*1.5
    disp('your tau_max is lower than your initial tau, set it to that')
    tau(1)=tau_max(1);
end
%% loop over sweeps to generate samples
addMoves = [0 0]; %first elem is number successful, second is number total
dropMoves = [0 0];
timeMoves = [0 0];
ampMoves = [0 0];
tauMoves = [0 0];
for i = 1:nsweeps
    % do burst time moves
    for ii = 1:10
        for ti = 1:ntrials
            %guess on time and amplitude
            si = sti{ti};
            ai = ati{ti};
            for ni = 1:N%for each burst
                tmpi = si(ni);
                tmpi_ = si(ni)+(proposalVar*randn); %add in noise 
                % bouncing off edges
                nB=1;
                while tmpi_>nBins(ti) || tmpi_<0
                    if tmpi_<0
                        tmpi_ = -(tmpi_);
                    elseif tmpi_>nBins(ti)
                        tmpi_ = nBins(ti)-(tmpi_-nBins(ti));
                    end
                    nB=nB+1;
                    if nB>1e5
                        error('variance too high')
                    end
                end
                %if its too close to another burst, reject this move
                if any(abs(tmpi_-si([1:(ni-1) (ni+1):end]))<exclusion_bound)
                    continue
                end
                
                %we start with ci{ti}. take out the signal from where we
                %thought the burst was, add in where we think it is now
                
                %create the proposal si_ and ci_
                %update logC_ to adjusted
                [si_, ci_, logC_(ti)] = removeSpike(si,ci{ti},logC(ti),ef,ai(ni),tau,CaF{ti},tmpi,ni, Dt, A, (tmpi-offsets(ti))*rescalings(ti));
                if abs(logC_(ti) - sum(-(ci_-CaF{ti}).^2))>1
%                     keyboard
                    error('keyboard')
                end
                if(any(ci_<-1e-5))
                    figure;plot(ci_)
%                     keyboard
                    error('keyboard')
                end
                [si_, ci_, logC_(ti)] = addSpike(si_,ci_,logC_(ti),ef,ai(ni),tau,CaF{ti},tmpi_,ni, Dt, A, (tmpi_-offsets(ti))*rescalings(ti));
                
                %check logC update
                if abs(logC_(ti) - sum(-(ci_-CaF{ti}).^2))>1
%                     keyboard
                    error('keyboard')
                end
                
                if(any(ci_<-1e-5))
                    figure;plot(ci_)
%                     keyboard
                    error('keyboard')
                end
                
                %accept or reject
                %for prior: (1) use ratio, (2) use ratio with fixed st_std, (3) set prior to 1.
                if ntrials == 1%if we only have one trial
                    prior_ratio = 1;
                else
                    newDist=-(si_(ni)-ssi(ni))^2;
                    origDist=-(si(ni)-ssi(ni))^2;
                    prior_ratio = exp((1/(2*st_std(ni)^2))*(newDist-origDist));
                end
%                 prior_ratio = 1;
%                 ratio = exp(sum((1/(2*calciumNoiseVar(ti)))*(logC_(ti)-logC(ti))*nBins(ti)))*prior_ratio;
                ratio = exp(sum((1/(2*calciumNoiseVar(ti)))*(logC_(ti)-logC(ti))))*prior_ratio;
                if ratio>1 %accept
                    si = si_;
                    ci{ti} = ci_;
                    logC(ti) = logC_(ti);
                    timeMoves = timeMoves + [1 1];
                    proposalVar = proposalVar + 2*.1*rand*proposalVar/sqrt(i);
                elseif rand<ratio %accept
                    si = si_;
                    ci{ti} = ci_;
                    logC(ti) = logC_(ti);
                    timeMoves = timeMoves + [1 1];
                    proposalVar = proposalVar + 2*.1*rand*proposalVar/sqrt(i);
                else
                    %reject - do nothing
                    proposalVar = proposalVar - .1*rand*proposalVar/sqrt(i);
                    timeMoves = timeMoves + [0 1];
                end

            end
            sti{ti} = si;
%                 ati{ti} = ai;
        end
    end
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    % re-estimate the mean and std deviations of bursts across trials
    if ~isempty(ssi)
        if ntrials == 1
            ssi = (cell2mat(sti));
            st_std = [];
        else
            ssi = mean(cell2mat(sti));
            df = (ntrials); %DOF (possibly ntrials-1)
            st_std = sqrt(sum((cell2mat(sti)-repmat(ssi,ntrials,1)).^2)/df); %separate std per burst

            %sample shared burst times from current estimate of st_std;
            ssi = ssi + st_std/sqrt(ntrials).*randn(1,N);

            %sample from distribution
            for ni = 1:length(st_std)
                A_samp = 0.5 * (ntrials + nu_0);
                B_samp = 1/(0.5 * (df * (st_std(ni))^2 + nu_0*sig2_0 ));
                st_std(ni) = sqrt(1/gamrnd(A_samp,B_samp)); %this could be inf but it shouldn't be
            end
        end
    end
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    % update amplitude of each burst
    for ii = 1:1
        for ti = 1:ntrials
            si = sti{ti}; 
            ai = ati{ti};
            for ni = 1:N
                %sample with random walk proposal
                tmp_a = ai(ni);
                tmp_a_ = tmp_a+(a_std*randn); %with bouncing off min and max
                indA=1;
                while tmp_a_>a_max || tmp_a_<a_min
                    if tmp_a_<a_min
                        tmp_a_ = a_min+(a_min-tmp_a_);
                    elseif tmp_a_>a_max
                        tmp_a_ = a_max-(tmp_a_-a_max);
                    end
                    %if it gets stuck because a_std has grown too large to get a value in the allowed ranged. 
                    %take a look at taus
                    indA=indA+1;
                    if indA>1e4
%                         keyboard;
                        figure;plot(mean(objective))%-check that its gettng
                        error('keyboard')
                        %save everything for josh, look at quality of
                        %cell's traces
                    end
                end

                %set si_ to set of bursts with the move and ci_ to adjusted calcium and update logC_ to adjusted
                [si_, ci_, logC_(ti)] = removeSpike(si,ci{ti},logC(ti),ef,ai(ni),tau,CaF{ti},si(ni),ni, Dt, A, (si(ni)-offsets(ti))*rescalings(ti));
                %check logC update
                if abs(logC_(ti) - sum(-(ci_-CaF{ti}).^2))>1
%                     keyboard
                    error('keyboard')
                end
                
                [si_, ci_, logC_(ti)] = addSpike(si_,ci_,logC_(ti),ef,tmp_a_,tau,CaF{ti},si(ni),ni, Dt, A, (si(ni)-offsets(ti))*rescalings(ti));

                %check logC update
                if abs(logC_(ti) - sum(-(ci_-CaF{ti}).^2))>1
%                     keyboard
                    error('keyboard')
                end
                
                ai_ = ai;
                ai_(ni) = tmp_a_;

                if(any(ci_<-1e-5))
                    figure;plot(ci_)
%                     keyboard
                    error('keyboard')
                end
        
                %accept or reject - include a prior?
                prior_ratio = 1;
                ratio = exp(sum((1/(2*calciumNoiseVar(ti)))*(logC_(ti)-logC(ti))))*prior_ratio;
                if ratio>1 %accept
                    ai = ai_;
                    si = si_;
                    ci{ti} = ci_;
                    logC(ti) = logC_(ti);
                    ampMoves = ampMoves + [1 1];
                    a_std = a_std + 2*.1*rand*a_std/sqrt(i);
                elseif rand<ratio %accept
                    ai = ai_;
                    si = si_;
                    ci{ti} = ci_;
                    logC(ti) = logC_(ti);
                    ampMoves = ampMoves + [1 1];
                    a_std = a_std + 2*.1*rand*a_std/sqrt(i);
%                     a_std=min(a_std,10);
                else
                    %reject - do nothing
                    a_std = a_std - .1*rand*a_std/sqrt(i);
                    ampMoves = ampMoves + [0 1];
                end
            end
            ati{ti} = ai;
        end
    end
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    % update amplitude of each initial condition
    for ii = 1:1
        for ti = 1:ntrials

            %sample with random walk proposal
            tmp_a = init_cond_a(ti);
            tmp_a_ = tmp_a+(a_std*randn); %with bouncing off min and max
            while tmp_a_>a_max || tmp_a_<0
                if tmp_a_<0
                    tmp_a_ = 0+(0-tmp_a_);
                elseif tmp_a_>a_max
                    tmp_a_ = a_max-(tmp_a_-a_max);
                end
            end

            %set si_ to set of bursts with the move and ci_ to adjusted calcium and update logC_ to adjusted
            [ci_, logC_(ti)] = remove_init(ci{ti},logC(ti),ef,tmp_a,tau,CaF{ti},Dt,A);
            [ci_, logC_(ti)] = add_init(ci_,logC_(ti),ef,tmp_a_,tau,CaF{ti},Dt,A);
                
            %check logC update
            if abs(logC_(ti) - sum(-(ci_-CaF{ti}).^2))>1
%                 keyboard
                error('keyboard')
            end
                
            if(any(ci_<-1e-5))
                figure;plot(ci_)
%                 keyboard
                error('keyboard')
            end
                
            %accept or reject - include a prior?
            prior_ratio = 1;
            ratio = exp(sum((1/(2*calciumNoiseVar(ti)))*(logC_(ti)-logC(ti))))*prior_ratio;
            if ratio>1 %accept
                init_cond_a(ti) = tmp_a_;
                ci{ti} = ci_;
                logC(ti) = logC_(ti);
            elseif rand<ratio %accept
                init_cond_a(ti) = tmp_a_;
                ci{ti} = ci_;
                logC(ti) = logC_(ti);
            else
                %reject - do nothing
            end
        end
    end
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    % update baseline of each trial
    for ii = 1:1
        for ti = 1:ntrials

            %sample with random walk proposal
            tmp_b = baseline(ti);
            tmp_b_ = tmp_b+(b_std*randn); %with bouncing off min and max
            while tmp_b_>b_max || tmp_b_<b_min
                if tmp_b_<b_min
                    tmp_b_ = b_min+(b_min-tmp_b_);
                elseif tmp_b_>b_max
                    tmp_b_ = b_max-(tmp_b_-b_max);
                end
            end

            %set si_ to set of bursts with the move and ci_ to adjusted calcium and update logC_ to adjusted
            [ci_, logC_(ti)] = remove_base(ci{ti},logC(ti),tmp_b,CaF{ti},A);   
            [ci_, logC_(ti)] = add_base(ci_,logC_(ti),tmp_b_,CaF{ti},A);

            %check logC update
            if abs(logC_(ti) - sum(-(ci_-CaF{ti}).^2))>1
%                 keyboard
                error('keyboard')
            end
                
                
            if(any(ci_<-1e-5))
                figure;plot(ci_)
%                 keyboard
                error('keyboard')
            end
                
            %accept or reject - include a prior?
            prior_ratio = 1;
            ratio = exp(sum((1/(2*calciumNoiseVar(ti)))*(logC_(ti)-logC(ti))))*prior_ratio;
            if ratio>1 %accept
                baseline(ti) = tmp_b_;
                ci{ti} = ci_;
                logC(ti) = logC_(ti);
                b_std = b_std + 2*.1*rand*b_std/sqrt(i);
            elseif rand<ratio %accept
                baseline(ti) = tmp_b_;
                ci{ti} = ci_;
                logC(ti) = logC_(ti);
                b_std = b_std + 2*.1*rand*b_std/sqrt(i);
            else
                b_std = b_std - .1*rand*b_std/sqrt(i);
                %reject - do nothing
            end
        end
    end
%         if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    if i>1
    %% this is the section that updates the number of spikes (add/drop)
    % loop over add/drop a few times
    %define insertion proposal distribution as the likelihood function
    %define removal proposal distribution as uniform over bursts
    %perhaps better is to choose smarter removals.
        for ii = 1
            %propose a uniform add
            %tmpi = T(1)*rand; + max(0,max(offsets.*rescalings));
            %pick a random point
            tmpi = max(0,max(offsets.*rescalings)) + (min(nBins)-max(0,max(offsets.*rescalings)))*rand;
            %dont add if we have too many bursts or the proposed new location
            %is too close to another one
            if ~(any(abs(tmpi-ssi)<exclusion_bound) || N >= maxNbursts)
                ssi_ = [ssi tmpi];
                %must add burst to each trial (at mean location or sampled -- more appropriate if sampled, but make sure no trial's burst violates exclusion)
                logC_ = logC;
                cti_ = ci;
                ati_ = ati;
                for ti = 1:ntrials
                    a_init = max(CaF{ti}(max(1,floor(tmpi)))/A - baseline(ti) + a_std*randn,a_min);%propose an initial amplitude for it
                    [si_, ci_, logC_(ti)] = addSpike(sti{ti},ci{ti},logC_(ti),ef,a_init,tau,CaF{ti},tmpi, N+1, Dt, A, (tmpi-offsets(ti))*rescalings(ti)); %adds all trials' bursts at same time
                    if(any(ci_<-1e-5))
                        figure;plot(ci_)
%                         keyboard
                        error('keyboard')
                    end
                    sti_{ti} = si_;
                    cti_{ti} = ci_;
                    ati_{ti} = [ati_{ti} a_init];
                end
                fprob = 1/nBins(1);%forward probability
                rprob = 1/(N+1);%reverse (remove at that spot) probability
                %accept or reject
%                 ratio = exp(sum((1./(2*calciumNoiseVar)).*(logC_-logC).*nBins))*(rprob/fprob)*(m(1)/(nBins(1)-m(1))); %posterior times reverse prob/forward prob
                ratio = exp(sum((1./(2*calciumNoiseVar)).*(logC_-logC)))*(rprob/fprob)^ntrials*(m(1)/(nBins(1)-m(1)))^ntrials; %posterior times reverse prob/forward prob
                if (ratio>1)||(ratio>rand) %accept
                    ati = ati_;
                    ssi = ssi_;
                    sti = sti_;
                    ci = cti_;
                    logC = logC_;
                    addMoves = addMoves + [1 1];
                    if ntrials>1
                        st_std = [st_std 1];
                    end
                else
                    %reject - do nothing
                    addMoves = addMoves + [0 1];
                end
                N = length(ssi);
            end


            % delete
            if N>minNburst%i.e. we if have at least the minimum 
                %propose a uniform removal
                tmpi = randi(N);%pick one of the spikes at random
                ssi_ = ssi;
                ssi_(tmpi) = [];
                %must remove burst from each trial
                logC_ = logC;
                cti_ = ci;
                ati_ = ati;
                for ti = 1:ntrials
                    %always remove the ith burst (the ith burst of each trial is linked)                     
                    [si_ ci_, logC_(ti)] = removeSpike(sti{ti},ci{ti},logC_(ti),ef,ati{ti}(tmpi),tau,CaF{ti},sti{ti}(tmpi),tmpi, Dt, A, (sti{ti}(tmpi)-offsets(ti))*rescalings(ti));
                    if(any(ci_<-1e-5))%if somehow we get to be below 0
                        figure;plot(ci_)
%                         keyboard
                        error('keyboard')
                    end
                    sti_{ti} = si_;
                    cti_{ti} = ci_;
                    ati_{ti}(tmpi) = [];
                end

                %reverse probability
                rprob = 1/nBins(1);

                %compute forward prob
                fprob = 1/N;

                %accept or reject
                %posterior times reverse prob/forward prob
                ratio = exp(sum((1./(2*calciumNoiseVar)).*(logC_-logC)))*(rprob/fprob)^ntrials*((nBins(1)-m(1))/m(1))^ntrials; 

                if (ratio>1)||(ratio>rand)%accept
                    ati = ati_;
                    ssi = ssi_;
                    sti = sti_;
                    ci = cti_;
                    logC = logC_;
                    dropMoves = dropMoves + [1 1]; 
                    if ntrials>1
                        st_std(tmpi) = [];
                    end
                else
                    %reject - do nothing
                    dropMoves = dropMoves + [0 1];
                end
                N = length(ssi);
            end
        end
    end
    if i>1
    % update tau1 (via random walk sampling)
    for ii = 1:1  
        % update first tau value
        tau_ = tau;
        tau_(1) = tau_(1)+(tau_std(1)*randn); %with bouncing off min and max 
        
        upperBound=min(tau_max(1),tau(2));
        while tau_(1)>upperBound || tau_(1)<tau_min
            if tau_(1)<tau_min
                tau_(1) = tau_min+(tau_min-tau_(1));
            elseif tau_(1)>upperBound
                tau_(1) = upperBound-(tau_(1)-upperBound);
            end
        end 
   
        
        ef_ = genEfilt(tau_,nBins);%exponential filter
        
        
        %remove all old bumps and replace them with new bumps    
        logC_ = logC;
        cti_ = ci;
        for ti = 1:ntrials
            ci_ = ci{ti};
            for ni = 1:N
                [~, ci_, logC_(ti)] = removeSpike(sti{ti},ci_,logC_(ti),ef,ati{ti}(ni),tau,CaF{ti},sti{ti}(ni),ni, Dt, A, (sti{ti}(ni)-offsets(ti))*rescalings(ti) );
                [~, ci_, logC_(ti)] = addSpike(sti{ti},ci_,logC_(ti),ef_,ati{ti}(ni),tau_,CaF{ti},sti{ti}(ni),ni, Dt, A, (sti{ti}(ni)-offsets(ti))*rescalings(ti));
            end
            [ci_, logC_(ti)] = remove_init(ci_,logC_(ti),ef,init_cond_a(ti),tau,CaF{ti},Dt,A);
            [ci_, logC_(ti)] = add_init(ci_,logC_(ti),ef_,init_cond_a(ti),tau_,CaF{ti},Dt,A);
            cti_{ti} = ci_;
            if(any(ci_<-1e-5))
                figure;plot(ci_)
%                 keyboard
                error('keyboard')
            end
        end
                
                
        %accept or reject
        prior_ratio = (gampdf(tau_(1),1.5,1))/(gampdf(tau(1),1.5,1));
        ratio = exp(sum(sum((1./(2*calciumNoiseVar)).*(logC_-logC))))*prior_ratio;
        if ratio>1 %accept
            ci = cti_;
            logC = logC_;
            tau = tau_;
            ef = ef_;
            tauMoves = tauMoves + [1 1];
            tau_std(1) = tau_std(1) + 2*.1*rand*tau_std(1)/sqrt(i);
        elseif rand<ratio %accept
            ci = cti_;
            logC = logC_;
            tau = tau_;
            ef = ef_;
            tauMoves = tauMoves + [1 1];
            tau_std(1) = tau_std(1) + 2*.1*rand*tau_std(1)/sqrt(i);
        else
            %reject - do nothing
            tau_std(1) = tau_std(1) - .1*rand*tau_std(1)/sqrt(i);
            tauMoves = tauMoves + [0 1];
        end

    end
    
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    % update tau2 (via random walk sampling)
    for ii = 1:1  
        % update both tau values
        tau_ = tau;
        nnnn=randn;%if it breaks here then i can know that it was due to the random number
        tau_(2) = tau_(2)+(tau_std(2)*nnnn);
        indT=1;
        while tau_(2)>tau_max(2) || tau_(2)<tau_(1)
            if tau_(2)<tau_(1)
                tau_(2) = tau_(1)+(tau_(1)-tau_(2));%bounce off of tau 1
            elseif tau_(2)>tau_max(2)
                tau_(2) = tau_max(2)-(tau_(2)-tau_max(2));
            end
            indT=indT+1;
            if indT>1e6
%                keyboard;
                error('keyboard')
            end
        end  
        
        ef_ = genEfilt(tau_,nBins);%exponential filter
        
        
        %remove all old bumps and replace them with new bumps    
        logC_ = logC;
        cti_ = ci;
        for ti = 1:ntrials
            ci_ = ci{ti};
            for ni = 1:N
                [~, ci_, logC_(ti)] = removeSpike(sti{ti},ci_,logC_(ti),ef,ati{ti}(ni),tau,CaF{ti},sti{ti}(ni),ni, Dt, A, (sti{ti}(ni)-offsets(ti))*rescalings(ti) );
                [~, ci_, logC_(ti)] = addSpike(sti{ti},ci_,logC_(ti),ef_,ati{ti}(ni),tau_,CaF{ti},sti{ti}(ni),ni, Dt, A, (sti{ti}(ni)-offsets(ti))*rescalings(ti));
            end
            [ci_, logC_(ti)] = remove_init(ci_,logC_(ti),ef,init_cond_a(ti),tau,CaF{ti},Dt,A);
            [ci_, logC_(ti)] = add_init(ci_,logC_(ti),ef_,init_cond_a(ti),tau_,CaF{ti},Dt,A);
            cti_{ti} = ci_;
            if(any(ci_<-1e-5))
                figure;plot(ci_)
%                 keyboard
                error('keyboard')
            end
        end
                        
                
        %accept or reject
        prior_ratio = gampdf(tau_(2),12,1)/gampdf(tau(2),12,1);
        ratio = exp(sum(sum((1./(2*calciumNoiseVar)).*(logC_-logC))))*prior_ratio;
        if ratio>1 %accept
            ci = cti_;
            logC = logC_;
            tau = tau_;
            ef = ef_;
            tauMoves = tauMoves + [1 1];
            tau_std(2) = tau_std(2) + 2*.1*rand*tau_std(2)/sqrt(i);
        elseif rand<ratio %accept
            ci = cti_;
            logC = logC_;
            tau = tau_;
            ef = ef_;
            tauMoves = tauMoves + [1 1];
            tau_std(2) = tau_std(2) + 2*.1*rand*tau_std(2)/sqrt(i);
        else
            %reject - do nothing
            tau_std(2) = tau_std(2) - .1*rand*tau_std(2)/sqrt(i);
            tauMoves = tauMoves + [0 1];
        end

    end
    
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         keyboard
%     end
    
    end
    % re-estimate the noise variance
    if ~isempty(ssi)
        for ti = 1:ntrials
            df = (numel(ci{ti})); %DOF (possibly numel(ci(ti,:))-1)
            calciumNoiseVar(ti) = sum((ci{ti}-CaF{ti}).^2)/df; %ML - DOF, init, baseline and each burst amplitude

            A_samp = 0.5 * (df);
            B_samp = 1/(0.5 * df * calciumNoiseVar(ti));
            calciumNoiseVar(ti) = 1/gamrnd(A_samp,B_samp); %this could be inf but it shouldn't be
        end
%         display(['std_c: ' num2str(sqrt(calciumNoiseVar'))])
    end
    

    %store things
    N_sto = [N_sto N];
    burstBins(:,i) = sti; %trial bursts
    samples_a(:,i) = ati; %trial amplitudes
    samples_a0(:,i) = init_cond_a; %trial initial amplitudes
    samples_b(:,i) = baseline; %trial baselines
    samples_s{i} = ssi; %shared bursts
    samples_c{i} = ci; %save calcium traces
    samples_tau{i} = tau; %save tau values
    samples_cnoise(:,i) = calciumNoiseVar; %save calcium noise values (is a variance)
    spi_std{i} = st_std;    
    %store overall logliklihood as well
%     if abs(sum(logC)-sum(sum(-(cell2mat(ci)-cell2mat(CaF)).^2)))>1
%         figure(90)
%         subplot(121)
%         plot(cell2mat(samples_c{i-1})')
%         subplot(122)
%         plot(cell2mat(ci)')
%         keyboard
%     end

    objective = [objective logC];
    if plotit
        figure(10);
        plot(ci{1});hold on;
        plot(CaF{1},'r');hold off
        drawnow
    end
    if sum(ismember(indreporti,i))
        fprintf([num2str(indreport(ismember(indreporti,i)),2),', '])
    end
end
disp('Done')
%% Vigi's Clean up
%details about what the mcmc did
%addMoves, dropMoves, and timeMoves give acceptance probabilities for each subclass of move
mcmc.addMoves=addMoves;
mcmc.timeMoves=timeMoves;
mcmc.dropMoves=dropMoves;
mcmc.ampMoves=ampMoves;
mcmc.tauMoves=tauMoves;
mcmc.N_sto=N_sto;%number of bursts

trials.burstTimes=burstBins;
trials.amp=samples_a;
trials.base=samples_b;
trials.a0=samples_a0;
trials.curves=samples_c;
trials.tau=samples_tau;
trials.spi_std=spi_std;
trials.obj = objective;
trials.cnoise = samples_cnoise;

disp('Below are the moves that were done: ')
display(['time: ' num2str(timeMoves(1)/timeMoves(2))])
display(['add: ' num2str(addMoves(1)/addMoves(2))])
display(['drop: ' num2str(dropMoves(1)/dropMoves(2))])
display(['amplitude: ' num2str(ampMoves(1)/ampMoves(2))])
display(['tau: ' num2str(tauMoves(1)/tauMoves(2))])