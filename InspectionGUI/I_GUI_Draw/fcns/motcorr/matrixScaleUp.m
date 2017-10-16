function M = matrixScaleUp(M,scaleUp)
% replicate entries in a matrix
% M - the matrix
% scaleUp - the number of times to replicate each entry along each dimension

assert(all(scaleUp==round(scaleUp)))

for ss=1:length(scaleUp)
    if scaleUp(ss) > 1
        M = scaleUpOneDim(M,scaleUp(ss),ss);
    end
end



function M = scaleUpOneDim(M,ds,dim)

mSize = size(M);

otherDims = [1:dim-1 dim+1:length(mSize)];

% put the dimension to be scaled last
M = permute(M,[otherDims dim]);

% reshape
M = reshape(M,[],mSize(dim));

% replicate last dimension
M = repmat(M,[ds 1]);

% reshape
M = reshape(M,[mSize(otherDims) mSize(dim)*ds]);

% permute to original dimension order
M = permute(M,[1:dim-1 length(mSize) dim:length(mSize)-1]);



