function [Trials]=checkBlinks(Trials)
%Dr.Yanping Liu
%email:liuyp33@mail.sysu.edu.cn
%
for t=1:length(Trials)
    iB=0;
    prevfix=[];

    if ~isempty(Trials(t).Fixations)&&~isempty(fieldnames(Trials(t).Fixations))
        if ~isempty(Trials(t).Blinks)&&~isempty(fieldnames(Trials(t).Blinks))
            for f=1:length(Trials(t).Fixations)
                currfix=Trials(t).Fixations(f);
                if ~isempty(prevfix)

                    for b=1:length(Trials(t).Blinks)
                        blink=Trials(t).Blinks(b);
                        if (blink.sttime>=prevfix.entime&&blink.entime<=currfix.sttime&&blink.eye==currfix.eye)                           
                            if (~isfield(currfix,'blink')||isempty(currfix.blink))
                                Trials(t).Fixations(f).blink=0;
                            end
                            Trials(t).Fixations(f).blink=Trials(t).Fixations(f).blink+1;                            
                            iB=iB+1;
                            break;
                        end
                    end

                end
                prevfix=currfix;
            end
        end
    end
    Trials(t).blinknum=iB;
end
end