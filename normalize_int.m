function [stack_all_nor]=normalize_int(stack_all,varargin)

% Normalization rutine for normalization of intensity values of images. Admits options:
% max -       Normalization to a maximum value I_max. The whole image is divided by I_max and shifted if negetive values are taken. 
%             By default the maximum is taken from the th=0.001% of the 50 bin histogram, which usually equals the absolute maximum,
%             except when outlier values are present. The percentage 'th' can also be specified as an input.
% int -       Integral normalization. The whole image is divided by I_max, estimated by the sum of all
%             voxel values of the image
% cerebellum - The whole image is divided by I_max, estimated as the average intensity in the cerebellum. Requires the file listado.mat, and
%              the images to be registered with the MRI template of ICBM.
% pk`-        Under development
% eq -        Performs an histogram equalization.
%
%
% Ignacio Alvarez Illan // 13-11-2014



okopts={'max','int','cerebellum','pk','eq'};
P=size(stack_all,1);
stack_all_nor=zeros(size(stack_all));
pname = varargin{1};
cl = find(strncmpi(pname, okopts,numel(pname)));
switch cl
    case 1
        if nargin<3
            fprintf('taking default parameters..')
            th=0.001;
        else
        th=varargin{2};
        end

        for p=1:P
            stack=squeeze(stack_all(p,:,:,:));
            mini=min(stack(:));
            stack(isnan(stack))=0;
            desp=0-mini;
            stack=stack+desp;
            stackm=mascara(stack); % Se descartan las regiones exteriores al cerebro
            [j,k]=hist(stackm(stackm>0),50);fprintf('.')

            valor_acum=cumsum(j)/max(cumsum(j));
            fprintf('.')
            % Obtiene el bin a partir del cual se registran intensidades mayores al Th% del valor acumulado anterior
            max_i=k(find(valor_acum>(1-th),1));fprintf('.')
            % Se normaliza toda la imagen a 1-0 con este valor
            stack=stack./max_i;fprintf('.')

            stack(stack>1)=1;fprintf('.')
            stack(stack<0.00001)=0;fprintf('.')
            fprintf('intensity normalized of %d patient \n',p)
            stack_all_nor(p,:,:,:)=stack(:,:,:);
        end
    case 2
        %data=mascara(stack_all,0.25);
        data=stack_all;
        for p=1:P
            mini=squeeze(data(p,:,:,:)); fprintf .
            stack=mascara(mini);
            Imax=mean(stack(stack>0)); fprintf .
            stack_all_nor(p,:,:,:)=stack_all(p,:,:,:)./Imax;%-beb(ded); fprintf .
            fprintf('intensity normalized of %d patient \n',p)
        end
        
    case 3
        P=size(stack_all,1);
        load listado.mat
        cerebellum_list=listado.regions{37};
        for i=1:P
            stack=squeeze(stack_all(i,:,:,:));
            cerebellum=stack(cerebellum_list);
            Imax=mean(cerebellum(cerebellum(:)>0));          
            stack_all_nor(i,:,:,:)=stack_all(i,:,:,:)/Imax;
            fprintf('intensity normalized of %d patient \n',i)
        end
    case 4
        template=load_nii('/home/ignacio/Matlab/programas/spm8/templates/spect_datscan_48.hdr');
    case 5
        for i=1:P
            stack=squeeze(stack_all(i,:));
            J=imadjust(stack,[0.2 1],[]);
            jr=reshape(J,size(squeeze(stack_all(1,:,:,:))));
            stack_all_nor(i,:,:,:)=jr;
            fprintf('intensity normalized of %d patient \n',i)
        end
end
end
