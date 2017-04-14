function [img]=estirar(stack, dim)

img=[];
for j=1:size(stack,dim)
    if dim==1
        A=squeeze(stack(j,:,:));
    elseif dim==2
        A=squeeze(stack(:,j,:));
    elseif dim==3
        A=squeeze(stack(:,:,j));
    else
        return
    end
    img=[img; A];
end