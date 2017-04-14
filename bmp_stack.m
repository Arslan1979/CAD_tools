function y= bmp_stack(stack,n,var)
% Dibuja Cerebrillos

% bmp_stack(stack,n) dibuja un cerebrillo en 'n' filas y ajusta el numero de
% slices por fila de manera q se dibuje todo el cerebro.
% Si el numero de filas no se especifica, el default es 1.
% stack ha de ser 3D, pero si se te olvida hacer squeeze, no
% pasa nada, te lo dibuja igual.
% Ademas, si es un stack que contiene muchos pacientes, te dibuja un slice
% de todos. En caso de que quieras un slice especial, entonces introduce
% var=1 para la primera dimension, var=2 segunda,... Por defecto var=0
if numel(size(stack))>3
    stack=squeeze(stack);
end
if nargin < 2
    n=floor(sqrt(size(stack,1)));
    var=0;
elseif nargin < 3
    var = 0;
end

if numel(size(stack))>3
    [nump s1 s2 s3]=size(stack);
    [so,var]=defso([s1 s2 s3],var);

    JPG= [ ];
    FILA= [ ];
    IMAGENES_POR_FILA= n;
    NUM_FILAS= floor(nump/IMAGENES_POR_FILA);
    contador= 0;

    NUM_IMAGENES= NUM_FILAS*IMAGENES_POR_FILA;
    for np=1:nump
        stackn(:,:,:)=squeeze(stack(np,:,:,:));
        while NUM_IMAGENES<nump
            IMAGENES_POR_FILA=IMAGENES_POR_FILA+1;
            NUM_IMAGENES= NUM_FILAS*IMAGENES_POR_FILA;
        end
        fila=0;
        %        for z=1:so(1)
        z=floor(so(1)/2);
        if var(1)==1
            R= squeeze(stackn(z,:,:));
        elseif var(1)==2
            R= squeeze(stackn(:,z,:));
        elseif var(1)==3
            R= squeeze(stackn(:,:,z));
            R=flipud(R);
        end

        %    R=imresize(I,20);
        FILA= [ FILA R ];
        contador= contador + 1;
        if contador==IMAGENES_POR_FILA
            JPG= [JPG ; FILA ];
            FILA = [ ];
            contador= 0;
            fila=fila+1;
        elseif and(np==nump,contador<IMAGENES_POR_FILA)
            while contador<IMAGENES_POR_FILA
                S=zeros(size(R));
                %    R=imresize(I,20);
                FILA= [ FILA S ];
                contador= contador + 1;
            end
            JPG= [JPG ; FILA ];
        end
    end


    %map= jet(100);
    figure
    imagesc(JPG);
    colorbar;
    axis('image');
    axis('off');
    %caxis([min(stack(:)) max(stack(:))]);
    %title('Precision map in SPECT images')
    %imwrite(JPG,map,Fichero,'bmp');


else

    [s1 s2 s3]= size(stack);

    [so,var]=defso([s1 s2 s3],var);

    JPG= [ ];
    FILA= [ ];
    IMAGENES_POR_FILA= floor(so(1)/n);
    NUM_FILAS= floor((so(1))/IMAGENES_POR_FILA);
    contador= 0;

    NUM_IMAGENES= NUM_FILAS*IMAGENES_POR_FILA;
    while NUM_IMAGENES<so(1)
        IMAGENES_POR_FILA=IMAGENES_POR_FILA+1;
        NUM_IMAGENES= NUM_FILAS*IMAGENES_POR_FILA;
    end
    fila=0;
    for z=1:so(1)
        if var(1)==1
            R= squeeze(stack(z,:,:));
        elseif var(1)==2
            R= squeeze(stack(:,z,:));
        elseif var(1)==3
            R= squeeze(stack(:,:,z));
            R=flipud(R);
        end

        %    R=imresize(I,20);
        FILA= [ FILA R ];
        contador= contador + 1;
        if contador==IMAGENES_POR_FILA
            JPG= [JPG ; FILA ];
            FILA = [ ];
            contador= 0;
            fila=fila+1;
        elseif and(z==so(1),fila==NUM_FILAS-1)
            while contador<IMAGENES_POR_FILA
                S=zeros(size(R));
                %    R=imresize(I,20);
                FILA= [ FILA S ];
                contador= contador + 1;
            end
            JPG= [JPG ; FILA ];
        end
    end


    %map= jet(100);
    figure('Color',[0.8 0.8 0.8])
    imagesc(JPG);
    colorbar;
    axis('image');
    axis('off');
    %map= jet(100);
    %caxis([-0.04 0.0427]);
    %title('Precision map in SPECT images')
    %imwrite(JPG,map,Fichero,'bmp');
end
y= 1;
end

function [res,b]=defso(a,b)

if b==0
    [res,b]=sort(a);
else
    res=a(b);
end

end
