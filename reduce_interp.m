function [tr_data] = reduce_interp(stack_all,varargin)

% Devuelve: los datos comprimidos por un factor 1/VS^3
% tr_data           vector de datis de entrenamiento.
VS=varargin{1};
if nargin>2
    method=varargin{2};
    interp_flag=true;
else 
    interp_flag=false;
end
if numel(VS)==1
    VS=[VS VS VS];
end

if all(VS==1)
    tr_data=stack_all;
    return
else
    if numel(size(stack_all))>3
        squeeze(stack_all);
    end
    if numel(size(stack_all))>3
        [P Z Y X]=size(stack_all);
        
        [x,y,z]=ndgrid(1:Z,1:Y,1:X);
        [x1,y1,z1]=ndgrid(VS(1):VS(1):Z,VS(2):VS(2):Y,VS(3):VS(3):X);
        tr_data=zeros([P size(VS(1):VS(1):Z,2) size(VS(2):VS(2):Y,2) size(VS(3):VS(3):X,2)  ]);
        for k=1:P
            stack=squeeze(stack_all(k,:,:,:));
            if ~isa (stack, 'double')
                %    fprintf ('Warning: converting input data into regular (double) precision.\n');
                stack = double (stack);
            end
            if interp_flag
                tdata=interp3(y,x,z,stack,y1,x1,z1,method);fprintf .
            else
                tdata=interp3(y,x,z,stack,y1,x1,z1);fprintf .
            end

            fprintf('completed %d\n',k)
            tr_data(k,:,:,:)=tdata(:,:,:);
        end
        return
    else
    if ~isa (stack_all, 'double')
                %    fprintf ('Warning: converting input data into regular (double) precision.\n');
                stack_all = double (stack_all);
    end
    [Z Y X]=size(stack_all);
    [x,y,z]=ndgrid(1:Z,1:Y,1:X);
    [x1,y1,z1]=ndgrid(VS(1):VS(1):Z,VS(2):VS(2):Y,VS(3):VS(3):X);%=ndgrid(1:VS(1):Z,1:VS(2):Y,1:VS(3):X);%
    if interp_flag
       tr_data=interp3(y,x,z,stack_all,y1,x1,z1,method);fprintf .
    else
        tr_data=interp3(y,x,z,stack_all,y1,x1,z1);fprintf .
    end
    end
end




end
