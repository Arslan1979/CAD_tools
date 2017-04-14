function [stack]=leer_DBT(ruta,jump)
 lis=dir([ruta filesep '*.IMA']);
        num=numel(lis);
        if num==0, return; end
        for i=1:26,
            comp_im= dicomread([ruta filesep lis(i).name]); 
            [x y]=size(comp_im);
            [x1 x2]=ndgrid(1:x,1:y);
            [xr1 xr2]=ndgrid(1:jump:x,1:jump:y);
            tdata=interp2(x2,x1,double(comp_im),xr2,xr1);fprintf .
            stack1(i,1:size(tdata,1),1:size(tdata,2))=tdata;
        end
for i=27:27+25
            comp_im= dicomread([ruta filesep lis(i).name]); 
            [x y]=size(comp_im);
            [x1 x2]=ndgrid(1:x,1:y);
            [xr1 xr2]=ndgrid(1:jump:x,1:jump:y);
            tdata=interp2(x2,x1,double(comp_im),xr2,xr1);fprintf .
            stack2(i,1:size(tdata,1),1:size(tdata,2))=tdata;
        end

end