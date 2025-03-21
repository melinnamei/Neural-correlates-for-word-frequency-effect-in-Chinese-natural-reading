function [Trials]=extractData(Trials,stimuli)
% Dr.Yanping Liu
% email:liuyp33@mail.sysu.edu.cn
%

for t=1:length(Trials)
    
    trial = Trials(t);
    if ~isempty(trial)
        sentence = [stimuli.preceeding{trial.sentid},stimuli.target{trial.sentid}{trial.cond},stimuli.following{trial.sentid}];
        
        [ROIs]=makeROIs(length(stimuli.preceeding{trial.sentid})+1,sentence);
        
        EM.maxX =0;
        EM.prev2Fix = []; % more previous fix
        EM.prevFix=[];
        EM.nextFix=[];
        EM.prev2FixedROI=[];
        EM.prevFixedROI=[];
        EM.nextFixedROI=[];
        
        if ~isempty(trial.Fixations)&&~isempty(fieldnames(trial.Fixations))
            for f=1:length(trial.Fixations)
                EM.nextFix=trial.Fixations(f);
                [EM,ROIs]=analyzeOneFixation(EM,ROIs,sentence);
            end
        end
        
        Trials(t).sentence=sentence;
        Trials(t).roi=ROIs;
    end
end
end

function [ROIs]=makeROIs(targetid,sentence)

xst=600;

for i=1:length(sentence)
   
    % fill previous roi
    if i>1
        ROIs(i).prevtext      =sentence{i-1};
        ROIs(i).prevchnum     =length(sentence{i-1});
    else
        ROIs(i).prevtext      =[];
        ROIs(i).prevchnum     =[];
    end
    
    ROIs(i).text      =sentence{i};
    ROIs(i).chnum     =length(sentence{i});
    ROIs(i).istarget  =targetid==i;
    ROIs(i).ispunct   =any(isstrprop(sentence{i},'punct'));
    
    ROIs(i).fn        =0;
    ROIs(i).blink     =0;
    ROIs(i).regout    =0;
    ROIs(i).regin     =0;
    ROIs(i).comingin  =0;
    ROIs(i).goingout  =0;
    ROIs(i).skipped   =0;
    
    ROIs(i).Xst       =xst;
    ROIs(i).Xen       =xst+53*ROIs(i).chnum;
    
    %fill next roi
    if i<length(sentence)
        ROIs(i).nexttext      =sentence{i+1};
        ROIs(i).nextchnum     =length(sentence{i+1});
    else
        ROIs(i).nexttext      =[];
        ROIs(i).nextchnum     =[];
    end
    
    xst = ROIs(i).Xen;
end
end