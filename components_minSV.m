function [res]=components_minSV(stack_all,tr_labels,hsize,jump,comp_siz,stack_allcompl)

Tama=size(stack_all);
if nargin>6, tama2=size(stack_allcompl); P=Tama(1)+tama2(1); else P=Tama(1); end
labels=(tr_labels>0);
lista=listar(stack_all,jump,comp_siz);
numOfcomp=size(lista,2);fprintf .


if hsize==0;
    indices=(1:P)';
    nfolds=P;
else
    indices = crossvalind('Kfold',P,hsize);
    nfolds=hsize; fprintf .
end

fprintf('Empezando con el grupo ')

for p=1:nfolds
    test = (indices == p); train = ~test;
    for i=1:numOfcomp
        fprintf([ 'Calculando la precision de la componente ' num2str(i) '/' num2str(numOfcomp) ]);
        try
            if nargin>6
                component_part1=stack_all(:,lista{i});
                component_part2=stack_allcompl(:,lista{i});
                component=[component_part1;component_part2];
                stack_train=component(train,:);
            else
                stack_train=stack_all(train,lista{i});
            end
            train_values(p,i)=component_minSVs(stack_train,labels(train));
        catch
            continue
        end
        fprintf('completado! \n')
    end
    
end
[res]=minSV_aggregation(train_values,labels,indices,lista,stack_all);
end



function [lista]=listar(stack_all,jump,comp_size)

[~,masky]=mascara(stack_all);
Tama=size(stack_all);fprintf .
Z=Tama(2);Y=Tama(3);X=Tama(4);
grid= zeros(Z,Y,X);
for xx=1:jump:X
    for yy=1:jump:Y
        for zz=1:jump:Z
            grid(zz,yy,xx)= 1;
        end
    end
end


lista_ind=find(grid);
ccomp=intersect(lista_ind,find(~masky));
lista=cell(1);

for r=1:numel(ccomp)
    [z y x]=ind2sub([Z Y X],ccomp(r));
    
    listap=[];
    for m=1:comp_size
        for n=1:comp_size
            listap=[listap z+(y-2+n)*Z+(x-2+m)*Z*Y:z+(y-2+n)*Z+(x-2+m)*Z*Y+comp_size-1]; % min(,Z*Y*X)];
        end
    end
    lista{r}=listap;
end



end




function [values]=component_minSVs(tr_data,tr_labels)
kernels= { 'linear' }; %'rbf' 'polynomial' 'quadratic'  };
P=size(tr_data,1);
NK=numel(kernels);
values=struct('nSv',cell(1,NK),'trad',cell(1,NK));

        for kernel= 1:NK
            %
            
            options=optimset('MaxIter',1000);
            svmStruct = svmtrain(double(tr_data), tr_labels,'Kernel_Function',char(kernels(kernel)),'method','QP','options',options);
            numofSV=numel(svmStruct.SupportVectorIndices);
            values(kernel).trad=svmStruct; fprintf .
            values(kernel).nSv=numofSV;          
            fprintf('completado! \n')
        end
       
end

function [cp]=minSV_aggregation(train_values,labels,indices,lista,stack_all)
s=struct2cell(train_values);
sval=squeeze(cell2mat(s(1,:,:)));
%max_nsv=max(sval);
max_nsv=floor(mean(sval));
minnSv=min(max_nsv);
numSv=(sum(indices~=1)-minnSv);
xval=size(sval,1);
for k=1:numSv+1
    cp(k)=classperf(labels);
    lista2=find(max_nsv<=(minnSv+k-1));
    for p=1:xval
        test = (indices == p); train = ~test;       
        for j=1:numel(lista2)
            nd(:,j)=eval_svmStruct(train_values(p,lista2(j)).trad,stack_all(train,lista{lista2(j) }));
        end
        svmStruct2 = svmtrain(double(nd),labels(train),'Kernel_Function','linear','method','QP');
        for j=1:numel(lista2)
            ndt(:,j)=eval_svmStruct(train_values(p,lista2(j)).trad,stack_all(test,lista{lista2(j) }));
        end
        classes=svmclassify(svmStruct2,double(ndt));
        classperf(cp(k), classes,test);fprintf .
        clear nd*
    end
end
end


