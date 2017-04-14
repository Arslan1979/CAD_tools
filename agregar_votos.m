
function [agregad]=agregar_votos(train_values,test_values,agregadmethod,mTh)

okopts={'mayoria','relevancia','MAP'};
cl = find(strncmpi(agregadmethod, okopts,numel(agregadmethod)));
numOfcomp=numel(train_values);
switch cl
    case 1
        ErrD=zeros(numOfcomp,numel(test_values(1).cp.ErrorDistribution));
        grut=(test_values(1).cp.GroundTruth);
        for j=1:numOfcomp
            ErrD(j,:)=test_values(j).cp.ErrorDistribution;
        end
        cp=classperf(grut);
        mEd=mean(ErrD);
        if xor(isrow(grut),isrow(mEd)), mEd=mEd'; end
        clas=grut-(mEd>0.5);
        clas(clas==0)=2;
        prec=classperf(cp,clas,'positive',2,'negative',1);
    case 2
        %ErrD=ones(1,numel(test_values(1).cp.ErrorDistribution));
        grut=(test_values(1).cp.GroundTruth);
        count=0;
        %mTh=0.8; %puede introducirse como input
        for j=1:numOfcomp
            if train_values(j).cp.CorrectRate>mTh
                count=count+1;
                ErrD(count,:)=test_values(j).cp.ErrorDistribution;
                j
            end
        end
        cp=classperf(grut);
        if count==0
            clas=ones(1,numel(grut));
            ErrD=NaN;
        else
        mEd=mean(ErrD,1);
        if xor(isrow(grut),isrow(mEd)), mEd=mEd'; end
        clas=grut-(mEd>0.5);
        clas(clas==0)=2;
        end
        prec=classperf(cp,clas,'positive',2,'negative',1);
    case 3
        prev=(test_values(1).cp.Prevalence); 
        ErrD=zeros(numOfcomp,numel(test_values(1).cp.ErrorDistribution));
        grut=(test_values(1).cp.GroundTruth);
        for j=1:numOfcomp
            ErrD(j,:)=test_values(j).cp.ErrorDistribution;
            assign=test_values(j).cp.GroundTruth-1+test_values(j).cp.ErrorDistribution;
        assign(assign==2)=0; probac1(1:numel(grut))=0;probac2(1:numel(grut))=0;%probac3(1:numel(grut))=0;probac4(1:numel(grut))=0;
        apriorip=test_values(j).cp.DiagnosticTable./sum(test_values(j).cp.DiagnosticTable(:));
        probac1(assign==0)=apriorip(1,1);
        probac2(assign==1)=apriorip(2,2);
        probac2(assign==0)=apriorip(1,2);
        probac1(assign==1)=apriorip(2,1);
        probabilitc1(1:numel(grut),j)=probac1';
        probabilitc2(1:numel(grut),j)=probac2';
        %probabilitc3(1:numel(grut),cont)=probac3';
        %probabilitc4(1:numel(grut),cont)=probac4';
        end
        
        probabilitc1(probabilitc1==0)=eps;
        probabilitc2(probabilitc2==0)=eps;
        cp=classperf(grut);
        opt1=sum(log(probabilitc1),2);
        opt2=sum(log(probabilitc2),2);
        [a,b]=sort([prev*opt1 (1-prev)*opt2],2);
        prec=classperf(cp,b(:,2),'positive',2,'negative',1);
end

agregad.Results=prec;
agregad.ErrorVotes=ErrD;

end
