listapac=dir;
listapacfol=listapac([listapac.isdir]);
for i=3:numel(listapacfol)
    cd(listapacfol(i).name)
    niname=dir('nii*');
    cd(niname.name)
    list=dir;
    listap=list([list.isdir]);
    listap(3).name
    cd(listap(3).name)
    nimg=dir('*.nii');
    imgfine=niftiread(nimg(1).name);
    cd('..')
    listap(end).name
    cd(listap(end).name)
    nimg=dir('*.nii');
    imgcoarse=niftiread(nimg(1).name);
    cd('..')
    cd('..')
    xmlfile=dir('*.xml');
    try
    [y,x,reduced_mask]=create_ROImask(imgfine, xmlfile.name, imgcoarse);    

    save([num2str(i) 'mask'],'y','x','reduced_mask')
    catch
        fprintf(['Problema con el paciente' num2str(i)])
    end
    cd('..')
end