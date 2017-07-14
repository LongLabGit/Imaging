function P = arpfit(Y,p,ph)

[d,T] = size(Y);

if nargin == 2
    fprintf('Estimating time constant through autocorrelation function.. \n');
    tt1 = tic;
    lags = 4;
    g = zeros(d,lags+p);

    for j = 1:d
        xx = xcov(Y(j,:),lags+p,'unbiased');
        g(j,:) = xx(lags+p:-1:1);
    end

    A = zeros(d*lags,p);
    for i = 1:d
        A((i-1)*lags + (1:lags),:) = toeplitz(g(i,p:p+lags-1),g(i,p:-1:1));
    end
    gv = g(:,p+1:end)';
    %ph = pinv(A)*gv(:);
    ph = A\gv(:);
    disp(ph);
    fprintf('Done after %2.2f seconds. \n',toc(tt1));
end
mg = sum(ph);

G = spdiags(ones(T,1)*[-ph(end:-1:1)',1],[-length(ph):0],T,T); %foopsi_matrix(T,P.g);
%G = foopsi_matrix(T,ph);

Sp = Y*G';
Sp = Sp(:,p+1:end);

% sn = zeros(d,1);
% for i = 1:d
%     xx = xcov(Sp(i,:),p,'biased');
%     sn(i) = mean(sqrt(-xx(p+2:end)'./ph(:)));
% end
% sn = sqrt(var(Sp,[],2)/(1+sum(ph.^2)));
sn = zeros(d,1);
for i = 1:d
    xx = xcov(Y(i,:)',p,'unbiased');
    s_est = zeros(p,1);
    for k = 1:p
        s_est(k) = (ph'*xx(p+1+k-(1:p)) - xx(p+1+k))/ph(k);
    end
    sn(i) = sqrt(mean(s_est));
end

G = foopsi_matrix(T,sum(ph));
Sp = Y*G';
Sp = Sp(:,2:end);
ft_ = fittype('poly1');
fo_ = fitoptions('method','LinearLeastSquares','Robust','Bisquare');

Cb_med = median(Sp,2)/(1-mg);
%Cb_med = mean(Sp,2)/(1-mg);
sn2 = sn;
cf_ = fit(sn2,Cb_med,ft_,fo_);

Cb_est = cf_.p1*sn2 + cf_.p2;
[idx,cn] = kmeans(Cb_med - Cb_est,2);
[~,id] = min(cn);
rl = find(idx==id);
cf2_ = fit(sn2(rl),Cb_med(rl),ft_,fo_);
Cb_est2 = cf2_.p1*sn2 + cf2_.p2;

Ald = (mean(Y,2) - Cb_est2)*(1-mg);
Ald = max(Ald,1e-3);
Cb = mean(Y,2) - Ald/(1-mg);
Cb = max(Cb,1e-3);    

P.sn = sn;
P.Ald = Ald;
P.Cb = Cb;
P.g = ph(:);

ind = find(abs(imag(P.sn)>0));
if ~isempty(ind);
    fprintf('Correcting complex number estimates. \n');
    ind2 = setdiff(1:d,ind);
    P.sn(ind) = mean(P.sn(ind2));
    P.Cb(ind) = mean(P.Cb(ind2));
    P.Ald(ind) = mean(P.Ald(ind2));
    fprintf('done. \n');
end