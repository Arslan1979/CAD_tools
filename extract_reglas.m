function [rules]=extract_reglas(datos,min_conf,min_sup)


[rules]=perfMining(datos,min_conf,min_sup,2,[],[],true);

end

%different functions to perform mining then calls displayRules
function [final_rulesmc]=perfMining(file_data,min_confidence,min_support,sup_type,LHS_goal,RHS_goal,multi)

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
final_rulesmc=[];

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
        if and((max_length > 2),multi)
            temp_rules = genMultCand(file_data,new_candidates,max_length,min_support);
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
        %% Remove rules<min_conf
        
        for i=1:numel(final_rules)
            for j=1:3
                final_rulesmc{i}{j}=final_rules{i}{j}(final_rules{i}{4}>min_confidence,:);
                final_rulesmc{i}{4}=final_rules{i}{4}(final_rules{i}{4}>min_confidence);
            end 
        end
        
        
        %------------------------------------------------------------
        fprintf('Mining completed.');
        
        

        %Order rules as specified by user removing below min_confidence
        %rules for each set of rules starting with 1LHS & format for displaying
        %         empty_flag = 1;
        %         for no = 1:size(final_rules,2)
        %             if ~isempty(final_rules{no})
        %                 ordered_rules{no} = orderRules(final_rules{no}{1},final_rules{no}{2},final_rules{no}{3},final_rules{no}{4},min_confidence);
        %                 if ~isempty(ordered_rules{no})
        %                     empty_flag = 0;
        %                 end
        %             end
        %         end
        %
        %         %If no rules have survived set ordered_rules to empty
        %         if empty_flag == 1
        %             ordered_rules = [];
        %         end

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
% if sup_type == 2
%     min_support = round((min_support*100)/no_sets);
%     sup_str = num2str(min_support);
%     min_support = strcat(sup_str,'%');
% end

%Display the final ordered rules with mining report data
%displayRules(ordered_rules,candidates,min_support,min_confidence,time_taken,file_name,no_sets,method_summary);

%End----------------------------------------------------------------------
end


%-------------------------------------------------------------------------------------
%ARMADA - Association Rule Mining And Deduction Analysis
%Desciprtion:	Data Mining Tool for extraction of association rules and analysis
%					of deduction methods.
%Author& 
%Copyright: 	James Malone
%Date:			14/04/03
%Modified:      18/02/11
%Version:		1.4
%-------------------------------------------------------------------------------------

%-------------------------------------------------------------------------

%Function to generate 3 and more item sets
function rules = genMultCand(file_data,new_candidates,max_length,min_support)

%Initiate variables
temp_cand=[1];
i = 2;
rules{1} = 0;

%While there are still candidates to generate rules from and max length 
%of rules has not been reached
while (~isempty(temp_cand) & i ~= max_length)
    
   %For each size of rule to maximum length of data set
   for i=3:max_length
		cand_length = size(new_candidates,1);
      next_elem = 1;
      temp_cand = [];
      %For each item in new_candidates up to second last entry
      for j=1:(cand_length - 1)
         %For each item in new_candidates after new_candidates(j)
         for k=(j+1):cand_length
            %Initiate macth to 0 which is no match found
            match = 0;
            %For each item in an entry up to second last one
            for l=1:(i-1)
               %For each item in an entry up to second last one
               for m=1:(i-1)
                  %If items match then increment match variable
                  if new_candidates(j,l) == new_candidates(k,m)
               		match = match+1;
                     %If matches are enough to form a new rule
                     if match == (i-2)
								possible_candidates = union(new_candidates(j,:),new_candidates(k,:));
                        %Ensure possible_candidate is of correct size, i.e. that there aren't 
                        %too many matches in unified rule which would reduce size
                        if size(possible_candidates,2) == i
                         	temp_cand(next_elem,:) = union(new_candidates(j,:),new_candidates(k,:));  
                        	%Order line using sort----------------------
               				temp_cand(next_elem,:)=sort(temp_cand(next_elem,:));
                           next_elem = next_elem + 1;
                        end
                        m=(i-l); %exit loop now
                        l=(i-1); %breaks out of next for loop as well
                    end 
            	   end
         		end
            end
         end
      end

      %remove duplicate rules
      if ~isempty(temp_cand) %If possible new candidates set is not empty
         temp_cand = unique(temp_cand,'rows'); %Remove any duplicates
         new_candidates = temp_cand;
         
         %Now count instances of new candidates-------------
         clear count;
         new_instance = 0;
         for z = 1:size(new_candidates,1)
   			count(z) = countInstance(new_candidates(z,:),file_data);
            if count(z) >= min_support
               new_instance = 1;
            end
         end
         %-------------------------------------------------
         
         %Following the count, check to see if there any new rules over
         %minimum spec, otherwise halt the mining
         if new_instance == 0
            return
         else
         %Else, remove all rules with < min_coverage-------------
			rules{(i-2)} = removeRules(new_candidates,min_support,count,i);
         %Remove counts from end of array for next comparisons
         clear new_candidates;
         new_candidates = rules{i-2}(:,1:i);
         end
         %-------------------------------------------------
         
      else
         %no more candidates - break out of for loop
   		return
      end 
      fprintf('Generated next set %g out of %g\n',i,max_length);
	end
end

%End----------------------------------------------------------------------
end