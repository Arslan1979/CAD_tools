function [res] = components_g(stack_all,tr_labels,jump,comp_size,nfolds,hsize,Th,pname)


[stack_all]=mascara(stack_all,Th);
[P]=numel(tr_labels);
[train,test] = crossvalind('HoldOut',P,hsize);
masky=squeeze(mean(stack_all(:,:,:,:)))>0;
%pname = 'bayes';% 'svm';%
labels=(tr_labels>0);
res=struct('val',cell(1,1),'values',cell(1,1),'map',cell(1,1));
fprintf('Empezando con el grupo ')
tic
[val]=component_factorization(stack_all(train,:,:,:),labels(train),masky,jump,comp_size,nfolds,pname);
toc
tic
[values]=selection_validation(stack_all(test,:,:,:),labels(test),val,jump,pname);
%[values]=selection_validation_S(stack_all(test,:,:,:),labels(test),val,comp_size);
toc
tic
%[map]=precision_map_S(masky,values,val,comp_size);
[map]=precision_map(masky,values,comp_size,jump);
toc
res.val=val;
res.values=values;
res.map=map;
res.testset=test;
res.jump=jump;
res.component_size=comp_size;
end

function [values]=component_factorization(stack_train,tr_labels,masky,jump,comp_size,nfolds,pname)


[P Z Y X]=size(stack_train); fprintf .
values=struct('cp',cell([Z Y X]),'trad',cell([Z Y X]),'index',cell([Z Y X]));
comp_sizeX=comp_size;comp_sizeY=comp_size;comp_sizeZ=comp_size;



tr_data_square=zeros([Z Y X]);
tr_data_square(1:comp_sizeZ,1:comp_sizeY,1:comp_sizeX)=1; fprintf .
if comp_sizeX>=X, vx=X; else vx=1; end, fprintf .
if comp_sizeY>=Y, vy=Y; else vy=1; end, fprintf .
if comp_sizeZ>=Z, vz=Z; else vz=1; end, fprintf .
nuc(2)=0;
for cir3=1:jump:Z/vz
    for cir2=1:jump:Y/vy
        for cir1=1:jump:X/vx
            cir=[cir3-1 cir2-1 cir1-1];
            tr_data_sq=circshift(tr_data_square,cir);
            indexado=find(tr_data_sq(:)>0 & masky(:)>0);
            nuc(1)=size(1:jump:X/vx,2)*size(1:jump:Y/vy,2)*size(1:jump:Z/vz,2);
            nuc(2)=nuc(2)+1;
            if any(indexado)
                fprintf([ 'Calculando la precisi�n de la componente ' num2str(nuc(2)) '/' num2str(nuc(1)) ]);
                [cp]=component_accuracy(indexado,stack_train,tr_labels,nfolds,pname);
                
                values(cir3,cir2,cir1).trad=cp.trad;
                values(cir3,cir2,cir1).cp=cp.cp;
                if ~isempty(cp), values(cir3,cir2,cir1).index=indexado; end
                
            end
            
        end
    end
end

end
function [values]=component_factorization_speed(stack_train,tr_labels,masky,jump,comp_size,nfolds,Th)
[P Z Y X]=size(stack_train); fprintf .
values=struct('cp',cell([Z Y X]),'trad',cell([Z Y X]));
comp_sizeX=comp_size;comp_sizeY=comp_size;comp_sizeZ=comp_size;

grid= zeros(Z,Y,X);
for xx=comp_sizeX+1:jump:X
    for yy=comp_sizeY+1:jump:Y
        for zz=comp_sizeZ+1:jump:Z
            grid(zz,yy,xx)= 1;
        end
    end
end

I = find((masky.*grid==1));
[z,y,x]= ind2sub(size(masky),I);
NVoxels= length(I);
values(1,1,1).I=I;

for l=1:NVoxels
    fprintf([ 'Calculando la precision de la componente ' num2str(l) '/' num2str(NVoxels) ]);
    train_data=stack_train(:,z(l)-comp_sizeZ:z(l)+comp_sizeZ,y(l)-comp_sizeZ:y(l)+comp_sizeZ, x(l)-comp_sizeZ:x(l)+comp_sizeZ);
    [cp]=component_accuracy_S(train_data(:,:),tr_labels,nfolds);
    values(z(l),y(l),x(l)).trad=cp.trad;
    values(z(l),y(l),x(l)).cp=cp.cp;
    if cp.cp.CorrectRate>Th
        values(z(l),y(l),x(l)).index=1;
    end
    
end
end

function [values]=component_accuracy(indexado,traing,tr_labels,nfolds,pname)
kernels= { 'linear' }; %'rbf' 'polynomial' 'quadratic'  };
tr_data=traing(:,indexado);
P=size(tr_data,1);
NK=numel(kernels);
values=struct('cp',cell(1,NK),'trad',cell(1,NK));
okopts={'svm','bayes'};


%    pval = varargin{j+1};
cl = find(strncmpi(pname, okopts,numel(pname)));
switch cl
    case 1
        for kernel= 1:NK
            %
            cp=classperf(tr_labels); fprintf .
            if nfolds==0;
                indices=(1:P)';
                nfolds=P;
            else
                indices = crossvalind('Kfold',P,nfolds); fprintf .
            end
            
            for p=1:nfolds
                test = (indices == p); train = ~test;
                train_data=tr_data(train,:);
                test_data=tr_data(test,:);
                svmStruct = svmtrain(train_data, tr_labels(train),'Kernel_Function',char(kernels(kernel)));
                classes = svmclassify(svmStruct,test_data);
                classperf(cp, classes,test,'Positive', 1, 'Negative', 0);
                
                
                
            end
            values(kernel).cp=cp; fprintf .
            values(kernel).trad=svmStruct; fprintf .
            
            fprintf('completado! \n')
        end
    case 2
        cp=classperf(tr_labels); fprintf .
        if nfolds==0;
            indices=(1:P)';
            nfolds=P;
        else
            indices = crossvalind('Kfold',P,nfolds); fprintf .
        end

        for p=1:nfolds
            test = (indices == p); train = ~test;
            train_data=tr_data(train,:);
            tt_data=tr_data(test,:);
           
            nb = NaiveBayes.fit(train_data, tr_labels(train));
            class = predict(nb, tt_data);
            classperf(cp, double(class),test,'Positive', 1, 'Negative', 0);
            
        end

        values.cp=cp; fprintf .
        values.trad=nb; fprintf .
        fprintf('completado! \n')
end
end
function [values]=component_accuracy_S(tr_data,tr_labels,nfolds)
kernels= { 'linear' }; %'rbf' 'polynomial' 'quadratic'  };
P=size(tr_data,1);
NK=numel(kernels);
values=struct('cp',cell(1,NK),'trad',cell(1,NK));
for kernel= 1:NK
    %
    cp=classperf(tr_labels); fprintf .
    if nfolds==0;
        indices=(1:P)';
        nfolds=P;
    else
        indices = crossvalind('Kfold',P,nfolds); fprintf .
    end
    
    for p=1:nfolds
        test = (indices == p); train = ~test;
        train_data=tr_data(train,:);
        test_data=tr_data(test,:);
        svmStruct = svmtrain(train_data, tr_labels(train),'Kernel_Function',char(kernels(kernel)));
        classes = svmclassify(svmStruct,test_data);
        classperf(cp, classes,test,'Positive', 1, 'Negative', 0);
    end
    values(kernel).cp=cp; fprintf .
    values(kernel).trad=svmStruct; fprintf .
    fprintf('completado! \n')
end

end

function [values]=selection_validation(testg,test_labels,val,jump,pname)
fprintf('Validando el mapa de precision..')

[Z Y X]=size(val);fprintf .
values=struct('cp',cell([Z Y X]));fprintf .
okopts={'svm','bayes'};

cl = find(strncmpi(pname, okopts,numel(pname)));
switch cl
    case 1
        for cir3=1:jump:Z
            for cir2=1:jump:Y
                for cir1=1:jump:X
                    if ~isempty(val(cir3,cir2,cir1).index)
                        %        values=struct('cp',cell(1,1));
                        test_data=testg(:,val(cir3,cir2,cir1).index);
                        classes = svmclassify(val(cir3,cir2,cir1).trad,test_data);
                        cp=classperf(test_labels, classes);
                        values(cir3,cir2,cir1).cp=cp;
                    end
                end
            end
            fprintf .
        end
    case 2
        for cir3=1:jump:Z
            for cir2=1:jump:Y
                for cir1=1:jump:X
                    if ~isempty(val(cir3,cir2,cir1).index)
                        %        values=struct('cp',cell(1,1));
                        test_data=testg(:,val(cir3,cir2,cir1).index);
                        classes = predict(val(cir3,cir2,cir1).trad,test_data);
                        cp=classperf(test_labels, double(classes));
                        values(cir3,cir2,cir1).cp=cp;
                    end
                end
            end
            fprintf .
        end
end
fprintf('Completado! \n')
end


function [values]=selection_validation_S(testg,test_labels,val,comp_sizeZ)
fprintf('Validando el mapa de precision..')
I=val(1,1,1).I;
[z,y,x]= ind2sub(size(squeeze(testg(1,:,:,:))),I);
NVoxels= length(I);
[Z Y X]=size(val);fprintf .
values=struct('cp',cell([Z Y X]));fprintf .
for l=1:NVoxels
    if ~isempty(val(z(l),y(l),x(l)).index)
        %        values=struct('cp',cell(1,1));
        test_data=testg(:,z(l)-comp_sizeZ:z(l)+comp_sizeZ,y(l)-comp_sizeZ:y(l)+comp_sizeZ, x(l)-comp_sizeZ:x(l)+comp_sizeZ);
        classes = svmclassify(val(z(l),y(l),x(l)).trad,test_data(:,:));
        cp=classperf(test_labels, classes);
        values(z(l),y(l),x(l)).cp=cp;
    end
    
    %    fprintf .
end

fprintf('Completado! \n')
end

function [map]=precision_map(mascara,values,comp_size,jump)
fprintf('Elaborando mapa de precision..')
[Z Y X]=size(mascara);
[pre]=get_values(values,jump);fprintf .
j1=jump; j2=jump; j3=jump;
[m n o]=size(pre);fprintf .
tr_Acc=zeros(Z,Y,X);fprintf .
map_fuz=zeros(Z,Y,X);fprintf .
tr_Acc(1:comp_size,1:comp_size,1:comp_size)=1;
counter=zeros(Z,Y,X);fprintf .

for cir3=1:j1:m
    for cir2=1:j2:n
        for cir1=1:j3:o
            if pre(cir3,cir2,cir1)==-1
                continue
            end
            cir=[cir3-1 cir2-1 cir1-1];
            tr_Acc_pr=circshift(tr_Acc,cir)*pre(cir3,cir2,cir1);
            map_fuz=map_fuz+tr_Acc_pr;
            cont=circshift(tr_Acc,cir);
            counter=counter+cont;
        end
    end
end
map=map_fuz./counter;


for z=1:Z
    map(z,:,:)=squeeze(mascara(z,:,:)).*squeeze(map(z,:,:));
end
figure
bmp_stack(map,5);
fprintf('Fin! \n')
end

function [map]=precision_map_S(mascara,values,val,comp_size)
fprintf('Elaborando mapa de precision..')
[Z Y X]=size(mascara);
I=val(1,1,1).I;
[z,y,x]= ind2sub(size(mascara),I);
NVoxels= length(I);

map_fuz=zeros(Z,Y,X);fprintf .

counter=zeros(Z,Y,X);fprintf .

for l=1:NVoxels
    if ~isempty(val(z(l),y(l),x(l)).index)
        tr_Acc=zeros(Z,Y,X);
        tr_Acc(z(l)-comp_size:z(l)+comp_size,y(l)-comp_size:y(l)+comp_size, x(l)-comp_size:x(l)+comp_size)=1;
        tr_Acc_pr=tr_Acc*values(z(l),y(l),x(l)).cp.CorrectRate;
        map_fuz=map_fuz+tr_Acc_pr;
        cont=tr_Acc;
        counter=counter+cont;
    end
end
map=map_fuz./counter;


for z=1:Z
    map(z,:,:)=squeeze(mascara(z,:,:)).*squeeze(map(z,:,:));
end
figure
bmp_stack(map,5);
fprintf('Fin! \n')
end

function [pre]=get_values(values,jump)
[Z Y X]=size(values);
pre=zeros(size(values));
for cir3=1:jump:Z
    for cir2=1:jump:Y
        for cir1=1:jump:X
            if ~isfield(values(cir3,cir2,cir1),'cp'), pre(cir3,cir2,cir1)=-1;
                continue
            elseif isempty(values(cir3,cir2,cir1).cp), pre(cir3,cir2,cir1)=-1;
                continue
            elseif (values(cir3,cir2,cir1).cp.CorrectRate)==0, pre(cir3,cir2,cir1)=-1;
                continue
            end
            pre(cir3,cir2,cir1)=values(cir3,cir2,cir1).cp.CorrectRate;
            
        end
    end
end
end

