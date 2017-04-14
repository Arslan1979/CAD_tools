function [res]=reglas_asociacion_tra(data,labels,min_confidence,min_support,LHS_goal,RHS_goal) %comp_size,jump,act_th,

comp_size=1;
jump=2;
act_th=128;
nfolds=41;
act_c_th=.89; %proporcion de voxeles activados en una region para considerarla activada
rulefrac_th=.85; %proporcion de reglas cumplidas para considerar un sujeto como normal
cp=classperf(labels>0); fprintf .
normales=(labels==0)';
ad=(labels>0)';
K=numel(normales);
indices=(1:K);

indi=find(normales);
indi2=find(ad);
K2=sum(ad);
indices2 = crossvalind('Kfold',K2,numel(indi)); fprintf .

sm= (mean(data(normales,:,:,:)));
data_mask= double(sm>act_th);
res.rules_satisfied(1:K,1)=0;
res.test_set=zeros(K,K);
[regions ]= sel_activated_regions(data_mask,data,jump,comp_size,act_th,act_c_th);
for p=1:numel(indi)
    test_ad(1:K)=0;
    test_n = (indices == indi(p)); train = ~test_n;
    test_ad(indi2(indices2 == p))=1;
    test=or(test_ad,test_n);
        tr_nor_labels=and(normales,train');
        tr_ad_labels=and(ad,train');
        [rules_nor]=performMining(regions(tr_nor_labels,:),min_confidence,min_support,2,LHS_goal,RHS_goal);
        rulesnor(:,1)=rules_nor{1}{1};
        rulesnor(:,2)=rules_nor{1}{2};
        [rules_ad]=performMining(regions(tr_ad_labels,:),min_confidence,min_support,2,LHS_goal,RHS_goal);
        rulesad(:,1)=rules_ad{1}{1};
        rulesad(:,2)=rules_ad{1}{2};  
        [rulesf]=nor_transactions(rulesnor,rulesad);
        [rules_satisfied]= eval_patient_rules(rulesf,regions(test,:));
    classes=rules_satisfied<rulefrac_th*max(rules_satisfied(:));
     if isempty(rules_satisfied)
         res.rules_satisfied(test,:)=0;
     else
         res.rules_satisfied(test,:)=rules_satisfied;
     end
         res.test_set(test,:)=repmat(test,[sum(test) 1]);
        res.rules(p,:,:)=rulesf;
    clear rulesf
    classperf(cp, double(classes),test,'Positive', 1, 'Negative', 0);
end

res.component_size=comp_size;
res.grid_space=jump;
res.Threshold=act_th;
res.results=cp;
res.RHS_goal=RHS_goal;
res.LHS_goal=LHS_goal;
res.min_confidence=min_confidence;
res.min_support=min_support;
end

function [rulesf]=nor_transactions(rulesnor,rulesad)

numrn=size(rulesnor,1);
numra=size(rulesad,1);
cont=1;
rulesf=[];
for i=1:numrn
    for j=1:numra
        ok=rulesnor(i,:)==rulesad(j,:);
        if sum(ok==2)
            rulesf(cont,:)=rulesnor(i,:);
            cont=cont+1;
        end
    end
end


end

function [ regions ]= sel_activated_regions(data_mask,data,jump,comp_size,act_th,act_c_th)
[P Z Y X]=size(data);
tr_data_square=zeros([Z Y X]);
tr_data_square(1:comp_size,1:comp_size,1:comp_size)=1; fprintf .

regions(1:P)=0;
for p=1:P
    counter=1;
    for cir3=1:jump:Z
        for cir2=1:jump:Y
            for cir1=1:jump:X
                cir=[cir3-1 cir2-1 cir1-1];
                tr_data_sq=circshift(tr_data_square,cir);
                indexado=find(tr_data_sq(:)>0 & data_mask(:)>0);
                if numel(indexado)==comp_size*comp_size*comp_size
                    if sum(data(p,indexado)>=act_th)>=act_c_th*numel(indexado)
                        regions(p,counter)=sub2ind([Z Y X],cir3,cir2,cir1) ;
                        counter=counter+1;
                    end
                end
            end
        end
        fprintf .
    end
end
end

function [rules_satisfied]= eval_patient_rules(rules,regions)

P= size(regions,1);
num_rules= size(rules,1);
rules_satisfied= zeros(P,1);
for p=1:P
    for r=1:num_rules
        if and(find(regions(p,:)==rules(r,1)),find(regions(p,:)==rules(r,2)))
            rules_satisfied(p)= rules_satisfied(p)+1;

        end
    end
end
end

%different functions to perform mining then calls displayRules
function [final_rules]=performMining(file_data,min_confidence,min_support,sup_type,LHS_goal,RHS_goal)

%Start timer
%tic;

%If min support is as percentage convert to number for calc.
if sup_type == 2
    no_sets = size(file_data,1);
    min_support = (no_sets/100)* min_support;
end

%Sort stored file to increase speed of mining----------------
no_sets = size(file_data,1);
max_length = size(file_data,2);
for a = 1:no_sets
    file_data(a,:) = sort(file_data(a,:));
end
%------------------------------------------------------------

%Initiate variables in case an error occurs during try statement
%because they are used later in program
candidates = 0;
ordered_rules = [];

%Perform error check to see if file_data is empty - if it is set
%variables and blank and report, otherwise begin mining process
if (~isempty(file_data))
    try
        fprintf('Beginning mining...\n')

        %Get first elements to begin comparisons - read in first line
        candidates = readFirstLine(file_data,max_length);
        %------------------------------------------------------------

        %Count instances of one set----------------------------------
        candidates = genOneCand(file_data,candidates,no_sets,max_length,min_support);
        cand_length = size(candidates,1);
        %If there are no candidates or only 1 then halt mining, as there
        %will be no rules from only one item
        if (candidates == 0 | cand_length == 1)
            fprintf('No rules');
            return;
        end
        %------------------------------------------------------------

        %For generating 2 item sets----------------------------------
        rules{1} = genTwoCand(file_data,candidates,cand_length,min_support);
        %Remove counts from end of array for next comparisons if there are any
        if (rules{1} ~= 0)
            new_candidates = rules{1}(:,1:2);
        else
            %Break out of loop if there are no two LHS rules because possible
            %RHS values do not need to be generated
            return;
        end
        %------------------------------------------------------------

        %For generating 3 and more item sets-------------------------
        if (max_length > 2)
            temp_rules = genMultiCand(file_data,new_candidates,max_length,min_support);
            %Perform initial test to see if temp_rules has been added to, and therefore
            %there are new rules to add and if so concatenate rules into rules variable
            if temp_rules{1} ~= 0
                rules = cat(2,rules,temp_rules);
            end
        end
        %------------------------------------------------------------
        fprintf('Finished Generating Rules:\n');

        %Generate rule variants for minimum support------------------
		fprintf('Beginning generation of rule variants..\n');
      %If any goals have been defined
      if ~isempty(RHS_goal) | ~isempty(LHS_goal)
         final_rules = genRuleVariantsWithGoal(rules,candidates,min_confidence,RHS_goal,LHS_goal);
      else   
         final_rules = genRuleVariants(rules,candidates,min_confidence);
      end   
      %------------------------------------------------------------
      fprintf('Mining completed.');	

        %Order rules as specified by user removing below min_confidence
        %rules for each set of rules starting with 1LHS & format for displaying
        empty_flag = 1;
        for no = 1:size(final_rules,2)
            if ~isempty(final_rules{no})
                ordered_rules{no} = orderRules(final_rules{no}{1},final_rules{no}{2},final_rules{no}{3},final_rules{no}{4},min_confidence);
                if ~isempty(ordered_rules{no})
                    empty_flag = 0;
                end
            end
        end

        %If no rules have survived set ordered_rules to empty
        if empty_flag == 1
            ordered_rules = [];
        end

    catch
        lasterr
        fprintf('WARNING: Error occured while mining rules\n');
        %Set ordered_rules to empty, indicating an error to later functions
        ordered_rules = [];
    end
end

%Finish timing the mining process
%time = clock;
%time_taken = toc

%If min_sup is perc, convert back to perc from numb and add % sign on end
if sup_type == 2
    min_support = round((min_support*100)/no_sets);
    sup_str = num2str(min_support);
    min_support = strcat(sup_str,'%');
end

%Display the final ordered rules with mining report data
%displayRules(ordered_rules,candidates,min_support,min_confidence,time_taken,file_name,no_sets,method_summary);

%End----------------------------------------------------------------------
end