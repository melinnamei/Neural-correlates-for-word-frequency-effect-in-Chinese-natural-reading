function [Trials]=accTrials(Trials,myans)
% Dr.Yanping Liu
% email:liuyp33@mail.sysu.edu.cn
% 
for t=1:length(Trials)
    if(~isempty(Trials(t)) && ~isempty(Trials(t).ans) && ~strcmp(myans{t},'N'))
        Trials(t).acc=strcmp(Trials(t).ans,myans{t});
    end
end
end