function z= rbf_kernel(x,y,gamma)

z= exp(-gamma*dot_kernel(x-y,x-y));