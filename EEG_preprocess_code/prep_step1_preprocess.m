%% orgnaize the data files 

clear all;close all; clc;
cd .. % back to the uper folder
current_folder=pwd;

%%  step1 filter the EEG file, it is quite time costing!!! save the file for later use
tic % start timing

data_folder=[current_folder,'\data_exp']; % find the EEG data
save_folder=[current_folder,'\temp_file']; % create the destination ahead
cd(data_folder);

sbj_pool=[2:9 11:32]; % the sbjs to use

for sbji=1:length(sbj_pool)
    
    sbj_num=sbj_pool(sbji);
    
    filename=['sub',num2str(sbj_num),'.cnt'];
    
    EEG = pop_loadcnt(filename , 'dataformat', 'auto', 'memmapfile', '');
    
   
    % add channel location file
    EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    
    % filter the EEG data
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',50,'plotfreqz',1);
      
    % save the dataset for temperary, since the filter is time costing.
    EEG = pop_saveset( EEG, 'filename',['sub',num2str(sbj_num),'_filtered.set'],'filepath',save_folder);
    
    EEG=[];
end


%% step 2 synchronize the EEG and Eye Tracking data
tic
cd(save_folder);

% sbj 28 is different for sampling error should be
% handled differntly
sbj_pool=[2:9 11:32];

for sbji=1:length(sbj_pool)
    
    sbj_num=sbj_pool(sbji);
    
    EEG=pop_loadset(['sub',num2str(sbj_num),'_filtered.set']);
    
    % parse the data
    EyeData_source=[current_folder,'\data_asc\sub',num2str(sbj_num),'.asc']
    
    EyeData_tmp=[save_folder,'\sub',num2str(sbj_num),'.mat'];
    ET = parseeyelink(EyeData_source,EyeData_tmp,'Sent MYKEYWORD');
            
    
    
    if sbj_num==28 % sampling rate=2000
        load('sub28.mat');
        idx_c=unique(data(:,1));
        [~,position]=ismember(idx_c,data(:,1));
        data=data(position,:);
        save('sub28.mat','data','-v6','-append');
    end

    % start the synchronization
    EEG = pop_importeyetracker(EEG,['sub',num2str(sbj_num),'.mat'],[100 200] ,[2 3] ,{'R-GAZE-X' 'R-GAZE-Y'},1,1,0,1,4);
    
    saveas(gcf, fullfile([save_folder,'\figures'], ['sub',num2str(sbj_num),'_sync_plot', '.png']));
    close gcf;
    EEG = pop_saveset( EEG, 'filename',['sub',num2str(sbj_num),'_synchronized.set']);
    EEG=[];
end
toc

%% step 3 prepare for ICA training
tic
cd(save_folder);
sbj_pool=[2:9 11:32];

for sbji=1:length(sbj_pool)
    
    sbj_num=sbj_pool(sbji);
    EEG=pop_loadset(['sub',num2str(sbj_num),'_synchronized.set']);
    
    % find the pairs of each start and end
    idx1=find(strcmp({EEG.event.type},'100'));
    idx2=find(strcmp({EEG.event.type},'200'));
    
    idx=[idx1' idx2'];
    ts=[];
    for i=1:size(idx,1)
        ts=[ts;EEG.event(idx(i,1)).latency-100 EEG.event(idx(i,2)).latency+100]; % add 100 point around the start and end event
    end
    EEG = pop_select( EEG, 'point',ts);
    
    % only use the above selected time range to do the ica
    
    % before runing ICA, eye check the quality of signal and refer to the
    % following instruction.
    % http://arnauddelorme.com/ica_for_dummies/
    % https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline
    % https://blog.csdn.net/weixin_42750769/article/details/81136972
    
    %Create copy of data used as training data and high pass filter it
    fprintf('\nCreating optimized ICA training data...')
    
    %Set up the constants
    HIPASS = 1;                  %Filter's passband edge (in Hz).
    Resample_rate=250;
    OW_FACTOR = 0.3;             %Value for overweighting of SPs (0.3 = add spike potentials corresponding to 30% of original data length)
    REMOVE_EPOCHMEAN = true;     %Mean-center the appended peri-saccadic epochs.
    
    EEG2 = pop_resample( EEG, Resample_rate); % resample it to improve the runing speed
    EEG2 = pop_eegfiltnew(EEG2, 'locutoff',HIPASS);
    
    %Overweight spike potentials
    %Repeatedly append intervals around saccade onsets (-20 to +10 ms) to training data.
    EEG2 = pop_overweightevents(EEG2,'R_saccade',[-0.02 0.01],OW_FACTOR,REMOVE_EPOCHMEAN);  %This has a known bug related to the remove mean and new versions of EEGLAB, load most current version of EYE-EEG from github to have a patched version.
    
    EEGch=[1:62]; % (include M1 and M2 to do the ica)
    EEG2 = pop_runica(EEG2, 'icatype', 'runica', 'extended',1,'interrupt','on','chanind',EEGch);
    
    % transfer the weight to original data set
    EEG.icachansind=EEG2.icachansind;
    EEG.icasphere=EEG2.icasphere;
    EEG.icaweights=EEG2.icaweights;
    EEG.icawinv=EEG2.icawinv;
    clear EEG2;
    eeglab redraw;
    pop_topoplot(EEG, 0, [1:20] ,['sub',num2str(sbj_num),'_ica_plot'],[4 5] ,0,'electrodes','off');
    saveas(gcf, fullfile([save_folder,'\figures\ICA'], ['sub',num2str(sbj_num),'_ica_plot', '.png']));
    close gcf;
    EEG = pop_saveset( EEG, 'filename',['sub',num2str(sbj_num),'_ica.set']);
    EEG=[];
end
toc
% end of ica running

%% step 4 remove bad component

sbj_pool=[2:9 11:32];

%------------------------------caution!!!----------------------------
% the below idx of component for each subject was re-checked manually by melinna and the indexs of
% components should be replaced  once the ICA has been re-run.
% the to be removed component include definitely blinks, horizontal eye
% movement and muscle activity

tic
close all;
EEG=[];ALLEEG=[];CURRENTSET=[];


for sbji=1:length(sbj_pool)
    sbj_num=sbj_pool(sbji);
    EEG=pop_loadset(['sub',num2str(sbj_num),'_ica.set']);
    EEG = pop_iclabel(EEG, 'default');
       
    EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;0.8 1;0.8 1;0.8 1;NaN NaN]);                     
    comp2rm=find(EEG.reject.gcompreject==1);
    
    EEG=pop_subcomp(EEG,comp2rm);
    EEG = pop_saveset( EEG, 'filename',['sub',num2str(sbj_num),'_ica_pruned.set']);
    EEG=[];ALLEEG=[];CURRENTSET=[];
end
toc

