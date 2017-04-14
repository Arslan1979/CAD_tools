function [stack_all,labels]= read_bmp(path,VS)

directorios=dir(path);
s=numel(directorios)-2;
FILES= '*.bmp';

for i=1:s
    Files= dir([ path '\' directorios(i+2).name '\' FILES ]);
    Nfiles= length(Files);
    if ~isempty(strcmp(regexp(directorios(i+2).name,'NOR','match'),'NOR')==1)
        labels(i)=0;
    elseif ~isempty(strcmp(regexp(directorios(i+2).name,'DTA1','match'),'DTA1')==1)
        labels(i)=1;
    elseif ~isempty(strcmp(regexp(directorios(i+2).name,'DTA2','match'),'DTA2')==1)
        labels(i)=2;
    elseif ~isempty(strcmp(regexp(directorios(i+2).name,'DTA3','match'),'DTA3')==1)
        labels(i)=3;
    end
clear stack
    for file=1:Nfiles
        I= imread([ path '\' directorios(i+2).name '\' Files(file).name ]);
        stack(file,:,:)= I;
    end
    fprintf('loaded! %d\n',i)
    stack=reduce_stack(stack,VS);
    stack_all(i,:,:,:)=stack;
end