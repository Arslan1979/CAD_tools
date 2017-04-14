function [reduced_mask,reduced_newimg]=resize_delineatedcontour(imgfine,imgcoarse,mask)


jumpfx=  imgfine.hdr.hist.srow_x(1); jumpfy=  imgfine.hdr.hist.srow_y(3);jumpfz=imgfine.hdr.hist.srow_z(2);
jumpcx=imgcoarse.hdr.hist.srow_x(1); jumpcy=imgcoarse.hdr.hist.srow_y(3);jumpcz=imgcoarse.hdr.hist.srow_z(2);
fx=  imgfine.hdr.dime.dim(2); fy=  imgfine.hdr.dime.dim(4); fz=imgfine.hdr.dime.dim(3);
cx=imgcoarse.hdr.dime.dim(2); cy=imgcoarse.hdr.dime.dim(4); cz=imgcoarse.hdr.dime.dim(3);
offsetfx=  imgfine.hdr.hist.srow_x(4); offsetfy=  imgfine.hdr.hist.srow_y(4); offsetfz=imgfine.hdr.hist.srow_z(4);
offsetcx=imgcoarse.hdr.hist.srow_x(4); offsetcy=imgcoarse.hdr.hist.srow_y(4); offsetcz=imgcoarse.hdr.hist.srow_z(4);

rangefinex=(offsetfx+jumpfx):jumpfx:(offsetfx+jumpfx*fx);
rangefiney=(offsetfy+jumpfy):jumpfy:(offsetfy+jumpfy*fy);
rangefinez=(offsetfz+jumpfz):jumpfz:(offsetfz+jumpfz*fz);

rangecoarsex=(offsetcx+jumpcx):jumpcx:(offsetcx+jumpcx*cx);
rangecoarsey=(offsetcy+jumpcy):jumpcy:(offsetcy+jumpcy*cy);
rangecoarsez=(offsetcz+jumpcz):jumpcz:(offsetcz+jumpcz*cz);

[xi,yi,zi]=meshgrid(rangecoarsez,rangecoarsex,rangecoarsey);
reduced_newimg = interp3(rangefinez',rangefinex',rangefiney',double(imgfine.img),xi,yi,zi,'cubic',0);
reduced_mask = interp3(rangefinez',rangefinex',rangefiney',double(mask),xi,yi,zi,'linear',0);
% rangebigx=1*imgbig.hdr.dime.pixdim(2)-imgbig.hdr.hist.qoffset_x: imgbig.hdr.dime.dim(2)*imgbig.hdr.dime.pixdim(2)-imgbig.hdr.hist.qoffset_x;
% rangesmallx=1*imgsmall.hdr.dime.pixdim(2)-imgsmall.hdr.hist.qoffset_x: imgsmall.hdr.dime.dim(2)*imgsmall.hdr.dime.pixdim(2)-imgsmall.hdr.hist.qoffset_x;
% rangebigy=1*imgbig.hdr.dime.pixdim(3)-imgbig.hdr.hist.qoffset_y: imgbig.hdr.dime.dim(3)*imgbig.hdr.dime.pixdim(3)-imgbig.hdr.hist.qoffset_y;
% rangesmally=1*imgsmall.hdr.dime.pixdim(3)-imgsmall.hdr.hist.qoffset_y: imgsmall.hdr.dime.dim(3)*imgsmall.hdr.dime.pixdim(3)-imgsmall.hdr.hist.qoffset_y;
% rangebigz=1*imgbig.hdr.dime.pixdim(4)-imgbig.hdr.hist.qoffset_z: imgbig.hdr.dime.dim(4)*imgbig.hdr.dime.pixdim(4)-imgbig.hdr.hist.qoffset_z;
% rangesmallz=1*imgsmall.hdr.dime.pixdim(4)-imgsmall.hdr.hist.qoffset_z: imgsmall.hdr.dime.dim(4)*imgsmall.hdr.dime.pixdim(4)-imgsmall.hdr.hist.qoffset_z;
%
% rangebigx=(imgbig.hdr.dime.dim(2)*imgbig.hdr.hist.srow_x(1)+imgbig.hdr.hist.srow_x(4)): (imgbig.hdr.hist.srow_x(1)+imgbig.hdr.hist.srow_x(4));
% rangebigy=(imgbig.hdr.dime.dim(4)*imgbig.hdr.hist.srow_y(3)+imgbig.hdr.hist.srow_y(4)): (imgbig.hdr.hist.srow_y(3)+imgbig.hdr.hist.srow_y(4));
% rangebigz=-(imgbig.hdr.dime.dim(3)*imgbig.hdr.hist.srow_z(2)+imgbig.hdr.hist.srow_z(4)): -(imgbig.hdr.hist.srow_z(2)+imgbig.hdr.hist.srow_z(4));
%
% rangesmallx=(imgsmall.hdr.dime.dim(2)*imgsmall.hdr.hist.srow_x(1)+imgsmall.hdr.hist.srow_x(4)): (imgsmall.hdr.hist.srow_x(1)+imgsmall.hdr.hist.srow_x(4));
% rangesmally=(imgsmall.hdr.dime.dim(4)*imgsmall.hdr.hist.srow_y(3)+imgsmall.hdr.hist.srow_y(4)): (imgsmall.hdr.hist.srow_y(3)+imgsmall.hdr.hist.srow_y(4));
% rangesmallz=-(imgsmall.hdr.dime.dim(3)*imgsmall.hdr.hist.srow_z(2)+imgsmall.hdr.hist.srow_z(4)): -(imgsmall.hdr.hist.srow_z(2)+imgsmall.hdr.hist.srow_z(4));

% 
% for i=1:fy, rangefiney(i)=i*jumpfy+offsetfy;   end
% for i=1:fz, rangefinez(i)=i*jumpfz+offsetfz;   end
% 
% for i=1:cx, rangecoarsex(i)=i*jumpcx+offsetcx; end
% for i=1:cy, rangecoarsey(i)=i*jumpcy+offsetcy; end
% for i=1:cz, rangecoarsez(i)=i*jumpcz+offsetcz; end
% rangefine.x=rangefinex;rangefine.y=rangefiney;rangefine.z=rangefinez;
% rangecoarse.x=rangecoarsex;rangecoarse.y=rangecoarsey;rangecoarse.z=rangecoarsez;
% 
% resimgsmall=reduce_interp(imgcoarse.img,1./imgcoarse.hdr.dime.pixdim(2:4));
% resimgbig=reduce_interp(imgfine.img,1./imgfine.hdr.dime.pixdim(2:4));
% 
% 
% 
% begx=  rangecoarsex(1):jumpfx:rangefinex(1); endx=rangefinex(end):jumpfx:rangecoarsex(end) ;
% begy=  rangecoarsey(1):jumpfy:rangefiney(1); endy=rangefiney(end):jumpfy:rangecoarsey(end) ;
% begz=  rangecoarsez(1):jumpfz:rangefinez(1); endz=rangefinez(end):jumpfz:rangecoarsez(end) ;
% 
% resbigeq=zeros(size(resimgsmall));
% resbigeq(numel(begx)+1:(end-numel(endx)-1),numel(begz)+1:(end-numel(endz)-1),numel(begy)+1:(end-numel(endy))-1)=resimgbig;
% 
% if rangecoarse.x(1)<rangefine.x(1)
%     [~,begx]=min(abs(rangecoarse.x-rangefine.x(1)));
% else
%     [~,begx]=min(abs(rangefine.x-rangecoarse.x(1)));
%     sorbx=true;
% end
% if rangecoarse.x(end)>rangefine.x(end)
%     [~,endx]=min(abs(rangecoarse.x-rangefine.x(end)));
% else
%     [~,endx]=min(abs(rangefine.x-rangecoarse.x(end)));
%     sorex=true;
% end
% if rangecoarse.y(1)<rangefine.y(1)
%     [~,begy]=min(abs(rangecoarse.y-rangefine.y(1)));
% else
%     [~,begy]=min(abs(rangefine.y-rangecoarse.y(1)));
%     sorby=true;
% end
% if rangecoarse.y(end)>rangefine.y(end)
%     [~,endy]=min(abs(rangecoarse.y-rangefine.y(end)));
% else
%     [~,endy]=min(abs(rangefine.y-rangecoarse.y(end)));
%     sorey=true;
% end
% if rangecoarse.z(1)<rangefine.z(1)
%     [~,begz]=min(abs(rangecoarse.z-rangefine.z(1)));
% else
%     [~,begz]=min(abs(rangefine.z-rangecoarse.z(1)));
%     sorbz=true;
% end
% if rangecoarse.z(end)>rangefine.z(end)
%     [~,endz]=min(abs(rangecoarse.z-rangefine.z(end)));
% else
%     [~,endz]=min(abs(rangefine.z-rangecoarse.z(end)));
%     sorez=true;
% end
% newimg=zeros(size(resimgsmall));
% newimg(begx:endx,begz:endz,begy:endy)=resimgbig(:,:,:);
% reduced_newimg=reduce_interp(newimg,imgcoarse.hdr.dime.pixdim(2:4));