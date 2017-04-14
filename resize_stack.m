function [stack_spm]=resize_stack(img,str,method)
% Transforma imagenes segmentadas con DARTEL al tamaño de las normalizadas
% por spm. La orientación de la imagen debe ser igual que la que queda al
% guardarlas con la petra en un stack_All. method es el metodo de
% interpolación para reducir la imagen(ej. 'cubic', 'nearest')

vs = abs ([str.hdr.dime.pixdim(4) str.hdr.dime.pixdim(3) str.hdr.dime.pixdim(2)]);
stm=reduce_interp(img,1./vs,method);
if numel(size(img))>3
    stmc=stm(:,-51+72+2:85+72+2,-112+126+2:76+126+2,-78+90+2:78+90+2);
else
    stmc=stm(-51+72+2:85+72+2,-112+126+2:76+126+2,-78+90+2:78+90+2);
end
stack_spm=reduce_interp(stmc,2);
end