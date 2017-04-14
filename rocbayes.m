function [output,test]=rocbayes(data,labels)
P=size(data,1);
labels=labels>0;
hsize=0.65;

[train,test] = crossvalind('HoldOut',P,hsize);
values=struct('cp',1);
cp=classperf(labels);

tr_data=data(train,:);
tt_data=data(test,:);
    nb = NaiveBayes.fit(tr_data, labels(train));
    [class,unused1,cll] = posterior(nb, tt_data);
    output=cll;

end