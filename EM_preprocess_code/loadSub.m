function [Sub]=loadSub(filename)
% Dr.Yanping Liu
% email:liuyp33@mail.sysu.edu.cn
% 
[Trials]=edfImport([filename], [1 1 0], ' ');
[Trials]=clearTrials(Trials);               %#clear repeat or practice trials
[Trials]=extractInterestingEvents(Trials);  %#compose fixation, saccade, blink events
[Trials]=sortTrials(Trials);
[Trials]=accTrials(Trials,loadAns());       %#compute accuracy rate
[Trials]=clearPriorFixations(Trials);       %#clear prior fixation, blink, saccade before desplay on. 
[Trials]=checkBlinks(Trials);               %#check blinked trials.
[Trials]=extractData(Trials,loadStimuli());
Sub.Trials=Trials;
end