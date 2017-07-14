function G = foopsi_matrix(T,g)
    lg = length(g);
    g2 = [1;-g(:)];
    G = spalloc(T-lg,T,(T-lg)*(lg+1));
    for i = 1:lg+1
        G = G + g2(i)*[sparse(T-lg,lg-i+1) speye(T-lg) sparse(T-lg,i-1)];
    end
    G = [sparse(1:lg,1:lg,sum(g2)*ones(lg,1),lg,T);G];
end