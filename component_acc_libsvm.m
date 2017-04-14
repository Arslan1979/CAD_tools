function [values]=component_acc_libsvm(tr_data,tr_labels)
kernels= { 'linear' }; %'rbf' 'polynomial' 'quadratic'  };
NK=numel(kernels);
values=struct('cp',cell(1,NK),'trad',cell(1,NK));
model_crossval='-v 10';
c=1;
if isrow(tr_labels), tr_labels=tr_labels'; end
%model_kernel=['-t 0 -q -c ' num2str(c)];
bestcv = 0;
for log2c = -5:5,
  for log2g = -5:5,
    model_kernel = [' -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(tr_labels,double(tr_data),[model_crossval model_kernel]);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end
res = [];%
svmStruct = bestcv;
values.cp=res; fprintf .
values.trad=svmStruct; fprintf .
fprintf('completado! \n')
%% Confidence margins

lisp=((svmStruct.sv_coef)<=c);
[predict_labelp, ~, dec_valuesp] = svmpredict(tr_labels(svmStruct.sv_indices(lisp)), tr_data(svmStruct.sv_indices(lisp),:), svmStruct);
lis2p=tr_labels(svmStruct.sv_indices(lisp))~=predict_labelp;
MmarI=min(dec_valuesp(lis2p));if isempty(MmarI), MmarI=eps; end

lisn=((svmStruct.sv_coef)>=-c);
[predict_labeln, ~, dec_valuesn] = svmpredict(tr_labels(svmStruct.sv_indices(lisn)), tr_data(svmStruct.sv_indices(lisn),:), svmStruct);
lis2n=tr_labels(svmStruct.sv_indices(lisn))~=predict_labeln;
MmarS=max(dec_valuesn(lis2n));if isempty(MmarS), MmarS=eps; end

% lis=~(abs(svmStruct.sv_coef)==1);
% [~, ~, dec_values] = svmpredict(tr_labels(svmStruct.sv_indices(~lis))', tr_data(svmStruct.sv_indices(~lis),:), svmStruct);
% MS=max(dec_values);
% MI=min(dec_values); 

values.MS=MmarS;%max(MS,MmarS);
values.MI=MmarI;%min(MI,MmarI);
end


