function [stack_all,inf]=read_nii(directorio,VS,varargin)
%
% Lee todos los pacientes de la base de datos ADNI que esta en el
% directorio 'directorio' y lo escribe en la variable stack_all
% inf es struct con informaci�n del paciente.
% Los inputs son:
%
%     - VS: se reduce la imagen original a promediando en VSxVSxVS
%     - varargin puede ser:
%         -'normalize' : se normaliza en intensidad al 0.1% de los valores maximos de intensidad
%         - 'info' se obtiene la informacion del paciente
%
%


brain=dir([directorio '/*.nii']);fprintf('.')
bnames=dir([directorio '/*.nii']);fprintf('.')
bnamxml=dir([directorio '/*.xml']);fprintf('.')

for i=1:numel(brain)
    
%% Si el nombre es muy largo.....
%     nbrain=[brain(i).name(1:6) '.hdr'];
%     ibrain=[bimg(i).name(1:6) '.img'];
% %     copyfile([directorio '\normalizados\' brain(i).name],nbrain);
% %     copyfile([directorio '\normalizados\' bimg(i).name],ibrain);
%      copyfile([directorio '\' brain(i).name],nbrain);
%      copyfile([directorio '\' bimg(i).name],ibrain);
%    info=analyze75info(nbrain);fprintf('.')


%%

nii=load_nii(bnames(i).name);
stack=nii.img;

    okopts={'normalize','info','spect'};
    numoptargs=nargin-2;
    for j=1:numoptargs
        pname = varargin{j};
        %    pval = varargin{j+1};
        cl = find(strncmpi(pname, okopts,numel(pname)));
        switch cl
            %%
            case 1
                if ~isa(stack(:),'double')
                    stack=double(stack);
                end
                % Saca el histograma con 50 bins
                [j,k]=hist(stack(:),50);fprintf('.')

                % Coge los bins a partir del 10, porque normalmente los primeros bins acumulan muchisima informaci�n irrelevante de fuera del cerebro, y
                % calcula su valor acumulado
                for M=10:50
                    su(M-9)=sum(j(M:50));
                end
                fprintf('.')
                % Obtiene el bin a partir del cual se registran intensidades mayores al 0.1% del valor acumulado anterior
                max_i=k(max(find(su>(su(1)*0.001)))+9);fprintf('.')
                % Se normaliza toda la imagen a 1-0 con este valor
                stack=stack./max_i;fprintf('.')

                stack(stack>1)=1;fprintf('.')
                stack(stack<0.001)=0;fprintf('.')
            case 2
                if regexp(brain(i).name(end-7:end-4),bnamxml(i).name(end-7:end-4))
                    name_xml=bnamxml(i).name;
                else
                    posicion=regexp(bnames(i).name,'PT');
                    posicion2=regexp(bnames(i).name,'_');

                    name_xml=[bnames(i).name(1:posicion-1) bnames(i).name(posicion+3:posicion2(end-3))  bnames(i).name(posicion2(end-1)+1:end-4)];
                    name_xml(end+1:end+4)=('.xml');
                end
                inform='info.xml';
                copyfile([directorio '\' name_xml],inform)
                inf(i)=xml_read(inform);fprintf('.')
                delete(inform);

                clear name_xml

                %%
            case 3

                if ~isempty(strcmp(regexp(brain(i).name,'NOR','match'),'NOR')==1)
                    inf(i)=0;
                elseif ~isempty(strcmp(regexp(brain(i).name,'DTA1','match'),'DTA1')==1)
                    inf(i)=1;
                elseif ~isempty(strcmp(regexp(brain(i).name,'DTA2','match'),'DTA2')==1)
                    inf(i)=2;
                elseif ~isempty(strcmp(regexp(brain(i).name,'DTA3','match'),'DTA3')==1)
                    inf(i)=3;
                end


        end
    end
    fprintf('loaded! %d\n',i)
    %    stack(isnan(stack))=0;fprintf('.')
    stack=reduce_interp(stack,VS);
    stack_all(i,:,:,1:size(stack,3))=stack;
end
fprintf('loaded! \n')
%% Normalizaci�n en intensidad


