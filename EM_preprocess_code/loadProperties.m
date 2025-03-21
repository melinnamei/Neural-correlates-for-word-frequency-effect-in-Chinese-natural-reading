function [sp]=loadProperties()

[~,~,charfreq]=xlsread('Characters.xls','1-char','A1:F5622');

[~,~,wordfreq{1}]=xlsread('Words.xls','1-char','A1:E2580');
[~,~,wordfreq{2}]=xlsread('Words.xls','2-char','A1:E59295');
[~,~,wordfreq{3}]=xlsread('Words.xls','3-char','A1:E16275');
[~,~,wordfreq{4}]=xlsread('Words.xls','4-char','A1:E16275');

[~,~,stimuli]=xlsread('stimuli.xlsx','136_V2','C2:E137');
[~,~,charprt]=xlsread('Predict.xlsx','chars','A3:H3229');
[~,~,wordprt]=xlsread('Predict.xlsx','words','A3:I138');

sp={};
for t=1:length(stimuli)
    cid=0;
    %pun=0;
    %% preceeding text
    wdseq = strfind(stimuli{t,1},'/');
    st = 1;
    for w=1:length(wdseq)
        wd = stimuli{t,1}(st:wdseq(w)-1);
        sp.preceeding.text{t}{w} = wd;
        st = wdseq(w)+1;
        
        sp.preceeding.wf{t}{w} = cell2mat(wordfreq{length(wd)}(strcmp(wd,wordfreq{length(wd)}(:,1)), 5));
        
        %search each char
        for c=1:length(wd)
            cid=cid+1;
            ch = wd(c);
            if find(strcmp(ch,wordfreq{1}(:,1)))
                sp.preceeding.cf{t}{w}{c}=wordfreq{1}{strcmp(ch,wordfreq{1}(:,1)), 5};
            else
                sp.preceeding.cf{t}{w}{c}=nan;
            end
            if find(strcmp(ch,charfreq(:,1)))
                sp.preceeding.cstk{t}{w}{c}=charfreq{strcmp(ch,charfreq(:,1)), 6};
            else
                sp.preceeding.cstk{t}{w}{c}=nan;
            end
            if w==1 && c==1
                sp.preceeding.cprt{t}{w}{c}(1:4)=zeros(1,4);
            %elseif strcmp(ch,'£¬')==1
            %    pun=pun+1;
            %    sp.preceeding.cprt{t}{w}{c}(1:4)=-1*ones(1,4);
            else
                sp.preceeding.cprt{t}{w}{c}(1:4)=cell2mat(charprt(strcmp(['S',num2str(t),'_' num2str(cid)],charprt(:,1)), 5:8));
            end
        end
    end
    %% target text
    wdseq = strfind(stimuli{t,2},'/');
    %cond=1
    wd = stimuli{t,2}(1:wdseq(1)-1);
    sp.target.text{t}{1} = wd;
    sp.target.wf{t}{1} = cell2mat(wordfreq{length(wd)}(strcmp(wd,wordfreq{length(wd)}(:,1)), 5));
    sp.target.wprt{t}{1} = wordprt{t, 6};
    
    %search each char
    for c=1:length(wd)
        ch = wd(c);
        if find(strcmp(ch,wordfreq{1}(:,1)))
            sp.target.cf{t}{1}{c}=wordfreq{1}{strcmp(ch,wordfreq{1}(:,1)), 5};
        else
            sp.target.cf{t}{1}{c}=nan;
        end
        if find(strcmp(ch,charfreq(:,1)))
            sp.target.cstk{t}{1}{c}=charfreq{strcmp(ch,charfreq(:,1)), 6};
        else
            sp.target.cstk{t}{1}{c}=nan;
        end
        sp.target.cprt{t}{1}{c}=charprt{strcmp(['S',num2str(t),'_' num2str(cid+c)],charprt(:,1)), 5};
    end
    
    %cond=2
    wd = stimuli{t,2}(wdseq(1)+1:wdseq(2)-1);
    sp.target.text{t}{2} = wd;
    sp.target.wf{t}{2} = cell2mat(wordfreq{length(wd)}(strcmp(wd,wordfreq{length(wd)}(:,1)), 5));
    sp.target.wprt{t}{2} = wordprt{t, 7};
    
    %search each char
    for c=1:length(wd)
        ch = wd(c);
        if find(strcmp(ch,wordfreq{1}(:,1)))
            sp.target.cf{t}{2}{c}=wordfreq{1}{strcmp(ch,wordfreq{1}(:,1)), 5};
        else
            sp.target.cf{t}{2}{c}=nan;
        end
        if find(strcmp(ch,charfreq(:,1)))
            sp.target.cstk{t}{2}{c}=charfreq{strcmp(ch,charfreq(:,1)), 6};
        else
            sp.target.cstk{t}{2}{c}=nan;
        end
        sp.target.cprt{t}{2}{c}=charprt{strcmp(['S',num2str(t),'_' num2str(cid+c)],charprt(:,1)), 6};
    end
    
    %cond=3
    wd = stimuli{t,2}(wdseq(2)+1:wdseq(3)-1);
    sp.target.text{t}{3} = wd;
    sp.target.wf{t}{3} = cell2mat(wordfreq{length(wd)}(strcmp(wd,wordfreq{length(wd)}(:,1)), 5));
    sp.target.wprt{t}{3} = wordprt{t, 8};
    
    %search each char
    for c=1:length(wd)
        ch = wd(c);
        if find(strcmp(ch,wordfreq{1}(:,1)))
            sp.target.cf{t}{3}{c}=wordfreq{1}{strcmp(ch,wordfreq{1}(:,1)), 5};
        else
            sp.target.cf{t}{3}{c}=nan;
        end
        if find(strcmp(ch,charfreq(:,1)))
            sp.target.cstk{t}{3}{c}=charfreq{strcmp(ch,charfreq(:,1)), 6};
        else
            sp.target.cstk{t}{3}{c}=nan;
        end
        sp.target.cprt{t}{3}{c}=charprt{strcmp(['S',num2str(t),'_' num2str(cid+c)],charprt(:,1)), 7};
    end
    
    %cond=4
    wd = stimuli{t,2}(wdseq(3)+1:end);
    sp.target.text{t}{4} = wd;
    sp.target.wf{t}{4} = cell2mat(wordfreq{length(wd)}(strcmp(wd,wordfreq{length(wd)}(:,1)), 5));
    sp.target.wprt{t}{4} = wordprt{t, 9};
    
    %search each char
    for c=1:length(wd)
        ch = wd(c);
        if find(strcmp(ch,wordfreq{1}(:,1)))
            sp.target.cf{t}{4}{c}=wordfreq{1}{strcmp(ch,wordfreq{1}(:,1)), 5};
        else
            sp.target.cf{t}{4}{c}=nan;
        end
        if find(strcmp(ch,charfreq(:,1)))
            sp.target.cstk{t}{4}{c}=charfreq{strcmp(ch,charfreq(:,1)), 6};
        else
            sp.target.cstk{t}{4}{c}=nan;
        end
        sp.target.cprt{t}{4}{c}=charprt{strcmp(['S',num2str(t),'_' num2str(cid+c)],charprt(:,1)), 8};
    end
    
    %% following text
    cid = cid + 2;
    wdseq = strfind(stimuli{t,3},'/');
    st = 2;
    for w=2:length(wdseq)
        wd = stimuli{t,3}(st:wdseq(w)-1);
        sp.following.text{t}{w-1} = wd;
        st = wdseq(w)+1;
        
        sp.following.wf{t}{w-1} = cell2mat(wordfreq{length(wd)}(strcmp(wd,wordfreq{length(wd)}(:,1)), 5));
        
        %search each char
        for c=1:length(wd)
            cid=cid+1;
            ch = wd(c);
            
            if find(strcmp(ch,wordfreq{1}(:,1)))
                sp.following.cf{t}{w-1}{c}=wordfreq{1}{strcmp(ch,wordfreq{1}(:,1)), 5};
            else
                sp.following.cf{t}{w-1}{c}=nan;
            end
            if find(strcmp(ch,charfreq(:,1)))
                sp.following.cstk{t}{w-1}{c}=charfreq{strcmp(ch,charfreq(:,1)), 6};
            else
                sp.following.cstk{t}{w-1}{c}=nan;
            end
            
            %if strcmp(ch,'£¬')
            %    pun=pun+1;
            %    sp.following.cprt{t}{w-1}{c}(1:4)=-1*ones(1,4);
            %else
            if find(strcmp(['S',num2str(t),'_' num2str(cid)],charprt(:,1)))
                sp.following.cprt{t}{w-1}{c}(1:4)=cell2mat(charprt(strcmp(['S',num2str(t),'_' num2str(cid)],charprt(:,1)), 5:8));
            else
                sp.following.cprt{t}{w-1}{c}(1:4)=nan*ones(1,4);
            end
        end
    end
end
end