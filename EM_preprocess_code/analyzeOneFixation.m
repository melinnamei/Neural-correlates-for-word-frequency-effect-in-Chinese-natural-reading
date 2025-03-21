function [EM,ROIs]=analyzeOneFixation(EM,ROIs,sentence)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nextXst,nextXen,EM.nextFixedROI] = findWord(EM.nextFix.gavx,sentence);
if (isempty(EM.prevFix))
    EM.prev2Fix = EM.prevFix; 
    EM.prevFix = EM.nextFix;      
    EM.prev2FixedROI = EM.prevFixedROI;
    EM.prevFixedROI = EM.nextFixedROI;
    
    if EM.nextFixedROI>0 && EM.nextFixedROI<=length(sentence) && ~ROIs(EM.nextFixedROI).comingin
        ROIs(EM.nextFixedROI).comingin=1;
    end
    
    if (EM.nextFixedROI>0 && EM.nextFixedROI<=length(sentence))
        for i=1:EM.nextFixedROI
            if (i==EM.nextFixedROI)
                ROIs(i).ffd  = EM.nextFix.time;
                ROIs(i).gd   = EM.nextFix.time;
                ROIs(i).tt   = EM.nextFix.time;
				ROIs(i).blink= ROIs(i).blink + isBlinked(EM.nextFix);
                ROIs(i).fn   = 1;
                
                % melinna edit 2023/02/05 because in this case only has one
                % fixation, the first one is also the last one
                ROIs(i).lastfixation  = EM.nextFix.time;
                
              
                EM.maxX     = EM.nextFix.gavx;
                
                
                [ROIs]=saveFixation(ROIs,EM.nextFixedROI,EM.nextFix,(nextXst+nextXen)/2);
            else
                ROIs(i).skipped=1;
            end
        end
    end
    return;
end

[prevXst,prevXen,EM.prevFixedROI] = findWord(EM.prevFix.gavx,sentence);

if (EM.nextFix.gavx>EM.maxX)
    if (EM.nextFixedROI>0 && EM.nextFixedROI<=length(sentence))
        if (EM.prevFixedROI<EM.nextFixedROI)
            if (ROIs(EM.nextFixedROI).fn == 0 && ~ROIs(EM.nextFixedROI).comingin)
                ROIs(EM.nextFixedROI).ffd = EM.nextFix.time;
                ROIs(EM.nextFixedROI).gd  = EM.nextFix.time;
                ROIs(EM.nextFixedROI).tt  = EM.nextFix.time;
                ROIs(EM.nextFixedROI).blink = ROIs(EM.nextFixedROI).blink+isBlinked(EM.nextFix);
                ROIs(EM.nextFixedROI).fn  = 1;
                
                
                % melinna edit 2023/02/05 because in this case only has one
                % fixation, the first one is also the last one
                ROIs(EM.nextFixedROI).lastfixation = EM.nextFix.time;
                
                ROIs(EM.nextFixedROI).comingin=1;
                
                [ROIs]=saveFixation(ROIs,EM.nextFixedROI,EM.nextFix,(nextXst+nextXen)/2);
                [ROIs]=saveIncoming(ROIs,EM.nextFixedROI,EM.prev2Fix,EM.prevFix,EM.nextFix,nextXst);
                
                if (EM.prevFixedROI>0 && EM.prevFixedROI<=length(sentence) && ...
                        ~ROIs(EM.prevFixedROI).goingout && ~ROIs(EM.prevFixedROI).skipped)
                                                           
                    [ROIs]=saveProgress(ROIs,EM.prevFixedROI,EM.prev2Fix,EM.prevFix,EM.nextFix,prevXen);                   
                    [ROIs]=saveOutgoing(ROIs,EM.prevFixedROI,EM.prev2Fix,EM.prevFix,EM.nextFix,prevXen);
                end
            else
                ROIs(EM.nextFixedROI).regin = ROIs(EM.nextFixedROI).regin + 1;
                ROIs(EM.nextFixedROI).tt  = ROIs(EM.nextFixedROI).tt + EM.nextFix.time;
            end
        elseif (EM.prevFixedROI==EM.nextFixedROI)
            if (~ROIs(EM.nextFixedROI).goingout&&~ROIs(EM.nextFixedROI).skipped&&~ROIs(EM.nextFixedROI).regout)
                ROIs(EM.nextFixedROI).gd = ROIs(EM.nextFixedROI).gd+EM.nextFix.time;
                ROIs(EM.nextFixedROI).tt = ROIs(EM.nextFixedROI).tt+EM.nextFix.time;
                ROIs(EM.nextFixedROI).blink = ROIs(EM.nextFixedROI).blink+isBlinked(EM.nextFix);
                ROIs(EM.nextFixedROI).fn = ROIs(EM.nextFixedROI).fn+1;
                
                
                % melinna edit 2023/02/05
                ROIs(EM.nextFixedROI).lastfixation=EM.nextFix.time;
                               
                [ROIs]=saveFixation(ROIs,EM.nextFixedROI,EM.nextFix,(nextXst+nextXen)/2);
                [ROIs]=saveProgress(ROIs,EM.nextFixedROI,EM.prev2Fix,EM.prevFix,EM.nextFix,prevXen);
            else
                ROIs(EM.nextFixedROI).tt = ROIs(EM.nextFixedROI).tt+EM.nextFix.time;
            end
        end
    end
    
    EM.maxX = EM.nextFix.gavx;
    
    if (EM.nextFixedROI-EM.prevFixedROI>1)
        for i=EM.prevFixedROI+1:EM.nextFixedROI-1
            if (i>0 && i<=length(sentence)&&~ROIs(i).fn&&~ROIs(i).skipped&&~ROIs(i).comingin&&~ROIs(i).goingout)
                ROIs(i).skipped=1;
            end
        end
    end
    
    if EM.prevFixedROI>0&&EM.prevFixedROI<=length(sentence)&&~ROIs(EM.prevFixedROI).goingout&&EM.nextFixedROI~=EM.prevFixedROI
        ROIs(EM.prevFixedROI).goingout=1;
    end
    
else %% x<= maxX
    if (EM.nextFixedROI>0 && EM.nextFixedROI<=length(sentence))
        if (EM.nextFixedROI==EM.prevFixedROI && ~ROIs(EM.nextFixedROI).goingout && ...
            ~ROIs(EM.nextFixedROI).regout && ~ROIs(EM.nextFixedROI).skipped)
%             if (~isfield(ROIs(EM.nextFixedROI),'gd')||isempty(ROIs(EM.nextFixedROI).gd))
%                 ROIs(EM.nextFixedROI).gd = EM.nextFix.time;
%             else
%                 ROIs(EM.nextFixedROI).gd = ROIs(EM.nextFixedROI).gd+EM.nextFix.time;
%             end
            ROIs(EM.nextFixedROI).gd = ROIs(EM.nextFixedROI).gd+EM.nextFix.time;
            %ROIs(EM.nextFixedROI).fn = ROIs(EM.nextFixedROI).fn+1;
            ROIs(EM.nextFixedROI).blink = ROIs(EM.nextFixedROI).blink+isBlinked(EM.nextFix);
            
            [ROIs]=saveFixation(ROIs,EM.nextFixedROI,EM.nextFix,(nextXst+nextXen)/2);
        end
        if (~isfield(ROIs(EM.nextFixedROI),'tt')||isempty(ROIs(EM.nextFixedROI).tt))
            ROIs(EM.nextFixedROI).tt = EM.nextFix.time;
        else
            ROIs(EM.nextFixedROI).tt = ROIs(EM.nextFixedROI).tt + EM.nextFix.time;
        end
        if (EM.nextFixedROI~=EM.prevFixedROI && (ROIs(EM.nextFixedROI).goingout || ...
            ROIs(EM.nextFixedROI).regout || ROIs(EM.nextFixedROI).skipped))
            ROIs(EM.nextFixedROI).regin = ROIs(EM.nextFixedROI).regin + 1;
        end
    end
	if (EM.prevFixedROI>0 && EM.prevFixedROI<=length(sentence))
		if (EM.nextFixedROI<EM.prevFixedROI)
			ROIs(EM.prevFixedROI).regout=ROIs(EM.prevFixedROI).regout+1;
		end
	end
end

if (EM.prevFixedROI~=EM.nextFixedROI && EM.prevFixedROI>0 && EM.prevFixedROI<=length(sentence))
    ROIs(EM.prevFixedROI).goingout=1;
end

EM.prev2FixedROI = EM.prevFixedROI;
EM.prevFixedROI = EM.nextFixedROI;
EM.prev2Fix = EM.prevFix;
EM.prevFix = EM.nextFix;
return;
end

function [ROIs]=saveFixation(ROIs,id,fix,wc)
i=0;
if (isfield(ROIs(id),'fixation')&&~isempty(ROIs(id).fixation))
    i=size(ROIs(id).fixation,1);
end

ROIs(id).fixation(i+1,1)=isBlinked(fix);
ROIs(id).fixation(i+1,2)=fix.time;
ROIs(id).fixation(i+1,3)=fix.gavx-wc;
ROIs(id).fixation(i+1,4)=i+1;
end

function [ROIs]=saveIncoming(ROIs,id,pre2fix,prefix,nexfix,nexxbegin)
i=0;
if (isfield(ROIs(id),'incoming')&&~isempty(ROIs(id).incoming))
    i=size(ROIs(id).incoming,1);
end

ROIs(id).incoming(i+1,1)=isBlinked(nexfix);
if isempty(pre2fix)  %nearest fixation distance
    ROIs(id).incoming(i+1,2)=NaN;
else
    ROIs(id).incoming(i+1,2)=prefix.gavx - pre2fix.gavx;
end
ROIs(id).incoming(i+1,3)=prefix.time;
ROIs(id).incoming(i+1,4)=prefix.gavx-nexxbegin;
ROIs(id).incoming(i+1,5)=nexfix.gavx-prefix.gavx;
ROIs(id).incoming(i+1,6)=nexfix.time;
ROIs(id).incoming(i+1,7)=nexfix.gavx-nexxbegin;
ROIs(id).incoming(i+1,8)=i+1;
end

function [ROIs]=saveOutgoing(ROIs,id,pre2fix,prefix,nexfix,prexend)
i=0;
if (isfield(ROIs(id),'outgoing')&&~isempty(ROIs(id).outgoing))
    i=size(ROIs(id).outgoing,1);
end

ROIs(id).outgoing(i+1,1)=isBlinked(nexfix);
if isempty(pre2fix)  %nearest fixation distance
    ROIs(id).outgoing(i+1,2)=NaN;
else
    ROIs(id).outgoing(i+1,2)=prefix.gavx - pre2fix.gavx;
end
ROIs(id).outgoing(i+1,3)=prefix.time;
ROIs(id).outgoing(i+1,4)=prefix.gavx-prexend;
ROIs(id).outgoing(i+1,5)=nexfix.gavx-prefix.gavx;
ROIs(id).outgoing(i+1,6)=nexfix.time;
ROIs(id).outgoing(i+1,7)=nexfix.gavx-prexend;
ROIs(id).outgoing(i+1,8)=i+1;
end

function [ROIs]=saveProgress(ROIs,id,pre2fix,prefix,nexfix,prexend)
i=0;
if (isfield(ROIs(id),'progress')&&~isempty(ROIs(id).progress))
    i=size(ROIs(id).progress,1);
end

ROIs(id).progress(i+1,1)=isBlinked(nexfix);
if isempty(pre2fix)  %nearest fixation distance
    ROIs(id).progress(i+1,2)=NaN;
else
    ROIs(id).progress(i+1,2)=prefix.gavx - pre2fix.gavx;
end
ROIs(id).progress(i+1,3)=prefix.time;
ROIs(id).progress(i+1,4)=prefix.gavx-prexend;
ROIs(id).progress(i+1,5)=nexfix.gavx-prefix.gavx;
ROIs(id).progress(i+1,6)=nexfix.time;
ROIs(id).progress(i+1,7)=nexfix.gavx-prexend;
ROIs(id).progress(i+1,8)=i+1;
end

function [Xst,Xen,id]=findWord(x,sentence)
Xst=600;
Xen=600;
if (x<=Xst)
    id=0;
else
    for w=1:length(sentence)
        Xen=Xst+53*length(sentence{w});
        
        if (x>Xst && x<=Xen)
            id=w;
            break;
        end
        Xst=Xen;
    end
    if (x>Xen)
        id=length(sentence)+1;
        Xst=Xen;
    end
end
end

function [blinked]=isBlinked(nexfix)
blinked=0;
if (isfield(nexfix,'blink')&&~isempty(nexfix.blink)&&nexfix.blink)
	blinked=1;
end
end