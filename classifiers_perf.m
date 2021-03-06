function [values]=classifiers_perf(data,labels,k,varargin)

% Estima la precision de un clasificador sobre la matriz de datos 'data',
% etiquetada con 'labels' mediante 'k-fold cross-validation', donde k es el n�mero de folds a usar,
% y usando diferentes clasificadores. Usar k folds es equivalente a dejar P/k fuera, donde
% P es el n�mero total de pacientes. Devuelve una variable 'struct' con todo el analisis que produce
% classperf: CorrectRate, Sensibility, Sensitivity, Errordistribution,..etc.Los posibles clasificadores a usar son:
%
%  * 'svm' -->  Support vector machine
%
%     Debe introducirse el kernel o los kernels a utilizar,
%     %
%     ej 1:
%     [values]=classifiers_perf(data,labels,k,'svm',{'linear' 'rbf'})
%     ej 2:
%     [values]=classifiers_perf(data,labels,k,'svm',{'polynomic'})
%
%       Si se usa mas de un kernel, entonces values contendr� los
%       resultados ordenados segun el orden de los kernels introducidos
%       (en el ejemplo 1, el resultado ser� values(1).cp para kernel lineal
%       y values(2).cp para kernel rbf)
%
%  * 'knn' -->  k-Nearest Neighbour
%
%     Por defecto k=1, pero puede introducirse el numero de vecinos a utilizar,
%
%
%     ej 1:
%     [values]=classifiers_perf(data,labels,k,'knn',5)
%     ej 2:
%     [values]=classifiers_perf(data,labels,k,'knn')
%
%  * 'nm' -->  Nearest Mean
%
%     ej:
%     [values]=classifiers_perf(data,labels,k,'nm')
%

if ~isa (data, 'double')
    %    fprintf ('Warning: converting input data into regular (double) precision.\n');
    data = double (data);
end


P=size(data,1);
if k==P
    indices=1:P;
elseif k==P/2
    indices=[1:P/2 1:P/2];
else
    indices = crossvalind('Kfold',P,k);
end
labels=squeeze(labels);
if size(labels,2)>size(labels,1)
    labels=labels';
end
labels(labels>0)=1;
okopts={'svm','knn','nm','fdr','bayes'};
%numoptargs=nargin-3;
%for j=1:2:numoptargs
j=1;
pname = varargin{j};
    %    pval = varargin{j+1};
    cl = find(strncmpi(pname, okopts,numel(pname)));
    switch cl
        case 1
            disp('  Estimating the preformance parameters of the Support Vector Machine classificator with: ')
            kernels=varargin{j+1};
            NK=numel(kernels);
            values=struct('cp',cell([NK 1]));
            disp([ num2str(NK) ' kernels, and leaving ' num2str(floor(P/k)) ' out:'] );
            for kernel= 1:NK
                cp=classperf(labels);
                for p=1:k %leave-P/k-out
                    test = (indices == p); train = ~test;
                    train_data=data(train,:);
                    test_data=data(test,:);
                    svmStruct = svmtrain(train_data,labels(train),'Kernel_Function',char(kernels(kernel)));
                    classes = svmclassify(svmStruct,test_data);fprintf('.')
                    classperf(cp, classes,test,'Positive', 1, 'Negative', 0);
                    if and(size(train_data,2)==2,p==k)
                        figure;
                        svmStruct = svmtrain(train_data, labels(train),'showplot',true,'Kernel_Function',char(kernels(kernel))); title(sprintf('Kernel Function: %s',func2str(svmStruct.KernelFunction)),'interpreter','none'); legend('NORMAL','ATD','SVs');
                        % svmStruct = svmtrain(tr_data, tr_labels,'showplot',true,'Kernel_Function','quadratic'); title(sprintf('Kernel Function: %s',func2str(svmStruct.KernelFunction)),'interpreter','none'); legend('NORMAL','ATD','SVs');
                        % svmStruct = svmtrain(tr_data, tr_labels,'showplot',true,'Kernel_Function','rbf'); title(sprintf('Kernel Function: %s',func2str(svmStruct.KernelFunction)),'interpreter','none'); legend('NORMAL','ATD','SVs');
                        % svmStruct = svmtrain(tr_data, tr_labels,'showplot',true,'Kernel_Function','polynomial'); title(sprintf('Kernel Function: %s',func2str(svmStruct.KernelFunction)),'interpreter','none'); legend('NORMAL','ATD','SVs');
                    end
                end
                values(kernel).cp=cp;
                disp(['  Accuracy= ', num2str(cp.CorrectRate*100) ' %' ]);
            end
        case 2
            disp('  Estimating the preformance parameters of the Nearest neighbour classificator with: ')
            values=struct('cp',1);
            if nargin>4,            kfol=varargin{j+1}; else kfol=k; end,
            disp([ num2str(kfol) ' folds, and leaving ' num2str(floor(P/k)) ' out:'] );
            cp=classperf(labels);
            for p=1:k %leave-P/k-out
                test = (indices == p); train = ~test;
                train_data=data(train,:);
                test_data=data(test,:);
                if nargin<5
                    classes = knnclassify(test_data,train_data,labels(train));fprintf('.')
                else
                    classes = knnclassify(test_data,train_data,labels(train),kfol);fprintf('.')
                end
                classperf(cp, classes,test,'Positive', 1, 'Negative', 0);
            end
            values.cp=cp;
            disp(['  Accuracy= ', num2str(cp.CorrectRate*100) ' %' ]);
        case 3
            disp('  Estimating the preformance parameters of the Nearest Mean classificator with: ')
            values=struct('cp',1);
            cp=classperf(labels);
            for p=1:k %leave-P/k-out
                test = (indices == p); train = ~test;
                feat_norm=data(and(train,labels==0),:);
                feat_alz=data(and(train,labels>0),:);
                test_data=data(test,:);
                cl = nm_classifier(feat_norm,feat_alz,test_data);fprintf('.')
                classes=double(cl<0);
                classperf(cp, classes,test,'Positive', 1, 'Negative', 0);
            end
            values.cp=cp;
            disp(['  Accuracy= ', num2str(cp.CorrectRate*100) ' %' ]);
        case 4
            disp('  Estimating the preformance parameters of the Fisher Discriminant classificator with: ')
            values=struct('cp',1);
            cp=classperf(labels);
            for p=1:k %leave-P/k-out
                test = (indices == p); train = ~test;
                feat_norm=data(and(train,labels==0),:);
                feat_alz=data(and(train,labels>0),:);
                test_data=data(test,:);
                cl = fisher_classifier(feat_norm,feat_alz,test_data);fprintf('.')
                classes=double(cl<0);
                classperf(cp, classes,test,'Positive', 1, 'Negative', 0);
            end
            values.cp=cp;
            disp(['  Accuracy= ', num2str(cp.CorrectRate*100) ' %' ]);
        case 5
            disp('  Estimating the preformance parameters of the Naive Bayes classificator with: ')
            values=struct('cp',1);
            cp=classperf(labels);
            for p=1:k %leave-P/k-out
                test = (indices == p); train = ~test;
                tr_data=data(train,:);
                tt_data=data(test,:);
                nb = NaiveBayes.fit(tr_data, labels(train));
                class = predict(nb, tt_data);
                classperf(cp, class,test,'Positive', 1, 'Negative', 0);
            end
            values.cp=cp;
            disp(['  Accuracy= ', num2str(cp.CorrectRate*100) ' %' ]);
    end
end




