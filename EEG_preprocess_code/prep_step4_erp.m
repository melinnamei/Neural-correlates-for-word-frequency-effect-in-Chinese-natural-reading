clear all;
close all;
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

sbj_pool=[2:9 11:32];
cd ..
main_folder=pwd;

cd ([main_folder,'\temp_file']);
% 
% for sbji=1:length(sbj_pool)
%     sbj_num=sbj_pool(sbji);
%     EEG=pop_loadset('filename',['sub',num2str(sbj_num),'_epochs_test1.set']);
%     [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
% end
% 
% EEG = pop_mergeset( ALLEEG, [1:length(sbj_pool)], 0);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off');
% EEG=pop_saveset(EEG,'filename',['all_merged_target_epochs1.set']);

%% 
close all;EEG=[];ALLEEG=[];CURRENTSET=[];

tic % start timing

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

EEG=pop_loadset('filename',['all_merged_target_epochs1.set']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

EEG = pop_rmbase( EEG, [-100 0] ,[]);

EEG = pop_reref( EEG, []);

EEG = pop_eegfiltnew(EEG, 'hicutoff',20,'plotfreqz',1);

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );


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

eeglab redraw;

pop_comperp( ALLEEG, 1, [3 4] ,[],'addavg','off','addstd','off','addall','on','diffavg','off','diffstd','off','chans',[1:60] ,'lowpass',30,'tplotopt',{'ydir' 1});

%% topoplot

EEG=ALLEEG(3);
high_data=EEG.data;

EEG=ALLEEG(4);
low_data=EEG.data;

time_pool=[];


figure;
time_pool{1}=[-100:0];
time_pool{2}=[100:140];
time_pool{3}=[160:300];
time_pool{4}=[300:500];

list ={'Baseline';'P1';'N200';'N400'};

for ti=1:length(time_pool);
    
    time_range=time_pool{ti};
    start=200;
    
    q=start+time_range;
    low=mean(low_data(:,start+time_range,:),3);
    low=mean(low,2);
    high=mean(high_data(:,start+time_range,:),3);
    high=mean(high,2);
    diff=low-high;
    
     subplot(1,4,ti);     
    topoplot(diff,EEG.chanlocs,'drawaxis','off','electrodes','off','style','both','maplimits',[-0.8 0.8]);    
    hold on;
    set(gca,'fontsize',14);
    set(gcf,'color','w');
    title([list{ti}]);              
       colorbar;
              
end

%% ROI plot
ROI_name={'Frontal Central';'Central Parietal';'Left OT';'Right OT'};

F_C=[18 19 20 28];
C_P=[37 45 46 47];
Left_OT=[51 52 53 58];
Right_OT=[55 56 57 60];

ROI{1}=F_C;
ROI{2}=C_P;
ROI{3}=Left_OT;
ROI{4}=Right_OT;
x_range=[-199:800];


figure();
set(gcf,'color','w','Position',[0 0 1000 800]);

for roii=1:length(ROI_name)
    
    subplot(2,2,roii);    
    high=ALLEEG(3).data;
    high=mean(high(ROI{roii},:,:),3);%mean epochs
    high=mean(high,1);%mean roi
    
    low=ALLEEG(4).data;
    low=mean(low(ROI{roii},:,:),3);%mean epochs
    low=mean(low,1);%mean roi
    plot(x_range,high,'linew',2);
    hold on;
    plot(x_range,low,'linew',2);
    
    xlim([-100 600]);
    title(ROI_name{roii});
    yline(0);
    xline(0);
    ylim([-4 4]);
    ylabel('\muv');
   
    
    hold off;
    
    if roii==4
        legend('High Frequency','Low Frequency','AutoUpdate','off','Location','southeast');
    end
    set(gca,'FontSize',16);
    
   
    if roii==1              
         x = [300 500 500 300];
        y = [-4 -4 4 4];
        patch(x,y,[0.9290 0.6940 0.1250],'EdgeColor','none')
        alpha(.1)
        text(390,3,'*','FontSize',20);
        
    end
    
        if roii==2              
         x = [300 500 500 300];
        y = [-4 -4 4 4];
        patch(x,y,[0.9290 0.6940 0.1250],'EdgeColor','none')
        alpha(.1)
        text(390,3,'**','FontSize',20);
        
    end
    
    
    if roii==3
            
        x = [160 300 300 160];
        y = [-4 -4 4 4];
        patch(x,y,[0.8500 0.3250 0.0980],'EdgeColor','none')
        alpha(.1)
        text(240,3,'**','FontSize',20);
        
        
        x = [300 500 500 300];
        y = [-4 -4 4 4];
        patch(x,y,[0.9290 0.6940 0.1250],'EdgeColor','none')
        alpha(.1)
        text(390,3,'***','FontSize',20);
        
 
    end
    
    if roii==4
        
        x = [160 300 300 160];
        y = [-4 -4 4 4];
        patch(x,y,[0.8500 0.3250 0.0980],'EdgeColor','none')
        alpha(.1)
        text(240,3,'*','FontSize',20);
        
        x = [300 500 500 300];
        y = [-4 -4 4 4];
        patch(x,y,[0.9290 0.6940 0.1250],'EdgeColor','none')
        alpha(.1)
        text(390,3,'**','FontSize',20);
        
    end
    
    set(gca,'FontSize',16);
    
end

% saveas(gcf,'target_frequency_effect_EEG_with_statis.bmp')

