% Fisher linear classifier
%
% INPUT:    feat_norm - matrix with rows containing feature vectors of
%                       normal patients
%           feat_alz - matrix with rows containing feature vectors of
%                      Alzheimer patients
%           feat_test - feature vector to be classified
% OUTPUT:   class - classification of 'feat_test' as normal (value>0) or
%                   Alzheimer (value<0)

function class = fisher_classifier(feat_norm, feat_alz, feat_test)

%% average normal feature vector
V_norm = mean(feat_norm,1);

%% average Alzheimer feature vector
V_alz = mean(feat_alz,1);

%% compute the pseudo-inverse 'Si' of the sample covariance
sn = size(feat_norm, 1);
sa = size(feat_alz, 1);

f(1:sn,:) = feat_norm;
f((sn+1):(sn+sa),:) = feat_alz;

S = cov(f);
Si = pinv(S);

%% class label (normal>0, Alzheimer<0)
class = (feat_test-V_alz)*Si*(feat_test-V_alz)' - (feat_test-V_norm)*Si*(feat_test-V_norm)';

