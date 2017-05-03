function [x0,x1]=create_labelleddata(stack_all,mask,mask2)

% set threshold for consider interesting data (many lie below the 0.001
% range
th=0.01;
x1=double(stack_all(:,mask>th));
x0=double(stack_all(:,and(mask2,lt(mask,th))));
%the last row will be the label row
 x1=[x1 ;mask(mask(:)>th)'];
end