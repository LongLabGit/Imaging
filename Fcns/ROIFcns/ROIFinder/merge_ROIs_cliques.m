function [A,C,nr,merged_ROIs] = merge_ROIs_cliques(Y_res,A,C,P,G,nr,thr,mx)

if nargin < 7
    thr = 0.85;     % threshold for temporal correlation
end

if nargin < 8
    mx = 10;        % maximum merging operations
end

[d,T] = size(Y_res);
C_corr = corr(full(C(1:nr,:)'));
FF1 = triu(C_corr)>= thr;

A_corr = triu(A(:,1:nr)'*A(:,1:nr));
A_corr(1:nr+1:nr^2) = 0;
FF2 = A_corr > 0;

FF3 = and(FF1,FF2);
MC = maximalCliques(double(FF3+FF3'));
MC = MC(:,sum(MC,1)>1);
cor = zeros(size(MC,2),1);
for i = 1:length(cor)
    fm = find(MC(:,i));
    for j1 = 1:length(fm)
        for j2 = j1+1:length(fm)
            cor(i) = cor(i) + C_corr(j1,j2);
        end
    end
end
[~,ind] = sort(cor,'descend');
nm = min(length(ind),mx);   % number of merging operations
merged_ROIs = cell(nm,1);
mc = 30;
A_merged = zeros(d,nm);
C_merged = zeros(nm,T);
for i = 1:nm
    merged_ROIs{i} = find(MC(:,ind(i)));
    nC = sqrt(sum(C(merged_ROIs{i},:).^2,2));
    A_merged(:,i) = sum(A(:,merged_ROIs{i})*spdiags(nC,0,length(nC),length(nC)),2);
    Y_res = Y_res + A(:,merged_ROIs{i})*C(merged_ROIs{i},:);
    [~,srt] = sort(A_merged(:,i),'descend');
    ff = srt(1:mc);
    [cc,~] = lagrangian_foopsi_temporal(Y_res(ff,:),A_merged(ff,i),T*P.sn(ff).^2,G);
    C_merged(i,:) = full(cc)';
    if i < nm
        Y_res = Y_res - A_merged(:,i)*full(cc');
    end
end

neur_id = unique(cell2mat(merged_ROIs));

A = [A(:,1:nr),A_merged,A(:,nr+1:end)];
C = [C(1:nr,:);C_merged;C(nr+1:end,:)];
A(:,neur_id) = [];
C(neur_id,:) = [];
nr = nr - length(neur_id) + nm;