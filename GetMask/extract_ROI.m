function [x,masdeunaroi]=extract_ROI(dire,name)
masdeunaroi=0;
xm=xml_read([dire filesep name ]);
slice_num=numel(xm.dict.array.dict);
for num=1:slice_num
    num_roi= xm.dict.array.dict(num).integer{2};
    situmid=strfind(xm.dict.array.dict(num).array.dict(1).array(2).string{1},',');
    nslices=numel(xm.dict.array.dict(num).array.dict(1).array(2).string);
    for i=1:nslices,
        xx(i,1)=str2num(xm.dict.array.dict(num).array.dict(1).array(2).string{i}(2:situmid-1));
        xx(i,2)=str2num(xm.dict.array.dict(num).array.dict(1).array(2).string{i}(situmid+1:end-1));
        
    end
    if num_roi>1
        masdeunaroi=1;
        for nroi=2:num_roi
            situmid=strfind(xm.dict.array.dict(num).array.dict(nroi).array(2).string{1},',');
            nslices(nroi)=numel(xm.dict.array.dict(num).array.dict(nroi).array(2).string);
            for i=1:nslices(nroi),
                xx(i+nslices(nroi-1),1)=str2num(xm.dict.array.dict(num).array.dict(nroi).array(2).string{i}(2:situmid-1));
                xx(i+nslices(nroi-1),2)=str2num(xm.dict.array.dict(num).array.dict(nroi).array(2).string{i}(situmid+1:end-1));
            end
        end
        
    end
    
    x(1:size(xx,1),1:2,xm.dict.array.dict(num).integer{1})=xx(1:end,1:2);
    clear xx
end

