function [data]=concadena(stack)

[Z Y X]=size(stack);
x=1;y=1;z=1;
cont=1;
data=zeros(Z*Y*X,1);
while z<Z
    while y<Y
        while x<X

            data(cont)=squeeze(squeeze(squeeze(stack(z,y,x))));
            x=x+1;
            cont=cont+1;
        end
        y=y+1;
        while x>1
            data(cont)=squeeze(squeeze(squeeze(stack(z,y,x))));
            x=x-1;
            cont=cont+1;
        end
        y=y+1;
    end
    z=z+1;
    fprintf .
    while y>1
        while x<X

            data(cont)=squeeze(squeeze(squeeze(stack(z,y,x))));
            x=x+1;
            cont=cont+1;
        end
        y=y-1;
        while x>1
            data(cont)=squeeze(squeeze(squeeze(stack(z,y,x))));
            x=x-1;
            cont=cont+1;
        end
        y=y-1;
    end
    z=z+1;
    fprintf .
    
end
fprintf('Fin! \n')
end