function [res] = components_multi(stack_all,tr_labels,nfolds,hsize,pname,stack_allcompl)

ncompoini=2;

Tama=size(stack_all);
if nargin>5, tama2=size(stack_allcompl); P=Tama(1)+tama2(1); else stack_allcompl=[]; P=Tama(1); end
[train,test] = crossvalind('HoldOut',P,hsize);
okopts={'svm','bayes'};
%pname = 'bayes';% 'svm';%
labels=(tr_labels>0);
res=struct('TestValues',cell(1,1),'TrainValues',cell(1,1),'map',cell(1,1));
labels_train=labels(train);
labels_test=labels(test);

%% Entrenamiento de las componentes
fprintf('Empezando con el grupo ')

%lista=listar(stack_all,1,2);
load('listado.mat'); 
if Tama(2)>100
lista=listado.tama121x145x121.aal;
else
lista=listado.tama69x95x79.aal;
end
numOfcomp=size(lista,2);

for i=ncompoini:numOfcomp
    fprintf([ 'Calculando la precision de la componente ' num2str(i) '/' num2str(numOfcomp) ]);
    try
        if nargin>5
            component_part1=stack_all(:,lista{i});
            component_part2=stack_allcompl(:,lista{i});
            component=[component_part1;component_part2];
            stack_train=component(train,:);
        else
            stack_train=stack_all(train,lista{i});
        end
        train_values(i)=component_accuracy(stack_train,labels_train,nfolds,pname);
        %train_values(i)=component_minSV(stack_train,labels_train,pname);
    catch
        train_values(i)=NaN;
    end
    fprintf('completado! \n')
end

%% Validación de las componentes
fprintf('Validando el mapa de precision..')


cl = find(strncmpi(pname, okopts,numel(pname)));
switch cl
    case 1
        for i=ncompoini:numOfcomp
            if nargin>5
                component_part1=stack_all(:,lista{i});
                component_part2=stack_allcompl(:,lista{i});
                component=[component_part1;component_part2];
                test_data=component(test,:);
            else
                test_data=stack_all(test,lista{i});
            end
            classes = svmclassify(train_values(i).trad,test_data);
            cp=classperf(labels_test, classes);
            test_values(i).cp=cp;
        end
    case 2
        for i=ncompoini:numOfcomp
            if nargin>5
                component_part1=stack_all(:,lista{i});
                component_part2=stack_allcompl(:,lista{i});
                component=[component_part1;component_part2];
                test_data=component(test,:);
            else
                test_data=stack_all(test,lista{i});
            end
            classes = predict(train_values(i).trad,test_data);
            cp=classperf(labels_test, double(classes));
            test_values(i).cp=cp;
        end
end

fprintf('Completado! \n')

%% Elaborar mapa de precision

fprintf('Elaborando mapa de precision..')
Z=Tama(2);Y=Tama(3);X=Tama(4);
pmap=zeros(Z,Y,X);
spmap=zeros(Z,Y,X);
semap=zeros(Z,Y,X);
counter=zeros(Z,Y,X);
for i=2:numOfcomp
    pmap(lista{i})=pmap(lista{i})+train_values(i).cp.CorrectRate;
    spmap(lista{i})=spmap(lista{i})+train_values(i).cp.Sensitivity;
    semap(lista{i})=semap(lista{i})+train_values(i).cp.Specificity;
    counter(lista{i})=counter(lista{i})+1;
end
pmap=pmap./counter;
pmap=reshape(pmap,[Z Y X]);
spmap=spmap./counter;
spmap=reshape(spmap,[Z Y X]);
semap=semap./counter;
semap=reshape(semap,[Z Y X]);
%figure
%bmp_stack(pmap,5);
fprintf('Fin! \n')
%% Agregar votos
agregadmethod='mayoria'; %Puede introducirse como input

[prec]=agregar_votos(train_values,test_values,agregadmethod);

%%


res.TestValues=test_values;
res.TrainValues=train_values;
res.maps.pmap=pmap;
res.maps.spmap=spmap;
res.maps.semap=semap;
res.testset=test;
res.compList=lista;
res.Precision=prec;

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


function [values]=component_accuracy(tr_data,tr_labels,nfolds,pname)
kernels= { 'linear' }; %'rbf' 'polynomial' 'quadratic'  };
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
            options=optimset('MaxIter',1000);
            for p=1:nfolds
                test = (indices == p); train = ~test;
                train_data=tr_data(train,:);
                test_data=tr_data(test,:);
                svmStruct = svmtrain(double(train_data), tr_labels(train),'Kernel_Function',char(kernels(kernel)),'method','QP','options',options);
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
        
end
end

function [values]=component_minSV(tr_data,tr_labels,pname)
kernels= { 'linear' }; %'rbf' 'polynomial' 'quadratic'  };
P=size(tr_data,1);
NK=numel(kernels);
values=struct('nSv',cell(1,NK),'trad',cell(1,NK));
okopts={'svm','bayes'};


%    pval = varargin{j+1};
cl = find(strncmpi(pname, okopts,numel(pname)));
switch cl
    case 1
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
end

