function [labels]= leer_labels(P,pacientes)
labels(1:P)=-1;
for p=1:P
    if strcmp(regexp(pacientes(p).name,'NOR','match'),'NOR')==1
        labels(p)=0;
    elseif strcmp(regexp(pacientes(p).name,'DTA1','match'),'DTA1')==1
        labels(p)=1;
    elseif strcmp(regexp(pacientes(p).name,'DTA2','match'),'DTA2')==1
        labels(p)=2;
    elseif strcmp(regexp(pacientes(p).name,'DTA3','match'),'DTA3')==1
        labels(p)=3;
    end
end
end