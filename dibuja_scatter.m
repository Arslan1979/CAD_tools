function [dibu]=dibuja_scatter(featv,labels,num1,num2,nombres)
figure
plot(featv(labels==0,num1),featv(labels==0,num2),'*')
hold on
plot(featv(labels==1,num1),featv(labels==1,num2),'+m')
plot(featv(labels==2,num1),featv(labels==2,num2),'+r')
plot(featv(labels==3,num1),featv(labels==3,num2),'+g')
legend('control','normal','PD','noPD')
if exist('nombres','var')
    for i=1:numel(labels)
        text(double(featv(i,num1)),double(featv(i,num2)),nombres{i})
    end
end
hold off
dibu=1;
