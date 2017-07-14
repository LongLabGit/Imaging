function [f,grad] = min_gamma_motifs(g,s,y,P)

if isfield(P,'sl');
    sl = [0;P.sl];
    dsl = diff(sl);
else
    T = length(y);
    sl = [0,T];
    dsl = T;
end
ldsl = length(dsl);

prec = 1e-4;
f = 0;
grad = 0;

for i = 1:ldsl
    T = dsl(i);
    K = min(ceil(log(prec)/log(g)),T);
    vec_f = g.^(0:K-1);
    G_f = toeplitz(sparse(1:K,1,vec_f(:),T,1),sparse(1,1,1,1,T));
    vec_g = (0:K-1).*(g.^(-1:K-2));
    G_g = toeplitz(sparse(1:K,1,vec_g(:),T,1),sparse(1,T));

    f = 0.5*norm(y(sl(i)+1:sl(i+1))-G_f*s(sl(i)+1:sl(i+1)))^2;
    grad = grad - (y(sl(i)+1:sl(i+1))-G_f*s(sl(i)+1:sl(i+1)))'*(G_g*s(sl(i)+1:sl(i+1)));
end