function [stack_alln, stack_binary_mask]= mascara_adjust(stack_all,Th,pn)

if nargin<3
    pn=true;
end

stack_mask = entre0y1(squeeze(mean(stack_all)));
[P s1 s2 s3]=size(stack_all);

if nargin==1, Th = graythresh(stack_mask(:,:)); end
if pn, stack_binary_mask= stack_mask<Th;
else stack_binary_mask= stack_mask>Th; 
end
% para reducir el tamaño de las imagenes en los bordes que son cero

lossis=regionprops(~stack_binary_mask);
comy=floor(lossis.BoundingBox(1));comx=floor(lossis.BoundingBox(2));comz=floor(lossis.BoundingBox(3));
finy=min(floor(lossis.BoundingBox(4))+comy,s2);finx=min(floor(lossis.BoundingBox(5))+comx,s1);finz=min(floor(lossis.BoundingBox(6))+comz,s3);
stack_alln=zeros([size(stack_all,1) numel(comx:finx) numel(comy:finy) numel(comz:finz)]);
plan=estirar(stack_mask,1);

for i=1:P
    stack=squeeze(stack_all(i,:,:,:));
    img=estirar(stack,1);
    l=xcorr2(plan,img);[a b]=find(l==max(l(:)));
    imgc=circshift(img,[a-s1*s2 b-s2]);
    stackr=reapilar(imgc,s1,s2);
    stackr(stack_binary_mask)=0;
    stack_alln(i,:,:,:)=stackr(comx:finx,comy:finy,comz:finz);
    fprintf(['completed ' num2str(i) ' \n'])
end

end

