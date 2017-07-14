function SAMPLES = cont_ca_sampler_motifs(Y,P,Nsamples,B,params)

% Continuous time sampler
% Y                     data (normalized in [0,1])
% P                     intialization parameters (discrete time constant P.g required)
% Nsamples              number of samples (after burn-in period)
% B                     length of burn-in period
% params                optional additional parameters
% params.marg           flag for marginalized sampler (default 1)
% params.upd_gam        flag for updating gamma (default 0)
% params.gam_step       number of samples after which gamma is updated (default 50)

% output struct SAMPLES
% spikes                T x Nsamples matrix with spikes samples
% bp                    Nsamples x 1 vector with samples for spiking prior probability
% Am                    Nsamples x 1 vector with samples for spike amplitude

% If marginalized sampler is used
% Cb                    posterior mean and sd for baseline
% Cin                   posterior mean and sd for initial condition
% else
% Cb                    Nsamples x 1 vector with samples for baseline
% Cin                   Nsamples x 1 vector with samples for initial concentration
% sn                    Nsamples x 1 vector with samples for noise variance

% If gamma is updated
% g                     Nsamples x 1 vector with the gamma updates

% Author: Eftychios A. Pnevmatikakis

if nargin == 4
    marg_flag = 1;
    gam_flag = 0;
else
    if isfield(params,'marg')
        marg_flag = params.marg;
    else
        marg_flag = 1;
    end
    if isfield(params,'upd_gam')
        gam_flag = params.upd_gam;
    else
        gam_flag = 0;
    end
    if ~isfield(params,'gam_step')
        gam_step = 50;
    else
        gam_step = params.gam_step;
    end
end

if gam_flag
    options = optimset('GradObj','On','Display','Off','Algorithm','interior-point','TolX',1e-6);
end

T = length(Y);
g = P.g;
Dt = 1; %1/P.f;                                     % length of time bin
tau = -Dt/log(g); %Dt/(1-g);                    % continuous time constant
if ~isfield(P,'Cb')
    P.Cb = mean(Y(1:round(T/2)))/2;             % set an arbitrary baseline initializer
end
if isfield(P,'sl');
    sl = [0;P.sl];
    dsl = diff(sl);
    for i = 1:length(P.sl)-1
        G(P.sl(i)+1,P.sl(i))=0;
    end
else
    sl = [0,T];
    dsl = T;
end
ldsl = length(dsl);
if ~isfield(P,'sn')
    for i = 1:ldsl
        temp = (xcov(Y(sl(i)+1:sl(i+1)),1))/T;
        P.sn(i) = sqrt((g*temp(2) - temp(1))/g);
        if P.sn(i)^2<0
            temp = diff(xcov(Y(sl(i)+1:sl(i+1)),1))/T;
            P.sn(i) = sqrt(temp(1));
            if P.sn(i)^2 < 0
                P.sn(i) = std(Y(sl(i)+1:sl(i+1)));
            end
        end
    end
    P.sn = max(P.sn);
end
sg = P.sn;

fprintf('Initializing using noise constrained FOOPSI...  ');
if ldsl >= 1
    Z = cell(ldsl,1);
    for i = 1:ldsl
        [Z_temp,~,~] = optimal_foopsi_lars(Y(sl(i)+1:sl(i+1))',g,P.sn,P.Cb(i));
        Z{i} = Z_temp(:);
    end
    Z = cell2mat(Z);
else
    [Z,~,~] = optimal_foopsi_lars(Y(:)',g,P.sn,P.Cb);
end
fprintf('done. \n');
SAMPLES.Z  = Z;

G = spdiags(ones(T,1)*[-P.g,1],[-1,0],T,T); %foopsi_matrix(T,P.g);
if isfield(P,'sl');
    sl = [0;P.sl];
    dsl = diff(sl);
    for i = 1:length(P.sl)-1
        G(P.sl(i)+1,P.sl(i))=0;
    end
else
    sl = [0,T];
    dsl = T;
end
ldsl = length(dsl);

sp = G*Z(:);                                   % extract spikes
%figure;stem(sp); drawnow;
c1 = zeros(ldsl,1);
for i = 1:ldsl
    c1(i) = sp(sl(i)+1);    
    sp(sl(i)+1) = 0;
end
spiketimes_ = cell(ldsl,1);
s_in = sp>0.9*quantile(sp,1);
nsp = 0;
for i= 1:ldsl
    fs_in = find(s_in(sl(i)+1:sl(i+1)));
    spiketimes_{i} = Dt*(fs_in + rand(size(fs_in)) - 0.5);
    spiketimes_{i}(spiketimes_{i} > Dt*dsl(i)) = 2*Dt*dsl(i) - spiketimes_{i}(spiketimes_{i} > Dt*dsl(i));
    nsp = nsp + length(spiketimes_{i});
end

lam_ = nsp/(T*Dt);

spks = cell2mat(spiketimes_);
%lam_ = nsp;
mu_spike = mean(spks);
sig_spike = 0.15;std(spks);

s_ = cell(ldsl,1);  % start with no spikes
for i = 1:ldsl
    %spiketimes_{i} = [];
    s_{i} = sparse(ceil(spiketimes_{i}/Dt),1,exp(-(spiketimes_{i} - Dt*ceil(spiketimes_{i}/Dt))/tau),dsl(i),1);
end

A_   = quantile(sp(s_in),0.9);                 % initial amplitude value
b_   = P.Cb;                                   % initial baseline value'
C_in = c1;                                     % initial value sample
ge = P.g.^((0:T-1)'); 
prec = 1e-2;     % precision
ge(ge<prec) = 0;
BC_mat = zeros(T,2*ldsl);
for i = 1:ldsl
    BC_mat(sl(i)+1:sl(i+1),i) = ones(dsl(i),1);
    BC_mat(sl(i)+1:sl(i+1),ldsl+i) = ge(1:dsl(i));
end

N = Nsamples + B;

ss = cell(N,ldsl); 
lam = zeros(N,3);
Am = zeros(N,1);
ns = zeros(N,ldsl);
Gam = zeros(N,1);
if ~marg_flag
    Cb = zeros(N,ldsl);
    Cin = zeros(N,ldsl);
    SG = zeros(N,ldsl);
end

Sp = .1*eye(2*ldsl+1);          % prior covariance
Ld = inv(Sp);
mu = [A_;b_(:);C_in(:)]; % prior mean 
lb = [0.02,0.02*ones(1,ldsl),0.01*ones(1,ldsl)]';     % lower bound for [A,Cb,Cin]
Ns = 15;                 % Number of HMC samples
mu_b = mu(2:end);
Ym = Y - BC_mat*mu_b;

mub = zeros(2*ldsl,1);
Sigb = zeros(2*ldsl,2*ldsl);

spiketimes = cell(ldsl,1);
Gs_ = zeros(T,1);
TM = [0,0];
%mu_spike = T/2;
%sig_spike = T;
for i = 1:N
    if gam_flag
        Gam(i) = g;
    end
    nsp = 0;
    
    for j = 1:ldsl
        TT = dsl(j);
        G = spdiags(ones(TT,1)*[-P.g,1],[-1,0],TT,TT);
        if marg_flag
            sg_ = sg;
        else
            sg_ = sg;
        end
        %rate = @(t) lambda_rate_motifs(t,lam_,mu_spike,sig_spike);
        rate = @(t) lambda_rate(t,lam_);
        [spiketimes{j}, ~, timeMoves]  = get_next_spikes(spiketimes_{j}(:)',(A_*(G\s_{j}(:)))',Ym(sl(j)+1:sl(j+1))',ge',tau,sg_^2, rate, 20*Dt, Dt, A_);
        TM = TM + timeMoves;
        spiketimes{j} = spiketimes{j}';
        spiketimes_{j} = spiketimes{j};
        spiketimes{j}(spiketimes{j}<0) = -spiketimes{j}(spiketimes{j}<0);
        spiketimes{j}(spiketimes{j}>dsl(j)*Dt) = 2*dsl(j)*Dt - spiketimes{j}(spiketimes{j}>dsl(j)*Dt); 
        trunc_spikes = ceil(spiketimes{j}/Dt);
        trunc_spikes(trunc_spikes == 0) = 1;
        s_{j} = sparse(1,trunc_spikes,exp((spiketimes{j} - Dt*trunc_spikes)/tau),1,dsl(j))';
        ss{i,j} = spiketimes{j};
        nsp = nsp + length(spiketimes{j});
        ns(i,j) = length(spiketimes{j});
        Gs_(sl(j)+1:sl(j+1)) = G\s_{j}(:);
    end
    lam(i) = nsp/(T*Dt);
    lam_ = lam(i);
    %spks = cell2mat(spiketimes_);
    %lam_ = nsp;
    %mu_spike = mean(spks);
    %sig_spike = 0.15;std(spks);
    %lam(i,:) = [lam_,mu_spike,sig_spike];
    
    AM = [Gs_,BC_mat];
    L = inv(Ld + AM'*AM/sg^2);
    mu_post = (Ld + AM'*AM/sg^2)\(AM'*Y/sg^2 + Sp\mu);
    if ~marg_flag
        x_in = [A_;b_;C_in];
        if any(x_in < lb)
            x_in = max(x_in,1.1*lb);
        end
        [temp,~] = HMC_exact2(eye(2*ldsl+1), -lb, L, mu_post, 1, Ns, x_in);
        Am(i) = temp(1,Ns);
        Cb(i,:) = temp(2:ldsl+1,Ns)';
        Cin(i,:) = temp(ldsl+2:end,Ns)';
        A_ = Am(i);
        b_ = Cb(i,:)';
        C_in = Cin(i,:)';

        Ym   = Y - BC_mat*[b_;C_in];
        res   = Ym - A_*Gs_;
        sg   = 1./sqrt(gamrnd(1+T/2,1/(0.1 + sum((res.^2)/2))));
        SG(i) = sg;
    else
        repeat = 1;
        while repeat
            A_ = mu_post(1) + sqrt(L(1,1))*randn;
            repeat = (A_<0);
        end                
        Am(i) = A_;
        if i > B
           mub = mub + mu_post(2:end);
           Sigb = Sigb + L(2:end,2:end);
        end
    end
    if gam_flag
        if (i > 0*B) && mod(i-0*B,gam_step) == 0  % update gamma
            fprintf('updating time constant.. ')
            ss_ = zeros(1,T);
            for rep = i-gam_step+1:i
                trunc_spikes = ceil(ss{rep}/Dt);            
                ss_ = ss_ + Am(rep)*sparse(1,trunc_spikes,exp((ss{rep} - Dt*trunc_spikes)/tau),1,T);
            end
            ss_ = ss_/gam_step;        
            if ~marg_flag
                y_res = Y - mean(Cb(i-gam_step+1:i));
                ss_(1) = ss_(1) + mean(Cin(i-gam_step+1:i));
            else
                y_res = Y - mub(1)/(i-B);
                ss_(1) = ss_(1) + mub(2)/(i-B);
            end
        
            min_g = @(gam) min_gamma_motifs(gam,ss_(:),y_res(:),P);
            g_new = fmincon(min_g,g,[],[],[],[],0,1,[],options);
            fprintf('new value %1.5f \n',g_new);
            g = g_new;
            P.g = g;
            G = spdiags([-g*ones(T,1),ones(T,1)],[-1,0],T,T);
            if isfield(P,'sl');
                sl = [0;P.sl];
                dsl = diff(sl);
                for jj = 1:length(P.sl)-1
                    G(P.sl(jj)+1,P.sl(jj))=0;
                end
            else
                sl = [0,T];
                dsl = T;
            end
            ge = P.g.^((0:T-1)'); 
            ge(ge<prec) = 0;
            tau = -Dt/log(g);
        end
    end
    if mod(i,100)==0
        fprintf('%i out of total %i samples drawn \n', i, N);
    end    
end
if marg_flag
    mub = mub/(N-B);
    Sigb = Sigb/(N-B)^2;
end
if marg_flag
    SAMPLES.Cb = [mub(1:ldsl),sqrt(diag(Sigb(1:ldsl,1:ldsl)))];
    SAMPLES.Cin = [mub(ldsl+1:end),sqrt(diag(Sigb(ldsl+1:end,ldsl+1:end)))];
else
    SAMPLES.Cb = Cb(B+1:N,:);
    SAMPLES.Cin = Cin(B+1:N,:);
    SAMPLES.sn2 = SG(B+1:N).^2;
end
SAMPLES.ns = ns(B+1:N,:);
SAMPLES.ss = ss(B+1:N,:);
SAMPLES.ld = lam(B+1:N,:);
SAMPLES.Am = Am(B+1:N);
if gam_flag
    SAMPLES.g = Gam(B+1:N);
end