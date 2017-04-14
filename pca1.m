function [W SCORE LAT]=pca1(data)
% Principal Component Analysis
% A. Ortiz, 2015
% Sintax: [COEFF SCORE LAT]=pca(data);
% COEFF -> loadings
% SCORE -> Principal Components
% LAT   -> Eigenvalues
%
    % Center data to zero mean
    shifted_data=data-repmat(mean(data,2),1,size(data,2));
    % Calculate covariance matrix
    Sigma=(1/(size(data,2)))*data*data';
    % calculate eigenvectors (loadings) W, and eigenvalues of the covariance matrix
    [W, EvalueMatrix] = eig(single(Sigma));
    Evalues = diag(EvalueMatrix);
    % sort the variances in decreasing order
    [junk, ridx] = sort(-1*Evalues);
    W=W(:,ridx);
    % generate PCA component space (PCA scores)
    SCORE= (W' * shifted_data);
    LAT=Evalues;
end