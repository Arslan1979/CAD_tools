
a=(dir('./t1_f*'));%a=(dir)
for j=1:44
    if a(j).isdir
    cd(a(j).name);
    else
        continue
    end
nam=dir('r*.nii');
nam2=dir('s*.nii');
if isempty(nam), cd ..; continue;  end
stack=niftiread(nam.name);
datae=niftiread(nam2.name);
stack_all(j,:,:,:)=double(stack.img);
data{j}=datae.hdr.hist.descrip;
cd ..

clear stack
end
%save('1-1.mat','stack_all');