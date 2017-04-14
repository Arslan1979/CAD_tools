% nearest mean classifier
%
% INPUT:    feat_norm - matrix with rows containing feature vectors of
%                       normal patients
%           feat_alz - matrix with rows containing feature vectors of
%                      Alzheimer patients
%           feat_test - feature vector to be classified
% OUTPUT:   class - classification of 'feat_test' as normal (value>0) or
%                   Alzheimer (value<0)

function class = nm_classifier(feat_norm, feat_alz, feat_test)

%% average normal feature vector
V_norm = mean(feat_norm,1);

%% average Alzheimer feature vector
V_alz = mean(feat_alz,1);

%% distance of test feature to average normal and Alzheimer features
dn = norm(feat_test-V_norm);
da = norm(feat_test-V_alz);

%% class label (normal>0, Alzheimer<0)
class = (da-dn);