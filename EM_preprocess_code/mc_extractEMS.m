function mc_extractEMS(Subs,sp)
% Dr.Yanping Liu
% email:liuyp33@mail.sysu.edu.cn
%
% Extract rst from landolt-square.
% Syntax:[rst]=mc_extractEMS(Subs)
%
% Description:
% col 1:  subjectid
% col 2:  trialid
% col 3:  sentid
% col 4:  wordid
% col 5:  last word?
% col 6:  cond
% col 7:  previous word character number
% col 8:  curr word character number
% col 9:  next word character number
% col 10: previous cluster is target?
% col 11: current cluster is target?
% col 12: next cluster is target?
% col 13: acc
% col 14: totalblink
% col 15: regin
% col 16: regout
% col 17: fn
% col 18: ffd
% col 19: gd
% col 20: tt
% col 21: incoming blink
% col 22: incoming launch-site time
% col 23: incoming launch-site x
% col 24: incoming saccade length
% col 25: incoming landing-site time
% col 26: incoming landing-site x
% col 27: incoming order id
% col 28: outgoing blink
% col 29: outgoing launch-site time
% col 30: outgoing launch-site x
% col 31: outgoing saccade length
% col 32: outgoing landing-site time
% col 33: outgoing launch-site x
% col 34: outgoing order id

% col 35: prevWF
% col 36: currWF
% col 37: nextWF
% col 38: currWP

title={'subjectid','trialid','sentid','wordid','lastword','cond','prevchnum','currchnum','nextchnum'...
    ,'previstarget','curristarget','nextistarget','acc','totalblink','regin','regout','fn','ffd','gd','tt','lastfixation'...
    ,'prevWF','currWF','nextWF','currWP'};

fid=fopen('frequency_effect_EEG_EM_2023.txt','wt');
% fprintf(fid,'%s,',title{:});
fprintf(fid,'%s\t',title{:});
fprintf(fid,'\n');

for s=1:length(Subs)
    s
    Trials=Subs(s).Trials;
    for t=1:length(Trials)
        trial=Trials(t);
        
        position = 1; % 1=preceeding, 2=target, 3=following
        offset = 0;
        
        for i=1:length(trial.sentence)
            
            if trial.roi(i).istarget %%enter target
                position = 2;
                offset = i-1;
            elseif position == 2     %%leave target
                position = 3;
                offset = i-1;
            end
            
            fprintf(fid,'%d\t',s);                                          %%1  subjectid
            fprintf(fid,'%s\t',trial.trialid);                              %%2  trialid
            fprintf(fid,'%d\t',trial.sentid);                               %%3  sentid
            fprintf(fid,'%d\t',i);                                          %%4  wordid
            fprintf(fid,'%d\t',i==length(trial.sentence));                  %%5  wordid
            fprintf(fid,'%d\t',trial.cond);                                 %%6  cond
            fprintf(fid,'%d\t',trial.roi(i).prevchnum);                     %%7  prev word character num
            fprintf(fid,'%d\t',trial.roi(i).chnum);                         %%8  curr word character num
            fprintf(fid,'%d\t',trial.roi(i).nextchnum);                     %%9  next word character num
            
            if i==1
                fprintf(fid,' \t');                                         %%10 prev word is target?
            else
                fprintf(fid,'%d\t',trial.roi(i-1).istarget);                
            end
            fprintf(fid,'%d\t',trial.roi(i).istarget);                      %%11  curr word is target?
            if i==length(trial.sentence)
                fprintf(fid,' \t');                                         %%12 next word is target?
            else
                fprintf(fid,'%d\t',trial.roi(i+1).istarget);                
            end
            fprintf(fid,'%d\t',trial.acc);                                  %%13 acc
            fprintf(fid,'%d\t',trial.blinknum);                             %%14 total blink number
            fprintf(fid,'%d\t',trial.roi(i).regin);                         %%15 regression in
            fprintf(fid,'%d\t',trial.roi(i).regout);                        %%16 regression out
            fprintf(fid,'%d\t',trial.roi(i).fn);       
            %%17 fixation number
            if isfield(trial.roi(i),'ffd')
            fprintf(fid,'%d\t',trial.roi(i).ffd);                  
            else
                fprintf(fid,'\t');                           %%18 ffd
            end                
                        
            if isfield(trial.roi(i),'gd')
            fprintf(fid,'%d\t',trial.roi(i).gd);                  
            else
                fprintf(fid,'\t');                           %%19 gd
            end
                            
            if isfield(trial.roi(i),'tt')
            fprintf(fid,'%d\t',trial.roi(i).tt);                  
            else
                fprintf(fid,'\t');                           %%20tt
            end
            
            % melinna edit 2023/02/05
            if isfield(trial.roi(i),'lastfixation')
            fprintf(fid,'%d\t',trial.roi(i).lastfixation);                  
            else
                fprintf(fid,'\t');                           %%21 lastfixation
            end
            
            % col 35: prevWF
            if i==1
                fprintf(fid,'\t');
            else
                if position <= 2
                    fprintf(fid,'%5.8f\t',sp.preceeding.wf{trial.sentid}{i-1});
                else
                    if trial.roi(i-1).istarget
                        fprintf(fid,'%5.8f\t',sp.target.wf{trial.sentid}{trial.cond});
                    else
                        fprintf(fid,'%5.8f\t',sp.following.wf{trial.sentid}{i-1-offset});
                    end
                end
            end
            
            % col 36: currWF
            if position == 1
                fprintf(fid,'%5.8f\t',sp.preceeding.wf{trial.sentid}{i});
            elseif position == 2
                fprintf(fid,'%5.8f\t',sp.target.wf{trial.sentid}{trial.cond});
            else
                fprintf(fid,'%5.8f\t',sp.following.wf{trial.sentid}{i-offset});
            end
%             
            % col 37: nextWF
            if i==length(trial.sentence)
                fprintf(fid,'\t');
            else
                if position == 1
                    if trial.roi(i+1).istarget
                        fprintf(fid,'%5.8f\t',sp.target.wf{trial.sentid}{trial.cond});
                    else
                        fprintf(fid,'%5.8f\t',sp.preceeding.wf{trial.sentid}{i+1});
                    end
                elseif position == 2
                    fprintf(fid,'%5.8f\t',sp.following.wf{trial.sentid}{1});
                else
                    fprintf(fid,'%5.8f\t',sp.following.wf{trial.sentid}{i+1-offset});
                end
            end
            
            % col 38: currWP
            if trial.roi(i).istarget
                fprintf(fid,'%5.8f\t',sp.target.wprt{trial.sentid}{trial.cond});
            else
                fprintf(fid,'\t');
            end
%             
%             % col 39: prevWL
%             % col 40: currWL            
%             % col 41: nextWL
%             if position==1
%                 if i==1
%                     fprintf(fid,' ,');
%                 else
%                     fprintf(fid,'%d,',length(sp.preceeding.text{t}{i-1}));
%                 end
%                 
%                 fprintf(fid,'%d,',length(sp.preceeding.text{t}{i}));
%                                
%                 if trial.roi(i+1).istarget
%                     fprintf(fid,'%d,',2);
%                 else                   
%                     fprintf(fid,'%d,',length(sp.preceeding.text{t}{i+1}));
%                 end
%             elseif position == 2
%                 fprintf(fid,'%d,',length(sp.preceeding.text{t}{i-1}));
%                 fprintf(fid,'%d,',2);
%                 fprintf(fid,'%d,',length(sp.following.text{t}{1}));
%             else %position=3
%                 if trial.roi(i-1).istarget
%                     fprintf(fid,'%d,',2);
%                 else                   
%                     fprintf(fid,'%d,',length(sp.following.text{t}{i-1-offset}));
%                 end
%                 fprintf(fid,'%d,',length(sp.following.text{t}{i-offset}));
%                 if i==length(trial.sentence)
%                     fprintf(fid,' ,');
%                 else
%                     fprintf(fid,'%d,',length(sp.following.text{t}{i+1-offset}));
%                 end
%             end            
%                 
%             % col 42: prevC1F
%             % col 43: prevC2F
%             % col 44: prevC3F
%             % col 45: prevC4F
%             % col 46: prevCLF
%             % col 47: prevCMF            
%             if i==1
%                 fprintf(fid,' , , , , , ,');
%             else
%                 if position <= 2
%                     wd=sp.preceeding.text{t}{i-1};                    
%                     if ~isempty(sp.preceeding.cf{t}{i-1})
%                         total=0;
%                         for c=1:4
%                             if c<=length(wd)
%                                 fprintf(fid,'%5.8f,',sp.preceeding.cf{t}{i-1}{c});
%                                 total=total+sp.preceeding.cf{t}{i-1}{c};
%                             else
%                                 fprintf(fid,' ,');
%                             end                            
%                         end
% 
%                         fprintf(fid,'%5.8f,',sp.preceeding.cf{t}{i-1}{length(wd)});
%                         fprintf(fid,'%5.8f,',total/length(wd));
%                     else
%                         fprintf(fid,' , , , , , ,');
%                     end                    
%                 else %position=3
%                     if  trial.roi(i-1).istarget
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{1});
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{2});
%                         fprintf(fid,' , ,');
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{2});
%                         fprintf(fid,'%5.8f,',(sp.target.cf{t}{trial.cond}{1}+sp.target.cf{t}{trial.cond}{2})/2);
%                     else
%                         wd = sp.following.text{t}{i-1-offset};
%                         if ~isempty(sp.following.cf{t}{i-1-offset})
% 
%                             total=0;
%                             for c=1:4
%                                 if c<=length(wd)
%                                     fprintf(fid,'%5.8f,',sp.following.cf{t}{i-1-offset}{c});
%                                     total=total+sp.following.cf{t}{i-1-offset}{c};
%                                 else
%                                     fprintf(fid,' ,');
%                                 end
%                             end
% 
%                             fprintf(fid,'%5.8f,',sp.following.cf{t}{i-1-offset}{length(wd)});
%                             fprintf(fid,'%5.8f,',total/length(wd));
%                         else
%                             fprintf(fid,' , , , , , ,');
%                         end
%                     end
%                 end
%             end
%             
%             % col 48: currC1F
%             % col 49: currC2F
%             % col 50: currC3F
%             % col 51: currC4F
%             % col 52: currCLF
%             % col 53: currCMF   
%             if position == 1
%                 wd = sp.preceeding.text{t}{i};
%                 if ~isempty(sp.preceeding.cf{t}{i})
%                     total=0;
%                     for c=1:4
%                         if c<=length(wd)
%                             fprintf(fid,'%5.8f,',sp.preceeding.cf{t}{i}{c});
%                             total=total+sp.preceeding.cf{t}{i}{c};
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
% 
%                     fprintf(fid,'%5.8f,',sp.preceeding.cf{t}{i}{length(wd)});
%                     fprintf(fid,'%5.8f,',total/length(wd));
%                 else
%                     fprintf(fid,' , , , , , ,');
%                 end
%             elseif position == 2
%                 wd = sp.target.text{t}{trial.cond};
%                 total=0;
%                 for c=1:4
%                     if c<=length(wd)
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{c});
%                         total=total+sp.target.cf{t}{trial.cond}{c};
%                     else
%                         fprintf(fid,' ,');
%                     end
%                 end
%                 fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{length(wd)});
%                 fprintf(fid,'%5.8f,',total/length(wd));
%             else %position=3
%                 wd = sp.following.text{t}{i-offset};
%                 if ~isempty(sp.following.cf{t}{i-offset})
%                     total=0;
%                     for c=1:4
%                         if c<=length(wd)
%                             fprintf(fid,'%5.8f,',sp.following.cf{t}{i-offset}{c});
%                             total=total+sp.following.cf{t}{i-offset}{c};
%                         else
%                             fprintf(fid,' ,');
%                         end                        
%                     end
%                     fprintf(fid,'%5.8f,',sp.following.cf{t}{i-offset}{length(wd)});
%                     fprintf(fid,'%5.8f,',total/length(wd));
%                 else
%                     fprintf(fid,' , , , , , ,');
%                 end
%             end
% 
%             % col 54: nextC1F
%             % col 55: nextC2F
%             % col 56: nextC3F
%             % col 57: nextC4F
%             % col 58: nextCLF
%             % col 59: nextCMF
%             
%             if i==length(trial.sentence)
%                 fprintf(fid,' , , , , , ,');
%             else
%                 if position == 1
%                     if trial.roi(i+1).istarget
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{1});
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{2});
%                         fprintf(fid,' , ,');
%                         fprintf(fid,'%5.8f,',sp.target.cf{t}{trial.cond}{2});
%                         fprintf(fid,'%5.8f,',(sp.target.cf{t}{trial.cond}{1}+sp.target.cf{t}{trial.cond}{2})/2);
%                     else
%                         wd = sp.preceeding.text{t}{i+1};
%                         if ~isempty(sp.preceeding.cf{t}{i+1})
%                             total=0;
%                             for c=1:4
%                                 if c<= length(wd)
%                                     fprintf(fid,'%5.8f,',sp.preceeding.cf{t}{i+1}{c});
%                                     total=total+sp.preceeding.cf{t}{i+1}{c};
%                                 else
%                                     fprintf(fid,' ,');
%                                 end
%                             end
%                             fprintf(fid,'%5.8f,',sp.preceeding.cf{t}{i+1}{length(wd)});
%                             fprintf(fid,'%5.8f,',total/length(wd));
%                         else
%                             fprintf(fid,' , , , , , ,');
%                         end
%                     end
%                 elseif position == 2
%                     wd = sp.following.text{t}{1};
%                     if ~isempty(sp.following.cf{t}{1})
%                         total=0;
%                         for c=1:4
%                             if c<=length(wd)
%                                 fprintf(fid,'%5.8f,',sp.following.cf{t}{1}{c});
%                                 total=total+sp.following.cf{t}{1}{c};
%                             else
%                                 fprintf(fid,' ,');
%                             end
%                         end
%                         
%                         fprintf(fid,'%5.8f,',sp.following.cf{t}{1}{length(wd)});                        
%                         fprintf(fid,'%5.8f,',total/length(wd));                        
%                     else
%                         fprintf(fid,' , , , , , ,');
%                     end
%                 else
%                     wd = sp.following.text{t}{i+1-offset};
%                     if ~isempty(sp.following.cf{t}{i+1-offset})
%                         total=0;
%                         for c=1:4
%                             if c<=length(wd)
%                                 fprintf(fid,'%5.8f,',sp.following.cf{t}{i+1-offset}{c});
%                                 total=total+sp.following.cf{t}{i+1-offset}{c};
%                             else
%                                 fprintf(fid,' ,');
%                             end
%                         end
%                         
%                         fprintf(fid,'%5.8f,',sp.following.cf{t}{i+1-offset}{length(wd)});
%                         fprintf(fid,'%5.8f,',total/length(wd));                        
%                     else
%                         fprintf(fid,' , , , , , ,');
%                     end
%                 end
%             end
%             
%             % col 60: prevC1P
%             % col 61: prevC2P
%             % col 62: prevC3P
%             % col 63: prevC4P
%             % col 64: prevCLP
%             % col 65: prevCalgMP
%             % col 66: prevCgeoMP
%             
%             if i==1
%                 fprintf(fid,' , , , , , , ,');
%             else
%                 if position <= 2
%                     wd=sp.preceeding.text{t}{i-1};
%                     algM=0;
%                     geoM=1;
%                     for c=1:4
%                         if c<=length(wd)
%                             prt=mean(sp.preceeding.cprt{t}{i-1}{c});
%                             fprintf(fid,'%5.8f,',prt);
%                             algM=algM+prt;
%                             geoM=geoM*prt;
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',mean(sp.preceeding.cprt{t}{i-1}{length(wd)}));
%                     fprintf(fid,'%5.8f,',algM/length(wd));
%                     fprintf(fid,'%5.8f,',geoM);
%                 else
%                     if trial.roi(i-1).istarget
%                         fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{1});
%                         fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{2});
%                         fprintf(fid,' , ,');
%                         fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{2});
%                         fprintf(fid,'%5.8f,',(sp.target.cprt{t}{trial.cond}{1}+sp.target.cprt{t}{trial.cond}{2})/2);
%                         fprintf(fid,'%5.8f,',power(sp.target.cprt{t}{trial.cond}{1}*sp.target.cprt{t}{trial.cond}{2},1/2));
%                     else
%                         wd = sp.following.text{t}{i-1-offset};
%                         algM=0;
%                         geoM=1;
%                         pn=0;
%                         if i-1-offset<=length(sp.following.cprt{t})
%                             for c=1:4
%                                 if c<=length(wd) && ~any(sp.following.cprt{t}{i-1-offset}{c}==-1)
%                                     prt=mean(sp.following.cprt{t}{i-1-offset}{c});
%                                     fprintf(fid,'%5.8f,',prt);
%                                     algM=algM+prt;
%                                     geoM=geoM*prt;
%                                     pn=pn+1;
%                                 else
%                                     fprintf(fid,' ,');
%                                 end
%                             end
%                         else
%                             fprintf(fid,' , , , ,');
%                         end
%                         if pn>0
%                             fprintf(fid,'%5.8f,',mean(sp.following.cprt{t}{i-1-offset}{length(wd)}));
%                             fprintf(fid,'%5.8f,',algM/length(wd));
%                             fprintf(fid,'%5.8f,',geoM);
%                         else
%                             fprintf(fid,' , , ,');
%                         end
%                     end
%                 end
%             end
%             
%             % col 67: currC1P
%             % col 68: currC2P
%             % col 69: currC3P
%             % col 70: currC4P
%             % col 71: currCLP
%             % col 72: currCalgMP
%             % col 73: currCgeoMP
%             if i>length(trial.sentence)
%                 fprintf(fid,' , , , , , , ,');
%             else
%                 if position == 1
%                     wd = sp.preceeding.text{t}{i};
%                     algM=0;
%                     geoM=1;
%                     for c=1:4
%                         if c<=length(wd)
%                             prt=mean(sp.preceeding.cprt{t}{i}{c});
%                             algM=algM+prt;
%                             geoM=geoM*prt;
%                             fprintf(fid,'%5.8f,',prt);
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',mean(sp.preceeding.cprt{t}{i}{length(wd)}));
%                     fprintf(fid,'%5.8f,',algM/length(wd));
%                     fprintf(fid,'%5.8f,',geoM);
%                 elseif position == 2
%                     wd = sp.target.text{t}{trial.cond};
%                     algM=0;
%                     geoM=1;
%                     for c=1:4
%                         if c<=length(wd)
%                             prt=sp.target.cprt{t}{trial.cond}{c};
%                             fprintf(fid,'%5.8f,',prt);
%                             algM=algM+prt;
%                             geoM=geoM*prt;
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{length(wd)});
%                     fprintf(fid,'%5.8f,',algM/length(wd));
%                     fprintf(fid,'%5.8f,',geoM);
%                 else
%                     wd = sp.following.text{t}{i-offset};
%                     algM=0;
%                     geoM=1;
%                     pn=0;
%                     if i-offset<=length(sp.following.cprt{t})
%                         for c=1:4
%                             if c<=length(wd) && ~any(sp.following.cprt{t}{i-offset}{c}==-1)
%                                 prt=mean(sp.following.cprt{t}{i-offset}{c});
%                                 fprintf(fid,'%5.8f,',prt);
%                                 algM=algM+prt;
%                                 geoM=geoM*prt;
%                                 pn=pn+1;
%                             else
%                                 fprintf(fid,' ,');
%                             end
%                         end
%                         if pn>0
%                             fprintf(fid,'%5.8f,',mean(sp.following.cprt{t}{i-offset}{length(wd)}));
%                             fprintf(fid,'%5.8f,',algM/length(wd));
%                             fprintf(fid,'%5.8f,',geoM);
%                         else
%                             fprintf(fid,' , , ,');
%                         end
%                     else
%                         fprintf(fid,' , , , , , , ,');
%                     end                    
%                 end
%             end
%             % col 74: nextC1P
%             % col 75: nextC2P
%             % col 76: nextC3P
%             % col 77: nextC4P
%             % col 78: nextCLP
%             % col 79: nextCalgMP
%             % col 80: nextCgeoMP
%             
%             if i>=length(trial.sentence)
%                 fprintf(fid,' , , , , , , ,');
%             else
%                 if position == 1
%                     if trial.roi(i+1).istarget
%                         fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{1});
%                         fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{2});
%                         fprintf(fid,' , ,');
%                         fprintf(fid,'%5.8f,',sp.target.cprt{t}{trial.cond}{2});
%                         fprintf(fid,'%5.8f,',(sp.target.cprt{t}{trial.cond}{1}+sp.target.cprt{t}{trial.cond}{2})/2);
%                         fprintf(fid,'%5.8f,',power(sp.target.cprt{t}{trial.cond}{1}*sp.target.cprt{t}{trial.cond}{2},1/2));
%                     else
%                         wd = sp.preceeding.text{t}{i+1};
%                         algM=0;
%                         geoM=1;
%                         for c=1:4
%                             if c<= length(wd)
%                                 prt=mean(sp.preceeding.cprt{t}{i+1}{c});
%                                 fprintf(fid,'%d,',prt);
%                                 algM=algM+prt;
%                                 geoM=geoM*prt;
%                             else
%                                 fprintf(fid,' ,');
%                             end
%                         end
%                         fprintf(fid,'%5.8f,',mean(sp.preceeding.cprt{t}{i+1}{length(wd)}));
%                         fprintf(fid,'%5.8f,',algM/length(wd));
%                         fprintf(fid,'%5.8f,',geoM);
%                     end
%                 elseif position == 2
%                     wd = sp.following.text{t}{1};
%                     algM=0;
%                     geoM=1;
%                     for c=1:4
%                         if c<= length(wd)
%                             prt = mean(sp.following.cprt{t}{1}{c});
%                             fprintf(fid,'%5.8f,',prt);
%                             algM=algM+prt;
%                             geoM=geoM*prt;
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',mean(sp.following.cprt{t}{1}{length(wd)}));
%                     fprintf(fid,'%5.8f,',algM/length(wd));
%                     fprintf(fid,'%5.8f,',geoM);
%                 else %position==3
%                     wd = sp.following.text{t}{i+1-offset};
%                     algM=0;
%                     geoM=1;
%                     pn=0;
%                     if i+1-offset<=length(sp.following.cprt{t})
%                         for c=1:4                            
%                             if c<=length(wd) && ~any(sp.following.cprt{t}{i+1-offset}{c}==-1)
%                                 prt=mean(sp.following.cprt{t}{i+1-offset}{c});
%                                 fprintf(fid,'%5.8f,',prt);
%                                 algM=algM+prt;
%                                 geoM=geoM*prt;
%                                 pn=pn+1;
%                             else
%                                 fprintf(fid,' ,');
%                             end                            
%                         end
%                         if pn>0
%                             fprintf(fid,'%5.8f,',mean(sp.following.cprt{t}{i+1-offset}{pn}));
%                             fprintf(fid,'%5.8f,',algM/pn);
%                             fprintf(fid,'%5.8f,',geoM);
%                         else
%                             fprintf(fid,' , , ,');
%                         end
%                     else
%                         fprintf(fid,' , , , , , , ,');
%                     end                    
%                 end
%             end            
%             
%             % col 81: prevC1S  %%stoke
%             % col 82: prevC2S
%             % col 83: prevC3S
%             % col 84: prevC4S
%             % col 85: prevCLS
%             % col 86: prevCMS
%             
%             if i==1
%                 fprintf(fid,' , , , , , ,');
%             else
%                 if position <= 2
%                     wd=sp.preceeding.text{t}{i-1};
%                     if ~isempty(sp.preceeding.cstk{t}{i-1})
%                         total=0;
%                         for c=1:4
%                             if c<=length(wd)
%                                 fprintf(fid,'%5.8f,',sp.preceeding.cstk{t}{i-1}{c});
%                                 total=total+sp.preceeding.cstk{t}{i-1}{c};
%                             else
%                                 fprintf(fid,' ,');
%                             end
%                         end
%                         fprintf(fid,'%5.8f,',sp.preceeding.cstk{t}{i-1}{length(wd)});
%                         fprintf(fid,'%5.8f,',total/length(wd));
%                     else
%                         fprintf(fid,' , , , , , ,');
%                     end
%                 else
%                     if trial.roi(i-1).istarget
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{1});
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{2});
%                         fprintf(fid,' , ,');
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{2});
%                         fprintf(fid,'%5.8f,',(sp.target.cstk{t}{trial.cond}{1}+sp.target.cstk{t}{trial.cond}{2})/2);
%                     else
%                         wd = sp.following.text{t}{i-1-offset};
%                         if ~isempty(sp.following.cstk{t}{i-1-offset})
%                             total=0;
%                             for c=1:4
%                                 if c<=length(wd)
%                                     fprintf(fid,'%5.8f,',sp.following.cstk{t}{i-1-offset}{c});
%                                     total=total+sp.following.cstk{t}{i-1-offset}{c};
%                                 else
%                                     fprintf(fid,' ,');
%                                 end
%                             end
%                             fprintf(fid,'%5.8f,',sp.following.cstk{t}{i-1-offset}{length(wd)});
%                             fprintf(fid,'%5.8f,',total/length(wd));
%                         else
%                             fprintf(fid,' , , , , , ,');
%                         end
%                     end
%                 end
%             end
%             
%             % col 87: currC1S
%             % col 88: currC2S
%             % col 89: currC3S
%             % col 90: currC4S
%             % col 91: currCLS
%             % col 92: currCMS
%             
%             if position == 1
%                 wd = sp.preceeding.text{t}{i};
%                 if ~isempty(sp.preceeding.cstk{t}{i})
%                     total=0;
%                     for c=1:4
%                         if c<=length(wd)
%                             fprintf(fid,'%5.8f,',sp.preceeding.cstk{t}{i}{c});
%                             total=total+sp.preceeding.cstk{t}{i}{c};
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',sp.preceeding.cstk{t}{i}{length(wd)});
%                     fprintf(fid,'%5.8f,',total/length(wd));
%                 else
%                 end
%             elseif position == 2
%                 wd = sp.target.text{t}{trial.cond};
%                 total=0;
%                 for c=1:4
%                     if c<=length(wd)
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{c});
%                         total=total+sp.target.cstk{t}{trial.cond}{c};
%                     else
%                         fprintf(fid,' ,');
%                     end
%                 end
%                 fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{length(wd)});
%                 fprintf(fid,'%5.8f,',total/length(wd));
%             else
%                 wd = sp.following.text{t}{i-offset};
%                 if ~isempty(sp.following.cstk{t}{i-offset})
%                     total=0;
%                     for c=1:4
%                         if c<=length(wd)
%                             fprintf(fid,'%5.8f,',sp.following.cstk{t}{i-offset}{c});
%                             total=total+sp.following.cstk{t}{i-offset}{c};
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',sp.following.cstk{t}{i-offset}{length(wd)});
%                     fprintf(fid,'%5.8f,',total/length(wd));
%                 else
%                     fprintf(fid,' , , , , , ,');
%                 end
%             end
%             
%             % col 93: nextC1S
%             % col 94: nextC2S
%             % col 95: nextC3S
%             % col 96: nextC4S
%             % col 97: nextCLS
%             % col 98: nextCMS
%             
%             if i==length(trial.sentence)
%                 fprintf(fid,' , , , , , ,');
%             else
%                 if position == 1
%                     if trial.roi(i+1).istarget
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{1});
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{2});
%                         fprintf(fid,' , ,');
%                         fprintf(fid,'%5.8f,',sp.target.cstk{t}{trial.cond}{2});
%                         fprintf(fid,'%5.8f,',(sp.target.cstk{t}{trial.cond}{1}+sp.target.cstk{t}{trial.cond}{2})/2);
%                     else
%                         wd = sp.preceeding.text{t}{i+1};
%                         if ~isempty(sp.preceeding.cstk{t}{i+1})
%                             total=0;
%                             for c=1:4
%                                 if c<= length(wd)
%                                     fprintf(fid,'%5.8f,',sp.preceeding.cstk{t}{i+1}{c});
%                                     total=total+sp.preceeding.cstk{t}{i+1}{c};
%                                 else
%                                     fprintf(fid,' ,');
%                                 end
%                             end
%                             fprintf(fid,'%5.8f,',sp.preceeding.cstk{t}{i+1}{length(wd)});
%                             fprintf(fid,'%5.8f,',total/length(wd));
%                         else
%                             fprintf(fid,' , , , , , ,');
%                         end
%                     end
%                 elseif position == 2
%                     wd = sp.following.text{t}{1};
%                     total=0;
%                     for c=1:4
%                         if c<= length(wd)                            
%                             fprintf(fid,'%5.8f,',sp.following.cstk{t}{1}{c});
%                             total=total+sp.following.cstk{t}{1}{c};
%                         else
%                             fprintf(fid,' ,');
%                         end
%                     end
%                     fprintf(fid,'%5.8f,',sp.following.cstk{t}{1}{length(wd)});
%                     fprintf(fid,'%5.8f,',total/length(wd));
%                 else
%                     wd = sp.following.text{t}{i+1-offset};
%                     if ~isempty(sp.following.cstk{t}{i+1-offset})
%                         total=0;
%                         for c=1:4
%                             if c<= length(wd)
%                                 fprintf(fid,'%5.8f,',sp.following.cstk{t}{i+1-offset}{c});
%                                 total=total+sp.following.cstk{t}{i+1-offset}{c};
%                             else
%                                 fprintf(fid,' ,');
%                             end
%                         end
%                         fprintf(fid,'%5.8f,',sp.following.cstk{t}{i+1-offset}{length(wd)});
%                         fprintf(fid,'%5.8f,',total/length(wd));
%                     else
%                         fprintf(fid,' , , , , , ,');
%                     end
%                 end
%             end
%             
            fprintf(fid,'\n');
        end
    end
end

fclose(fid);
end