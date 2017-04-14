function DR= DiscriminantRatio(VAR,NORMAL,DTA)

DR= [];
for slice=1:size(VAR,2)
    m1= mean(VAR(NORMAL,slice));
    m2= mean(VAR(DTA,slice));
    v1= var(VAR(NORMAL,slice));
    v2= var(VAR(DTA,slice));
    m=mean(VAR(:,slice));
    vm1=(m1-m)^2;
    vm2=(m2-m)^2;
    DR(slice)= (vm1+vm2)/(v1+v2);
end
