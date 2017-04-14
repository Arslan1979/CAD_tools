function [sintetic_data]=create_sin_data(data,num_sin)

% loadings y demixmatrix deben ser pxn, donde p es el número de sujetos y n
% 
P=size(data,1);fprintf .
media=mean(data);fprintf .

        for j=1:P
            data(j,:,:,:)=data(j,:,:,:)-media; 
        end
        [loadings,mixing_matrix]=fastica(data(:,:),'verbose','off');%);%

        disp('ica extraction concluded')

[p n]=size(loadings);
random_loadings=zeros(num_sin,n);
for i=1:num_sin
random_loadings(i,:)=( randn(n,1)'.*std(loadings) ) + mean( loadings );
end

sintetic_data=reshape(random_loadings*mixing_matrix*data(:,:)+repmat(media(:)',[num_sin 1]),[num_sin size(data,2) size(data,3) size(data,4)]);


end