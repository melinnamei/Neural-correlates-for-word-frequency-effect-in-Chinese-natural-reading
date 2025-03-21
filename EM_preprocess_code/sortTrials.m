function [Trials]=sortTrials(Trials)
for iS=1:136
    for t=1:length(Trials)
        if Trials(t).sentid==iS
            tmpTrials(iS)=Trials(t);
            break;
        end
    end
end
Trials=tmpTrials;

inuse=[];
for is = 1:length(Trials)
   if ~isempty(Trials(is).Header) && ~isempty(Trials(is).enrec)
      inuse=[inuse is];
   end
    
end

Trials=Trials(inuse);
end