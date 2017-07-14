function xhat = LSdist(D, W)
p = size(D, 1);
A = [];
b = [];
if ~exist('W', 'var')
  W = ones(size(D));
end

% some of the entries in weight matrix are NaN where offset is not NaN
W(isnan(W)) = 1.0;
%A reflects the pairs, the derivate across locations
%b reflects the distance between 
for i=1:p
  for j=i+1:p
      if ~isnan(D(i, j))
        a = zeros(1, p);
        a(i) = 1;        a(j) = -1;
        A = [A; a * W(i, j)];
        b = [b; -D(i, j) * W(i, j)];
      end
  end
end

% solve least squares problem for offsets
%distance=location*derivative
xhat = A \ b;

% Normalize so first plane is 0
xhat = xhat - xhat(1);

