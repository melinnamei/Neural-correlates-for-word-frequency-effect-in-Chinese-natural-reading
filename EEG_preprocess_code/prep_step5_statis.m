%% version 2 is for corpus analysis
clear all;close all;clc;
cd ..

cd([pwd,'\temp_file']);
sbj_pool=[2:9 11:32];

result=[];
% the time window that I am interested

for sbji=1:length(sbj_pool)
    ALLEEG=[];EEG=[];CURRETSET=[];
    sbj_num=sbj_pool(sbji);
    EEG = pop_loadset('filename',['sub',num2str(sbj_num),'_epochs_test1.set']);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    EEG = pop_rmbase( EEG, [-100 0] ,[]);% baseline correction
    EEG = pop_reref( EEG, []);
    
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 2,'overwrite','on','gui','off' );
    
    
    for epoi=1:length(EEG.epoch)
        id_tmp=find(cell2mat(EEG.epoch(epoi).eventlatency)==0);% get the id of the onset event
        tmp{epoi}=EEG.epoch(epoi).eventtype{id_tmp};
    end
    idx_HF_epoch=find(strcmp(tmp,'HF'));
    idx_LF_epoch=find(strcmp(tmp,'LF'));
    
    EEG = pop_selectevent( EEG, 'epoch',[idx_HF_epoch] ,'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off','setname','HF');
    
    EEG=ALLEEG(2);
    EEG = pop_selectevent( EEG, 'epoch',[idx_LF_epoch] ,'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off','setname','LF');
    
    for condition=1:2
        EEG=ALLEEG(condition+2);  % index of EEG ; the third is high frequency, the forth is low frequency
        % get the componet by different time window
        point_vol=[];
        for time_pi=1:length(EEG.times)
            point_vol=mean(EEG.data,3);
        end
        result=[result; repmat([sbj_num condition],size(point_vol,1),1) [1:size(point_vol,1)]' point_vol ]; % high code 1 in second colum
    end
end

header={'subjectid';'condition';'elec'}';
header(4:1003)=num2cell(EEG.times);
ff=[header; num2cell(result)];
writetable(cell2table(ff),'EEG_result_point_by_point.csv', 'WriteVariableNames',0);
save  EEG_result_point_by_point result;

% colum 1 sbj_num
% colum 2 condition; 1 for high , 2 for low
% colum 3 electrode number
% the left is voltage for each time point