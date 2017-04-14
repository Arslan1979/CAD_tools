function stack_plot(stack,dim)


if nargin<2
dim=1;
end
stack=squeeze(stack);


if numel(size(stack))<4    
    if dim==2
        stack=permute(stack,[3 2 1]);
    elseif dim==3
        stack=permute(stack,[2 1 3]);
    end
    I(:,:,1,:)=stack/max(stack(:));
    montage(I);
else
    if dim==1
        I(:,:,1,:)=permute(squeeze(stack(:,floor(size(stack,2)/2),:,:)/max(stack(:))),[2 3 1]);
    elseif dim==2
        I(:,:,1,:)=permute(squeeze(stack(:,:,floor(size(stack,3)/2),:)/max(stack(:))),[2 3 1]);
    elseif dim==3
        I(:,:,1,:)=permute(squeeze(stack(:,:,:,floor(size(stack,4)/2))/max(stack(:))),[2 3 1]);
    end
    
    montage(I);    
end
    colormap('default')

end
    
  