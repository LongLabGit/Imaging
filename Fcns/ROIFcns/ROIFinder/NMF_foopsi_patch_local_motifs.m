function [A,C,b,f] = NMF_foopsi_patch_local_motifs(Y,nr,P,Coor,varargin)

[d,T] = size(Y);
mc = min(d,30);
if nargin < 3  || isempty(P) % check if model parameters are given, else estimate them
    P = arpfit(Y,1);
    ind = find(abs(imag(P.sn)>0));
    if ~isempty(ind);
        ind2 = setdiff(1:d,ind);
        P.sn(ind) = mean(P.sn(ind2));
        P.Cb(ind) = mean(P.Cb(ind2));
        P.Ald(ind) = mean(P.Ald(ind2));
    end
end
G = spdiags(ones(T,1)*[-P.g(end:-1:1)',1],[-length(P.g):0],T,T); %foopsi_matrix(T,P.g);
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
P.b = P.Cb;
Y_mean = zeros(d,ldsl);
for i = 1:ldsl
    Y_mean(:,i) = mean(Y(:,sl(i)+1:sl(i+1)),2);
end
Y_mean = max(Y_mean*spdiags(sqrt(dsl),0,ldsl,ldsl),0);
%savefile = 'concatenated/Y_mean.mat';
%save(savefile,'Y_mean');
%% initialization (check if initializer exists)

if nargin < 4
    dist = Inf;
else
    dist = Coor.dist;
end

if nargin < 5
    P.NN = 0.015;
    C_rec = spatial_foopsi(Y,P,'NN');
    %C_rec = Y;
    qn = 0.9;
    size_Z = size(C_rec,1);
    Z_temp = C_rec*G';
    Z_temp = Z_temp(:,2:end);
    for num_p = 1:size_Z
        thq = quantile(Z_temp(num_p,:),qn);
        Z_temp(num_p,:) = Z_temp(num_p,:).*(Z_temp(num_p,:)>thq);
    end
    [~,cnc] = kmeans_pp(Z_temp,nr+1);
    A = cnc;
    [~,id] = min(sum(A));
    A(:,id) = [];
    A = abs(A)+1e-5;
    mA = max(A,[],1);
    A = A/spdiags(mA',0,nr,nr);
    P.ln = 10*ones(nr,1);
    
    % initialize with greedy method
    %[~,ind] = sort(sum(A),'descend');
    Y_res = Y - P.Cb*ones(1,T);
    Fin = 1e-4*ones(nr,T);
    [F,LD] = temporal_cd_foopsi(Y_res,A,Fin,G,P,5);
%     F = zeros(nr,T);
%     for i = 1:nr
%         ii = ind(i);
%         [~,srt] = sort(A(:,ii),'descend');
%         ff = srt(1:mc);
%         [cc,~] = lagrangian_foopsi_temporal(Y_res(ff,:),A(ff,ii),T*P.sn(ff).^2,G);
%         F(ii,:) = cc';
%         Y_res = Y_res - A(:,ii)*F(ii,:);
%     end
%     perm = randperm(nr);
%     Y_res = Y - A*F;
%     for jj = 1:nr
%         ii = perm(jj);
%         Y_res = Y_res + A(:,ii)*F(ii,:);
%         [~,srt] = sort(A(:,ii),'descend');
%         ff = srt(1:mc);
%         [cc,~] = lagrangian_foopsi_temporal(Y_res(ff,:),A(ff,ii),T*P.sn(ff).^2,G);
%         if jj < nr
%             Y_res = Y_res - A(:,ii)*cc';
%         end
%         F(ii,:) = cc';
%     end
elseif size(varargin{1},1) == d && size(varargin{1},2) == nr
    A = varargin{1};
    Fin = spdiags(sum(A.^2,1)',0,nr,nr)\(A'*Y);
    Y_res = Y - P.Cb*ones(1,T);
    [F,LD] = temporal_cd_foopsi(Y_res,A,Fin,G,P,2);
    
elseif size(varargin{1},1) == nr && size(varargin{1},2) == T
    F = varargin{1};
    sp = F*G';
    if min(sp(:)) < 0
        error('Temporal initializer does not satisfy foopsi conditions');
    end
else
    error('Initializer does not have the right dimensions');
end

if nargin >= 6
    A = varargin{2};
end

F = full(F);
%% run full NMF
REP = 1;
A = [A,ones(d,length(dsl))];
C_bas = spalloc(length(dsl),T,T);
for i = 1:length(dsl)
    C_bas(i,sl(i)+1:sl(i+1)) = 1/sqrt(dsl(i));
end
C = [F;P.neuropil];
nC = sqrt(sum(C.^2,2));
C = spdiags(nC,0,nr+ldsl,nr+ldsl)\C;

%% run global NMF
fprintf('Starting matrix factorization proceduce.. \n')
d1 = P.d1;
d2 = P.d2;
for rep = 1:REP
    fprintf('Iter %i \n',rep);
    if ~(dist==Inf)       % determine search area for each neuron
	   cm = zeros(nr,2);  % vector for center of mass
	   Vr = cell(nr,1);
	   IND = zeros(d,nr); % indicator for distance								   
        cm(:,1) = Coor.x'*A(:,1:nr)./sum(A(:,1:nr));
        cm(:,2) = Coor.y'*A(:,1:nr)./sum(A(:,1:nr));
        for i = 1:nr
            Vr{i} = ([Coor.x - cm(i,1), Coor.y - cm(i,2)]'*spdiags(A(:,i),0,d,d)*[Coor.x - cm(i,1), Coor.y - cm(i,2)])/sum(A(:,i));
            [V,D] = eig(Vr{i});
            cor = [Coor.x - cm(i,1),Coor.y - cm(i,2)];
            d11 = min(8^2,max(3^2,D(1,1)));
            d22 = min(8^2,max(3^2,D(2,2)));
            IND(:,i) = sqrt((cor*V(:,1)).^2/d11 + (cor*V(:,2)).^2/d22)<=dist;
        end
    end

    ld = 1e8*ones(d,1);
    A = [zeros(d,nr),Y_mean];
    for px = 1:d   % estimate spatial components
        if dist == Inf
            [~, ~, a, ~] = lars_regression_noise(Y(px,:)', C', 1, P.sn(px)^2*T);
            A(px,:) = a';
        else
            ind = find(IND(px,:));
            if ~isempty(ind);
                ind2 = [ind,nr+(1:ldsl)];
                [~, ~, a, ld(px)] = lars_regression_noise(Y(px,:)', C(ind2,:)', 1, P.sn(px)^2*T);
                A(px,ind2) = a';
            end
        end
        if mod(px,1e4) == 0;
            fprintf('%i done \n',px);
        end
    end
    
    for i = 1:nr   % perform median filtering on extracted components
 	    I_temp = medfilt2(reshape(A(:,i),d1,d2),[3,3]);
        acp = intersect(find(I_temp(:)),find(A(:,i)));
	    A(:,i) = sparse(acp,1,A(acp,i),d,1); %I_temp(:);
	end
    A = sparse(A);
    
    Ath = A;       % perform thresholding on extracted components 
    for i = 1:nr
        Ath(Ath(:,i)<0.2*max(Ath(:,i)),i) = 0;
        BW = bwlabel(full(reshape(Ath(:,i),d1,d2)));
        ml = max(BW(:));
        ln = zeros(ml,1);
        for j = 1:ml
            ln(j) = length(find(BW==j));
        end
        [~,ind] = max(ln);
        Ath(BW(:)~=ind,i) = 0;
    end
    A = Ath;
    
    fprintf('Updated spatial components \n');
    
    ff = find(sum(A)==0);
    if ~isempty(ff)
        nr = nr - length(ff);
        A(:,ff) = [];
        C(ff,:) = [];
    end
    
    if rep > 1   % update spatial component
        Y_res = Y - A(:,1:nr)*C(1:nr,:);
        A_bas = max(Y_res*C(end,:)'/norm(C(end,:))^2,0);
        A(:,end) = A_bas;
    end
    
    %savefile = ['A_spatial_',mat2str(rep),'.mat'];
	%save(savefile,'A');
    
    % update temporal components
    [F,Y_res,~] = temporal_cd_foopsi(Y-A(:,nr+1:end)*C(nr+1:end,:),A(:,1:nr),C(1:nr,:),G,P,2);
    Y_res = Y_res + A(:,end)*C(end,:);
    C_res = A(:,end)'*Y_res/norm(A(:,end))^2;
    Y_res = Y_res - A(:,end)*C_res;
    %[F2,Y_res2,~] = temporal_cd_sampling(Y-A(:,nr+1:end)*C(nr+1:end,:),A(:,1:nr),C(1:nr,:),G,P);
    C = [F;C_res];
    fprintf('Updated temporal components \n');
    %%
    %savefile = ['C_temporal_',mat2str(rep),'.mat'];
	%save(savefile,'C');
                                       
    % merge overlapping ROIs
    
    [A2,C2,nr2,~] = merge_ROIs_cliques(Y_res,A(:,1:nr),C(1:nr,:),P,G,nr,0.8);
    if nr2 ~= nr
        A = [A2,A(:,end)];
        C = [C2;C_res];
        nr = nr2;
    end
end

C = C(1:nr,:);          % temporal components
f = C(end,:);           % time varying background
b = A(:,nr+(1:ldsl));   % background activity
A = A(:,1:nr);          % spatial components