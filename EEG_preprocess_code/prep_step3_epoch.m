%% prepare for epochs
clear all; close all;clc;
cd ..

cd([pwd,'\temp_file'])
load('sentence_prep_result.mat');
load('sent_id_order.mat');

[aa]=xlsread('sentid_from_EM.csv');

sbj_pool=[2:9 11:32];

bad_summary=[];

for sbji=1:length(sbj_pool)
    ALLEEG=[];EEG=[];CURRENTSET=[];
    
    sbj_num=sbj_pool(sbji);
    EEG = pop_loadset('filename',['sub',num2str(sbj_num),'_bad_checked.set']);
    EEG = pop_select( EEG, 'nochannel',{'M1' 'M2' 'CB1' 'CB2' 'HEO' 'VEO' 'EKG' 'EMG' 'R-GAZE-X' 'R-GAZE-Y'});
 
   [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % only want the event with fixations
    
    ss={EEG.event.type};
    z=find(strcmp(ss,'R_fixation'));
    EEG.event=EEG.event(z);
    
    % do not want the empty cells
    cc={EEG.event.char};
    z=find(cellfun(@isempty,cc));
    EEG.event(z)=[];
    
    % sort the fixation
    %--------------------only want the first pass fixation and ignore the
    %second and more
    
    all_char={EEG.event.char};
    
    sent_id_all=[EEG.event.trial_sent_id];
    sent_id=unique(sent_id_all,'stable');
    
    idx_final=[];
    
    for i=sent_id
        indx=[];
        idx_tmp=find(sent_id_all==i);
        char2use=all_char(idx_tmp);
        char2test=uniqueStrCell(char2use);
        
        for ni=1:length(char2test);indx=[indx;min(find(strcmp(char2use,char2test{ni})))];end;
        indx=sort(indx) ;
        idx_final=[idx_final idx_tmp(indx)];
        
    end
    
    EEG.event=EEG.event(idx_final);
    % finish the first fixation sorting
    
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    
    %%  PART 1  epoch for target words
    
    idx_tmp=[];
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).whether_target,'HF')
            EEG.event(i).type='HF';
            idx_tmp=[idx_tmp;i];
        end
        
        if strcmp(EEG.event(i).whether_target,'LF')
            EEG.event(i).type='LF';
            idx_tmp=[idx_tmp;i];
        end
        
    end
    
    EEG = pop_epoch( EEG, {  'HF'  'LF'  }, [-0.2         0.8], 'newname', 'target epochs', 'epochinfo', 'yes');
    
    % reject the bad epochs by two means: extrem value and the trend caculation
    
    threshold=100;
    
    [EEG idx1] = pop_eegthresh(EEG,1,[1:60] ,-threshold,threshold,-0.2,0.799,1,0);
    EEG = pop_rejtrend(EEG,1,[1:60] ,1000,50,0.3,2,0,0);
    idx2=find(EEG.reject.rejconst);
    rmtrial=[idx1 idx2];
    
    bad_ratio=length(rmtrial)/EEG.trials;
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off');
    
    fprintf('The following trials have been marked for rejection\n');
    fprintf([num2str(rmtrial) '\n']);
    fprintf('the bad ratio is % %4.2f\t',bad_ratio*100);
    % remove bad_epochs
    
    EEG=pop_rejepoch(EEG,rmtrial,0);
    
    bad_summary=[bad_summary;sbj_num 1 bad_ratio];
    
    EEG=pop_saveset(EEG,'filename',['sub',num2str(sbj_num),'_epochs_test1']);
    
end

