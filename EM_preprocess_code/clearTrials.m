function [Trials]=clearTrials(Trials)
% Dr. Yanping Liu
% email: liuyp33@mail.sysu.edu.cn
%
% Description: only keep experimental trials, excluding repeat or paractice trials.
iT=1;
for t=1:length(Trials)
    if isempty(cell2mat(strfind(Trials(t).Events.message,'Sentid P')))...
            && ~isempty(cell2mat(strfind(Trials(t).Events.message,'SYNCTIME')))
        tmpTrials(iT)=Trials(t);
        iT=iT+1;
    end
end
Trials=tmpTrials;
end