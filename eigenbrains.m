function [res]=eigenbrains(x,tr_labels,varargin)


% PCA y Proyecci�n 
%=================
% 
% Ejemplos de uso:
% 
% [res] = eigenbrains (mixedsig); pca normal usando tantas componentes como fuentes %
%
% [res] = eigenbrains (mixedsig,'fisher','on') pca usando criterio discriminante de fisher; %
%
% [res] = eigenbrains (mixedsig,'fisher','off','numOFpc',3); pca normal usando 3 componentes %
%==========================================================================
%
% OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
%======================================================================
%
%
% 'fisher'            (string) Puede ser "usalo" ('on') o no lo uses
%                      ('off). El default es ('off')
%                       %
%
% 'numOfpc'             (integer) Numero de componentes a usar,
%                      ya sea usando el criterio discriminante de fisher o
%                      no. El default es el numero de signals.
%
% 'adni'                (logical) Si se usa o no la base de datos adni (y
%                       por tanto se calcula o no los resultados parciales
%                       MCIvsNorm, ADvsNor y MCIc+ADvsNor. El default es
%                       off
%
% 'nfolds'               (double) Numero de folds a usar en la validacion
%                       por k-fold (deja aprox P/k fuera). Si nfolds=P, entonces
%                       se hace l-o-o. El default es 5.
%
% 'method'              (string) Puede ser 'pca' o 'ica', en funcion del
%                       metodo para obtener los eigenbrains. El default es
%                       pca
%
% 'mask'                (double, entre 0 y 1) Aplica una mascara con threashold fijado
%                        al valor introducido (toma la media y selecciona
%                        los voxels cuyo valor sea  superior al th
%                        introducido). Por defecto no se aplica.
%
% 'sym'                  (logical) Determina si duplicar los datos y
%                        aplicar el analisis de simetria. Por defecto no se
%                        aplica
%
%% Default values for 'pca_fisher' parameters

fisher         = 'off';
th             = 0;
numc           = size(x,1);
nfolds         = 5;
method         = 'pca';
adni           = false ;
sym            = false;

%% Main program

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        if ~ischar (varargin{i}),
            error (['Unknown type of optional parameter name (parameter' ...
                ' names must be strings).']);
        end
        % change the value of parameter
        switch lower (varargin{i})
            case 'fisher'
                fisher = lower (varargin{i+1});
            case 'numofpc'
                numc = varargin{i+1};
            case 'mask'
                th = varargin{i+1};% un buen numero es 0.15 para las SPECT
            case 'adni'
                adni=varargin{i+1};
            case 'nfolds'
                nfolds=varargin{i+1};
            case 'method'
                method=varargin{i+1};
            case 'sym'
                sym=varargin{i+1};
        end
    end
end
P=size(x,1);
kernels= { 'linear' 'rbf' }; %'quadratic''polynomial'   };%
NK=numel(kernels);

if th>0
    [x]=mascara(x,th);
end
if isrow(tr_labels), tr_labels=tr_labels'; end
values=struct('cp',cell([NK 1]));
partial=struct('perf',cell([4 1]));
if adni
    perf=struct('cp',cell([NK 1]));
    for j=1:4, partial(j).perf=perf; end
    groups(1).marks=or(tr_labels==0,tr_labels==3);
    groups(1).name='NCvsAD'; fprintf .
    groups(2).marks=or(tr_labels==0,tr_labels==2);
    groups(2).name='NCvsMCIc'; fprintf .
    groups(3).marks=(tr_labels<2);
    groups(3).name='NCvsMCI'; fprintf .
    groups(4).marks=not(tr_labels==1);
    groups(4).name='NCvsMCIc+AD';
    for j=1:4, for k=1:NK, partial(j).perf(k).cp=classperf(tr_labels(groups(j).marks)>0);  end, end
end



for k=1:NK, values(k).cp=classperf(tr_labels>0);   end

fprintf('variables initailized!\n Starting.')

labels=(tr_labels>0);
% if ~isa (x, 'double')
%     fprintf ('Warning: converting input data into regular (double) precision.\n');
%     x = double (x);
% end
if sym
    x = [ x ; flipdim(x,3)] ;
    P=2*P;
%    nfolds=P/2;
%    labels=[labels labels];
    for k=1:NK, values(k).cp=classperf(labels);   end
end

[eignbr,pca]=eigenbrain_extractor(x,method);
% eignbr=eignbr'; 
% [s1 s2 s3 s4]= size(x);
% eignbr=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
if nfolds==P
    indices=1:P;
elseif and(nfolds==P/2,sym)
    indices=(1:P/2);
else
    indices = crossvalind('Kfold',P,nfolds);
end
if sym    
    ode=(sum(squeeze(sum(squeeze(sum(abs(eignbr+flipdim(eignbr,3)),2)),2)),2))>1;
end

for p=1:nfolds %leave-M-out
            test = (indices == p); train = ~test;

%    test = false(P,1); test(p)=true;  train = ~test;fprintf .
    %     train_data_ns=xt(train,:)*eignbr;
    %     test_data_ns=xt(test,:)*eignbr;


    

    fprintf .
    if adni
        for j=1:4
            if any(and(test,groups(j).marks))
                traing=and(groups(j).marks,train);
                testg=and(groups(j).marks,test);
                train_data_ns=pca(traing,:);
                test_data_ns=pca(testg,:);
                testA(1:P)=false;
                testA(testg)=true;
                if strcmp(fisher,'on')
                    FDR= FisherDiscriminantRatio(train_data_ns,labels(traing));fprintf .
                    [coeff,order]=sort(FDR,'descend');fprintf .
                else
                    order=(1:sum(groups(j).marks));
                end
                train_data=train_data_ns(:,order(1:numc));fprintf .
                test_data=test_data_ns(:,order(1:numc));fprintf .

                for kernel= 1:NK

                    svmStruct = svmtrain(train_data,labels(traing),'Kernel_Function',char(kernels(kernel)));

                    classes = svmclassify(svmStruct,test_data);
                    fprintf .

                    classperf(partial(j).perf(kernel).cp, classes,testA(groups(j).marks),'Positive', 1, 'Negative', 0);
                end
            end
        end

    end
    if sym
        org_data=pca(1:P/2,:);
        train_data_ns=org_data(train,:);
    test_data_ns=org_data(test,:);
    odde=eignbr+flipdim(eignbr,3);
        parimp=mean(abs(odde(:,:)),2);
        labelsp=parimp<0.00001;
    else
    train_data_ns=pca(train,1:95);
    test_data_ns=pca(test,1:95); 

    end
    if strcmp(fisher,'on')
        FDR= FisherDiscriminantRatio(train_data_ns,labels(train));fprintf .
        [coeff,order]=sort(FDR,'descend');fprintf .
    else
        order=(1:P);
    end
    train_data=train_data_ns(:,order(1:numc));fprintf .
    test_data=test_data_ns(:,order(1:numc));fprintf .

    for kernel= 1:NK

         if ~isa (train_data, 'double')
              fprintf ('Warning: converting input data into regular (double) precision.\n');
              train_data = double (train_data);
              test_data= double (test_data);
        end
        svmStruct = svmtrain(train_data,labels(train),'Kernel_Function',char(kernels(kernel)));%,'Autoscale',false);
        fprintf .
        classes = svmclassify(svmStruct,test_data);
        fprintf .

        classperf(values(kernel).cp, classes,test,'Positive', 1, 'Negative', 0);
    end

    fprintf('completed %d\n',p)
end
fprintf('completed \n')

%end


res.all=values;
res.featv=pca(:,1:numc);
if adni
    res.partial=partial;
    for j=1:4
        res.partial(j).name=groups(j).name;
    end
end
if sym
    res.labels_eig_parity=labelsp;
    res.featv=x(1:P/2,:)*eignbr(order(1:numc),:)';
end
res.eignim=eignbr(order(1:numc),:,:,:);