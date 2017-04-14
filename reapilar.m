function [stack]=reapilar(img, size1,size2)

stack=zeros([size1 size2 size(img,2)]);
for j=1:size1
    innt(:,:)=img(1+(j-1)*size2:j*size2,:);
    stack(j,:,:)=innt;
end