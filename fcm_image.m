function [ imagNew ] = fcm_image(I,Nc,MaxP)

if nargin<2, Nc=3; MaxP=0; elseif nargin==2, MaxP=eps;   end

imageSize = size(I);

data = I(:);
options = [NaN 100 0.001 0];
[~,U,~] = fcm(I(:),Nc,options); % Fuzzy C-means classification with Nc classes

% Finding the pixels for each class
if MaxP>0, MaxP = max(U); end
mask(1:numel(data))=0;
for i=1:Nc
index{i} = find(U(i,:) >= MaxP);
mask(index{i})=i;
end


% Reshapeing the array to a image
imagNew = reshape(mask,imageSize);


end

