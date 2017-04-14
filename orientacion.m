function [ori_vect,imgs_o]=orientacion(imgs)

%Calcula la orientacion de la imagen img de tamaño XxYxZ.
%devuelve un vector de 3 componentes con valores comprendidos entre -3 y 3
%y la imagen orientada correctamente, de forma que:
% >>I(:,:,1,:)=imgs_o;
% >>montage(I,'DisplayRange',[min(I(:)),max(I(:))]);
% dibuja el montaje correctamente.

[~,~,Z]=size(imgs);
posdim=[1 2 3];
img=normalize_intensity(imgs);


for i=1:Z
    level=graythresh(img(:,:));
    if level==0;
        level=0.1;
    end
    imint=im2bw(img(:,:,i),level);
    se = strel('disk',1);
    imintop=imopen(imint,se);
    BW(:,:,i)=imfill(squeeze(imintop),'holes');
    
end

cc=bwconncomp(BW);
stats=regionprops(cc);
[~,rg]=max([stats.Area]);
reCentroid(1)=stats(rg).Centroid(1);
reCentroid(2)=stats(rg).Centroid(2);
reCentroid(3)=stats(rg).Centroid(3);
reBoundingBox(1)=stats(rg).BoundingBox(1);
reBoundingBox(2)=stats(rg).BoundingBox(2);
reBoundingBox(3)=stats(rg).BoundingBox(3);
reBoundingBox(4)=stats(rg).BoundingBox(4);
reBoundingBox(5)=stats(rg).BoundingBox(5);
reBoundingBox(6)=stats(rg).BoundingBox(6);
[~,x]=max(reBoundingBox);
dim2=(x-3==posdim);
for j=1:3
    cercanias(j)=2*(reBoundingBox(j+3)-reCentroid(j)+reBoundingBox(j))/reBoundingBox(j+3)-1;
end
[~,y]=min(abs(cercanias));
dim1=(y==posdim);
if dim1==dim2
    [~,yint]=sort(abs(cercanias));
    y=yint(2);
    dim1=(y==posdim);
end
dim3=~or(dim1,dim2);

ori_vect(1)=posdim(dim1);
ori_vect(2)=posdim(dim2);
ori_vect(3)=posdim(dim3);

if cercanias(dim2)>0
    ori_vect(2)=-posdim(dim2);
end
if cercanias(dim3)<0
    ori_vect(3)=-posdim(dim3);
end

imgs_op=imgs;
while any(ori_vect~=posdim)
    while ori_vect(1)~=1
        if ori_vect(1)==-1
            d3=find(abs(ori_vect)==3);
            imgs_op=rotar(imgs_op,d3,2);
            ori_vect=[-ori_vect(1) ori_vect(2) ori_vect(3)];
        elseif abs(ori_vect(1))==3
            d2=find(abs(ori_vect)==2);
            imgs_op=rotar(imgs_op,d2,1);
            if d2==2, ori_vect=[-ori_vect(3) ori_vect(2) ori_vect(1)];
            else ori_vect=[-ori_vect(2) ori_vect(1) ori_vect(3)] ;
            end
        elseif abs(ori_vect(1))==2
            d3=find(abs(ori_vect)==3);
            imgs_op=rotar(imgs_op,d3,1);
            if d3==2, ori_vect=[-ori_vect(3) ori_vect(2) ori_vect(1)] ;
            else ori_vect=[-ori_vect(2) ori_vect(1) ori_vect(3)] ;
            end
        end
    end
    while ori_vect(3)~=3
        if ori_vect(3)==-3
            imgs_op=rotar(imgs_op,1,1);
            imgs_op=rotar(imgs_op,1,1);
            ori_vect=[ori_vect(1) ori_vect(2) -ori_vect(3)];
        elseif abs(ori_vect(3))==2
            imgs_op=rotar(imgs_op,1,1);
            ori_vect=[ori_vect(1) -ori_vect(3) ori_vect(2)];
        end
    end
    if ori_vect(2)==-2
        imgs_op=rotar(imgs_op,3,3);
        ori_vect=[ori_vect(1) -ori_vect(2) ori_vect(3)];
    end
end
imgs_o=imgs_op;
end

function [img_nor]=normalize_intensity(stack)
pbin=10;
th=0.001;
mini=min(stack(:));
stack(isnan(stack))=0;
%     if mini<0
desp=0-mini;
stack=stack+desp;
%     end
[j,k]=hist(stack(:),50);fprintf('.')

% Coge los bins a partir del 10, porque normalmente los primeros bins acumulan muchisima informaci�n irrelevante de fuera del cerebro, y
% calcula su valor acumulado
for M=pbin:50
    su(M-9)=sum(j(M:50));
end
fprintf('.')
% Obtiene el bin a partir del cual se registran intensidades mayores al 0.1% del valor acumulado anterior
max_i=k(max(find(su>(su(1)*th)))+9);fprintf('.')
% Se normaliza toda la imagen a 1-0 con este valor
stack=stack./max_i;fprintf('.')

stack(stack>1)=1;fprintf('.')
stack(stack<0.001)=0;fprintf('.')
fprintf('intensity normalized \n')
img_nor=stack;
end

function [stack2]=rotar(stack,dim,k)
for i=1:size(stack,dim)
    if k==1
        if dim==1, stack2 (i,:,:) = rot90 (squeeze(stack (i,:,:)));
        elseif dim==2, stack2 (:,i,:) = rot90 (squeeze(stack (:,i,:)));
        else stack2 (:,:,i) = rot90 (squeeze(stack (:,:,i)));
        end
    elseif k==2
        if dim==1, stack2 (i,:,:) = fliplr (squeeze(stack (i,:,:)));
        elseif dim==2, stack2 (:,i,:) = fliplr (squeeze(stack (:,i,:)));
        else stack2 (:,:,i) = fliplr (squeeze(stack (:,:,i)));
        end
    elseif k==3
        if dim==1, stack2 (i,:,:) = flipud (squeeze(stack (i,:,:)));
        elseif dim==2, stack2 (:,i,:) = flipud (squeeze(stack (:,i,:)));
        else stack2 (:,:,i) = flipud (squeeze(stack (:,:,i)));
        end
    end
end

end
