function FDR= FisherDiscriminantRatio(VAR,tr_labels)

FDR= [];
for slice=1:size(VAR,2)
    m1= mean(VAR(find(~tr_labels),slice));
    m2= mean(VAR(find(tr_labels),slice));
    v1= var(VAR(find(~tr_labels),slice));
    v2= var(VAR(find(tr_labels),slice));
    FDR(slice)= (m1-m2)^2/(v1+v2);
end
