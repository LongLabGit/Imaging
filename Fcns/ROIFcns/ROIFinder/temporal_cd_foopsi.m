function [F,Y_res,LD] = temporal_cd_foopsi(Y,A,Fin,G,P,ITER,LD)

if nargin < 6
    ITER = 1;
end
[d,T] = size(Y);

nr = size(A,2);
Y_res = Y - A*Fin;
mc = min(d,50);  % number of constraints to be considered
F = zeros(nr,T);

if nargin < 7
    LD = 10*ones(mc,nr);
    if isempty(ITER)
        ITER = 1;
    end
end

for iter = 1:ITER
    perm = randperm(nr);
    for jj = 1:nr
        ii = perm(jj);
        %ii
        Y_res = Y_res + A(:,ii)*Fin(ii,:);
        [~,srt] = sort(A(:,ii),'descend');
        ff = srt(1:mc);
        [cc,LD(:,ii)] = lagrangian_foopsi_temporal(Y_res(ff,:),A(ff,ii),T*P.sn(ff).^2,G,LD(:,ii)/2);
        %[cc,~] = lagrangian_foopsi_temporal(Y_res(ff,:),A(ff,ii),T*P.sn(ff).^2,G,LD(:,ii));
        Y_res = Y_res - A(:,ii)*cc';
        F(ii,:) = full(cc');
        %ii
    end
    if norm(Fin(1:nr,:) - F,'fro')/norm(F,'fro') <= 1e-3
        % stop if the overall temporal component does not change by much
        break;
    else
        Fin = F;
    end
end