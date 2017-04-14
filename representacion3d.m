%% Representación de la superficie de decisión del clasificador 
figure
plot3(g(NORMAL,1),g(NORMAL,2),g(NORMAL,3),'b*'); hold on;
h= plot3(g(DTA,1),g(DTA,2),g(DTA,3),'rs'); hold off;
xlabel('First Component'); ylabel('Second Component'); zlabel('Third Component');
grid;
hAxis = get(h,'parent');
lims = axis(hAxis);

N=100;
[Xc, Yc, Zc]= meshgrid(linspace(lims(1),lims(2),N),linspace(lims(3),lims(4),N),linspace(lims(5),lims(6),N));
output= zeros(N,N,N);

type = 'rbf';


tr_data= g(:,[ 1 2 3 ]);


svmStruct = svmtrain(tr_data, tr_labels, 'Kernel_Function', type);
%net = nn_ff_train(tr_data, train_labels,1);

for xc=1:N
    for yc=1:N
        for zc=1:N
            % Bayes
%              [label,err,posteriori] = classify ([Xc(xc,yc,zc) Yc(xc,yc,zc) Zc(xc,yc,zc)], tr_data, train_labels,type); % Bayes
%              output(xc,yc,zc) = posteriori(1);
            % SVM
          output(xc,yc,zc) = svmclassify (svmStruct, [Xc(xc,yc,zc) Yc(xc,yc,zc) Zc(xc,yc,zc)]);
            % FF
%           output(xc,yc,zc) = sim (net, [Xc(xc,yc,zc) Yc(xc,yc,zc) Zc(xc,yc,zc)]')>0.5;
        end
    end
end

figure
plot3(g(NORMAL,1),g(NORMAL,2),g(NORMAL,3),'b*'); hold on;
h= plot3(g(DTA,1),g(DTA,2),g(DTA,3),'rs');
xlabel('First Component'); ylabel('Second Component'); zlabel('Third Component');
hAxis = get(h,'parent');
lims = axis(hAxis);
% hold on
% [C,h] = contour3(output,0.5);
% set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
% colormap cool


hpatch = patch(isosurface(Xc,Yc,Zc,output,0.5));
isonormals(Xc,Yc,Zc,output,hpatch)
set(hpatch,'FaceColor','green','EdgeColor','none')
view([-55,10]);
axis tight
camlight left; 
set(gcf,'Renderer','zbuffer'); 
lighting phong;
grid; title('SVM Polynomial')
hold off;


