function [Trials]=clearPriorFixations(Trials)
% Dr. Yanping Liu
% email: liuyp33@mail.sysu.edu.cn
%
% Description: clear fixations before display on.

for t=1:length(Trials)
    trial=Trials(t);
    eye=trial.Header.rec.eye;
    
    iS=1;
    tmpsac=struct;
    if ~isempty(trial.Saccades)&&~isempty(fieldnames(trial.Saccades))
        for s=1:length(trial.Saccades)
            if(trial.Saccades(s).eye+1==eye&&trial.Saccades(s).sttime>trial.strec&&trial.Saccades(s).entime<trial.enrec)
                tmpsac=replicateStruct(trial.Saccades(s),tmpsac,iS);
                iS=iS+1;
            end
        end
        Trials(t).Saccades=tmpsac;
    end
    
    iF=1;
    tmpfix=struct;
    if ~isempty(trial.Fixations)&&~isempty(fieldnames(trial.Fixations))
        for f=1:length(trial.Fixations)
            if(trial.Fixations(f).eye+1==eye&&trial.Fixations(f).sttime>trial.strec&&trial.Fixations(f).entime<trial.enrec)
                tmpfix=replicateStruct(trial.Fixations(f),tmpfix,iF);
                iF=iF+1;
            end
        end
        Trials(t).Fixations=tmpfix;
    end
    
    iB=1;
    tmpblk=struct;
    if ~isempty(trial.Blinks)&&~isempty(fieldnames(trial.Blinks))
        for b=1:length(trial.Blinks)
            if(trial.Blinks(b).eye+1==eye&&trial.Blinks(b).sttime>trial.strec&&trial.Blinks(b).entime<trial.enrec)
                tmpblk=replicateStruct(trial.Blinks(b),tmpblk,iB);
                iB=iB+1;
            end
        end
        Trials(t).Blinks=tmpblk;
    end
end
end