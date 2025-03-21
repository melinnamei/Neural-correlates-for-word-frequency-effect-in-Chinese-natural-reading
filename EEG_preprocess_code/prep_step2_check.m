%% step 1 mark bad channel and bad continous data
clear all;close all; clc;
cd .. % back to upper folder
current_folder=pwd;

data_folder=[current_folder,'\data_exp'];
save_folder=[current_folder,'\temp_file'];
cd(save_folder);

load('sentence_prep_result.mat'); 
[aa]=xlsread('sentid_from_EM.csv');% generated from EM process


tic % start timing


sbj_pool=[2:9 11:32];


for sbji=1:length(sbj_pool)
    
    sbj_num=sbj_pool(sbji);
    EEG=[];ALLEEG=[];CURRENTSET=[];        
    
    %% step 1 load the ica pruned data
    EEG = pop_loadset('filename',['sub',num2str(sbj_num),'_ica_pruned.set'])
    ind2use=find(strcmp({EEG.chanlocs.labels},'Trigger'));
    
    if ~isempty(ind2use)
        EEG = pop_select( EEG, 'nochannel',ind2use);
    end
    
    
      %% step2 have the dictionary file
    
    trial_sent_id=aa(find(aa(:,1)==sbj_num),3);% sent id in the exp
    trial_id=aa(find(aa(:,1)==sbj_num),2); % trial id in the corpus 
    condition=aa(find(aa(:,1)==sbj_num),5); %1   stands for high frequency condition, 2 for low frequency
    
    idx1=find(strcmp({EEG.event.type},'100'));% find the start
    idx2=find(strcmp({EEG.event.type},'200')); % find the end
    idx=[idx1' idx2'];
    idx=idx(trial_id,:);
    
    
    %% step3 search and add the event depending on eye tracking info
    
      condition_cell={'HF','LF'};       
      
    for triali=1:length(trial_sent_id)
        
        trial_idx=trial_sent_id(triali);% the sent trial id based on the EM recording
        idx_tmp=find([result.SentId]==trial_idx); % the sent trial id idx in dictionary
        
        for jj=idx(triali,1)+1:idx(triali,2)-1  % the loop of sentence in EEG
            count=0;
            
            EEG.event(jj).trial_sent_id=trial_idx; % give the sent id to EEG trial
            
            if strcmp(EEG.event(jj).type,'R_fixation')
                
                position_tmp=EEG.event(jj).fix_avgpos_x;
                
                for ti=1:length(idx_tmp)
                    
                    
                    if position_tmp<max(result(idx_tmp(ti)).gx_range)&&position_tmp>min(result(idx_tmp(ti)).gx_range)...
                            &&  strcmp(result(idx_tmp(ti)).whether_target,'no')
                        
                        EEG.event(jj).char=result(idx_tmp(ti)).char; % define the char of this fixation
                        EEG.event(jj).freq=result(idx_tmp(ti)).frequency; % add the frequency of this fixation
                        EEG.event(jj).char_position=result(idx_tmp(ti)).Position; % add the position of this position
                        EEG.event(jj).sent_length=result(idx_tmp(ti)).sent_length; % add the whole length value to this fixation
                        EEG.event(jj).whether_target=result(idx_tmp(ti)).whether_target;
                        
                    end % end the position searching
                    
                    if position_tmp<max(result(idx_tmp(ti)).gx_range)&&position_tmp>min(result(idx_tmp(ti)).gx_range)...
                            &&  ~strcmp(result(idx_tmp(ti)).whether_target,'no') && count==0
                        
                        EEG.event(jj).char=result(idx_tmp(ti)+condition(triali)-1).char; % define the char of this fixation
                        EEG.event(jj).freq=result(idx_tmp(ti)+condition(triali)-1).frequency; % add the frequency of this fixation
                        EEG.event(jj).char_position=result(idx_tmp(ti)).Position; % add the position of this position
                        EEG.event(jj).sent_length=result(idx_tmp(ti)).sent_length; % add the whole length value to this fixation
                        EEG.event(jj).whether_target=condition_cell{condition(triali)};
                        count=1;
                    end % end the position searching
                    
                    
                    
                end % end the within sentence searching
                
            end % end the comparison of R fixation
            
        end % end the within sentence searching within EEG trial
        
    end % end the whole EEG trial searching
    
    
     %% step 4 ------------------------Two purpose here--------------------
    % do not want any fixation shorter or longer than a criterion
    % do not want any fixation in the start and in the end
    fixation_no_use=[];
    shorter_than=50;
    longer_than=800;
    
    no_edge=4;% do not want these words in the start and end
    
    
    for tt=1:length(EEG.event);
        if strcmp(EEG.event(tt).type,'R_fixation');
            
            if EEG.event(tt).duration<shorter_than | EEG.event(tt).duration > longer_than
                fixation_no_use=[fixation_no_use;tt EEG.event(tt).duration];
            end
            
            if EEG.event(tt).char_position<no_edge | EEG.event(tt).char_position >[ EEG.event(tt).sent_length-no_edge+1]
                fixation_no_use=[fixation_no_use;tt EEG.event(tt).char_position];
            end
            
        end
    end
    
    EEG.event(fixation_no_use(:,1))=[];
    
    EEG=pop_saveset(EEG,'filename',['sub',num2str(sbj_num),'_tmp.set']);
    
end


%%
%----------------------------------------------------------------------------------------------------------------------------------------------
% -------------- ---------------------section 2 detect the bad burst and bad channels

% notice!!!---Here invovle some manualchecking of the channels and signal 
% notice!!!---Here is a very import part for the data cleanning

clear all; close all; clc;
tic
sbj_pool=[2:9 11:32];

% the following file was obtained with the aid of several algorith,
% especially the clean_artifacts, the PREP, the pop_rejchan, and finally
% determine by visual checking. That's a tough job.

[aa,bb,cc]=xlsread('bad_channels.xlsx');
 cc=cc(2:end,:);
  
for sbji=1:length(sbj_pool)
    
    
    sbj_num=sbj_pool(sbji);
    EEG=[];ALLEEG=[];CURRENTSET=[];     
    EEG=pop_loadset('filename',['sub',num2str(sbj_num),'_tmp.set']);            
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
            
    idx=find([cc{:,1}]==sbj_num);        
    bad_chan=cc{idx,3};
    reject_point=[cc{idx,4}];
    
    
    
    if ~isnan(reject_point)
        reject_point=str2num(reject_point);
        EEG = eeg_eegrej( EEG, reject_point);
        disp('-----------------prepare reject some bad points-----------------------');
    end
    
    if  ~isnan(bad_chan) 
      if  ~isnumeric(bad_chan);bad_chan=str2num(bad_chan);end
      
    EEG = pop_interp(EEG, bad_chan, 'spherical'); 
    disp('now interpolating');
    disp(bad_chan);
    end
    
    
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );                   
      
    EEG=pop_saveset(EEG,'filename',['sub',num2str(sbj_num),'_bad_checked.set']);
        
end

toc

