%% FOR four condition
clear all; close all;
[data,txt,raw]=xlsread('data20210402.csv');

% [data,txt,raw]=xlsread('mc_ems.csv');
clear raw txt;

data=data(:,1:20);

idx_target=find(data(:,11)==1);
data=data(idx_target,:);

ffd_c=18;
gd_c=19;
tt_c=20;
% remove less than 60 fixations
idx1=find(   data(:,ffd_c)>20) ;
% idx1=find(   data(:,ffd_c)>20 &data(:,gd_c)>60 & data(:,tt_c)>0& data(:,ffd_c)<800) ;
data=data(idx1,:);

% remove no_use sbj
% idx2=find(~ismember(data(:,1),[2 29 34]));

% idx2=find(data(:,1)>18);
% data=data(idx2,:);


pool2use={'sbj'};
pool_id=[1];


pool=unique(data(:,pool_id));% trial id or sbj id

% id1=find(~isnan(result(:,6)));
% id2=find(~isnan(result(:,7)));
% id_ff=intersect(id1,id2);

% sbj_pool=id_ff;
% idx_pool={'ffd','gd','tt'};
idx_pool={'gd'};
c2use_pool=[19:20];
condition_c=6;

result=[];
for idxi=1:length(idx_pool)
    
    c2use=c2use_pool(idxi);
    % High Frequency word
    conditions={'HFHC','HFLC','LFHC','LFLC','HF','LF','HC','LC'};
    
    for sbji=1:length(pool)
        temp_result=[];
    for condi=1:length(conditions)
    
        if condi==5            
            idx=find(data(:,condition_c)<3);
        elseif condi==6
            idx=find(data(:,condition_c)>2);
        elseif condi==7
            idx=find(data(:,condition_c)==1|data(:,condition_c)==3);
        elseif condi==8 
            idx=find(data(:,condition_c)==2|data(:,condition_c)==4);
        else
        idx=find(data(:,condition_c)==condi);
        end
        
        % sbj_idx in the data
        idx_tmp=find(data(:,pool_id)==pool(sbji));
        
        % find the intersect 
        idx2use=intersect(idx,idx_tmp);
        
        temp=data(idx2use,c2use);
        

        var_mean=mean(temp);        
        var_sem=std(temp)/ sqrt(length(temp));
         
        temp_result=[temp_result var_mean];
%         fprintf([conditions{condi},' ', idx_pool{idxi},' mean %4.2f(%4.2f)\n'],var_mean,var_sem);
    end
    result=[result;pool(sbji) temp_result];
    end            
end

% result=result(find(~isnan(result(:,2))),:)

