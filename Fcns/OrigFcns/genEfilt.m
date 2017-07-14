function ef=genEfilt(tau,T)
% compute exponential filter(s)
%random stuff?
% D = 1;
% p1 = exp(D*-1/tau(1));
% p2 = exp(D*-1/tau(2));
% gamma_1 = p1+p2;
% gamma_2 = -p1*p2;

%% old way
% h = exp(-(1:T)/tau(2)) - exp(-(1:T)/tau(1));
% 
% e_mult = 1;
% flength = 1000;
% ef_d = exp(-(0:flength)/tau(2))/h(1);
% e_support = find(abs(ef_d)<1e-3,1);
% ef_d = e_mult*ef_d(1:e_support);
% 
% ef_h = -exp(-(0:flength)/tau(1))/h(1);
% e_support = find(abs(ef_h)<1e-3,1);
% ef_h = e_mult*ef_h(1:e_support);
% ef = {ef_h/max(abs(ef_h)) ef_d/max(abs(ef_d))};


%% new way
% h = exp(-(0:T)/tau(2)) - exp(-(0:T)/tau(1));

ef_d = exp(-(0:T)/tau(2));

ef_h = -exp(-(0:T)/tau(1));

% ef = {ef_h/max(h) ef_d/max(h)};
ef = {ef_h ef_d};

