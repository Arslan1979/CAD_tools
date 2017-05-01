function [y,x,reduced_mask]=create_ROImask(imgnii, xmlfile, imgcoarse)

stacki2=double(imgnii.img);

[x, masdeunaroi]=extract_ROI('.',xmlfile);
fprintf 'Point coordinates extracted\n'

y=zeros(size(stacki2));
list=find(x(1,1,:));

if masdeunaroi
    fprintf('CUIDAO, hay mas de una roi!')
end

for i=list(1):list(end)
    [N M]=size(squeeze(y(i,:,:)));
    mask=points2bw( x(x(:,1,i)>0,:,i),N,M);
    y(i,:,:)=mask;
end
% if you want to have it like the nii (not the dicom)
y=flipdim(permute(y,[2 1 3]),2);


reduced_mask=resize_delineatedcontour(imgnii,imgcoarse,y);

fprintf('completed!\n')
end

% cd(dire)
% dcmi=dir('IM-0001*.dcm');
% if isempty(dcmi), bajauno=1; cd('DICOM'); dcmi=dir('IM-0001*.dcm');end
% for i=1:numel(dcmi)
% a=dicomread(dcmi(i).name);
% stacki2(:,:,i)=a;
% end
% cd ..

