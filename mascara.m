function [stack_all, stack_binary_mask]= mascara(stack_all,Th,pn)

if nargin<3
    pn=true;
end

stack_mask = entre0y1(squeeze(mean(stack_all)));
P=size(stack_all,1);

if nargin==1, Th = graythresh(stack_mask(:,:)); end
if pn, stack_binary_mask= stack_mask<=Th;
else stack_binary_mask= stack_mask>=Th; 
end

for i=1:P
    stack=squeeze(stack_all(i,:,:,:));
    stack(stack_binary_mask)=0;
    
    stack_all(i,:,:,:)=stack(:,:,:);
end

end

