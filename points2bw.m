function mask=points2bw(x,N,M)

% This function covert a series of n points defining a closed region in a NxM sized image into a
% binary mask. The input x must be a n times 2 vector, with x(i,1) the x
% coordinate of the point i and x(i,2) the y coordinate. The coordinates
% MUST define CLOSED regions

npoints=size(x,1);

% Zoom factor
f=10;

tube=zeros(f*N,f*M);
for j=1:npoints-1
[newx newy]=bresenham(f*x(j,1),f*x(j,2),f*x(j+1,1),f*x(j+1,2));
for k=1:numel(newx), tube(newx(k),newy(k))=1; end
fprintf .
end
region=imfill(tube,'holes');
[xi,zi]=meshgrid(1:M,1:N);
mask=interp2(1/f:1/f:N,1/f:1/f:M,region',zi,xi,'cubic');
end

function [x y]=bresenham(x1,y1,x2,y2)

%Matlab optmized version of Bresenham line algorithm. No loops.
%Format:
%               [x y]=bham(x1,y1,x2,y2)
%
%Input:
%               (x1,y1): Start position
%               (x2,y2): End position
%
%Output:
%               x y: the line coordinates from (x1,y1) to (x2,y2)
%
%Usage example:
%               [x y]=bham(1,1, 10,-5);
%               plot(x,y,'or');
x1=round(x1); x2=round(x2);
y1=round(y1); y2=round(y2);
dx=abs(x2-x1);
dy=abs(y2-y1);
steep=abs(dy)>abs(dx);
if steep t=dx;dx=dy;dy=t; end

%The main algorithm goes here.
if dy==0 
    q=zeros(dx+1,1);
else
    q=[0;diff(mod([floor(dx/2):-dy:-dy*dx+floor(dx/2)]',dx))>=0];
end

%and ends here.

if steep
    if y1<=y2 y=[y1:y2]'; else y=[y1:-1:y2]'; end
    if x1<=x2 x=x1+cumsum(q);else x=x1-cumsum(q); end
else
    if x1<=x2 x=[x1:x2]'; else x=[x1:-1:x2]'; end
    if y1<=y2 y=y1+cumsum(q);else y=y1-cumsum(q); end
end
end