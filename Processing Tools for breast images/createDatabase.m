% Create machine learning database from mat files

X1=[]; X0=[];
 listamask={'1-4mask.mat' '1-10mask.mat' '1-12mask.mat' '1-13mask.mat' '1-14mask.mat' '2-1mask.mat' '2-7mask.mat'};
 listaimg={'1-4r.mat' '1-10r.mat' '1-12r.mat' '1-13r.mat' '1-14r.mat' '2-1r.mat' '2-7r.mat'};
 pathimg='/media/ialvarezillan/MyPassport/NME/';
 for i=1:numel(listaimg)
     load([pathimg listamask{i}]);
     load([pathimg listaimg{i}]);
     [~,maskt]=mascara(stack_all);
 SE=strel('cube',10);
 mask2=imclose(~maskt,SE);
 [stack_all,mask,mask2]=torax_segmentation(stack_all,'NME',mask,mask2);
 [x0,x1]=create_labelleddata(stack_all,mask,mask2);
 X1=[X1 x1];
 X0=[X0 x0];
 save([pathimg 'X0-' listaimg{i}],'x0')
 save([pathimg 'X1-' listaimg{i}],'x1')
 end
save([pathimg 'X1'],'X1')
save([pathimg 'X0'],'X0') 
 % 2-8 doesnt have the same size (29 temporal frames)
 %load('/media/ialvarezillan/MyPassport/NME/2-8mask.mat')
 %load('/media/ialvarezillan/MyPassport/NME/2-8r.mat')
 
