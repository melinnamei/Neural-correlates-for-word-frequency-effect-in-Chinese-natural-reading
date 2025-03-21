function [sentences]=loadStimuli()

[~,~,stimuli]=xlsread('stimuli.xlsx','136_V2','C2:E137');

sentences={};
for t=1:length(stimuli)
    ix = strfind(stimuli{t,1},'/'); %preceeding text
    st = 1;
    for i=1:length(ix)
        sentences.preceeding{t}{i} = stimuli{t,1}(st:ix(i)-1);
        st = ix(i)+1;
    end
    ix = strfind(stimuli{t,2},'/'); %target text
    sentences.target{t}{1} = stimuli{t,2}(1:ix(1)-1);
    sentences.target{t}{2} = stimuli{t,2}(ix(1)+1:ix(2)-1);
    sentences.target{t}{3} = stimuli{t,2}(ix(2)+1:ix(3)-1);
    sentences.target{t}{4} = stimuli{t,2}(ix(3)+1:end);
    ix = strfind(stimuli{t,3},'/'); %following text
    st = 2;
    for i=2:length(ix)
        sentences.following{t}{i-1} = stimuli{t,3}(st:ix(i)-1);
        st = ix(i)+1;
    end
end
end