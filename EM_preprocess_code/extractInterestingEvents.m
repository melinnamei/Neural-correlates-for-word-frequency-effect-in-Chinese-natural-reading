function [Trials]=extractInterestingEvents(Trials)
%  Dr. Yanping Liu
%  email: liuyp33@mail.sysu.edu.cn
%
%  edfExtractInterestingEvents
%  Extract fixations, saccades, blinks and button presses from events and
%  places them into new fields within Trial structure.
%
%  Syntax:
%    Trials= edfExtractInterestingEvents(Trials)
%
%  Description"
%    Trials= edfExtractInterestingEvents(Trials)} extact fixations,
%    saccades, blinks and button presses from events and places them, respectively, into
%    Fixations, Saccades, Blinks and Buttons field in the updated Trials structure.
%    New substructures contain the following fields (see details in EDF API
%    manual):
%    * Fixations: eye, sttime, entime, time, gavx, gavy, PixInDegX,
%      PixInDegY
%    * Saccades: eye, sttime, entime, time, gstx, gsty, genx, geny, avel,
%      pvel, ampl, phi, PixInDegX, PixInDegY
%    * Blinks:  eye, sttime, entime, time
%    * Buttons: ID, Pressed, time

for iT=1:length(Trials),
    %% preparing service variables and arrays
    %% saccades
    iS=1;
    Saccades=[];
    SaccadeStart=[0 0];
    
    %% fixations
    iF=1;
    Fixations=[];
    FixationStart=[0 0];
    
    %% blinks
    iB=1;
    Blinks=[];
    BlinkStart=[0 0];
    
    %% button events
    iBut=1;
    Buttons=[];
    ButtonState=[0 0 0 0];
    
    %Events=Trials(iT).Events;
    
    %% finding start of recording
    Trials(iT).StartTime=edfFindTrialRecordingStart(Trials(iT).Events);
    StartTime=Trials(iT).StartTime;
    if (isempty(StartTime))
        Trials(iT).StartTime=Trials(iT).Events.sttime(1);
        StartTime=Trials(iT).StartTime;
        %continue;
    end;    
    
    %% going through all events
    for iE=1:length(Trials(iT).Events.type),
        eye=Trials(iT).Events.eye(iE);
        switch (Trials(iT).Events.type(iE))
            case 3 %% Blink start
                BlinkStart(eye+1)=Trials(iT).Events.sttime(iE);
            case 4 %% Blink end
                Blinks(iB).eye=eye;
                Blinks(iB).sttime=BlinkStart(eye+1)-StartTime;
                Blinks(iB).entime=Trials(iT).Events.entime(iE)-StartTime;
                Blinks(iB).time=Blinks(iB).entime-Blinks(iB).sttime;
                iB=iB+1;
            case 5 %% Saccade start
                SaccadeStart(eye+1)=Trials(iT).Events.sttime(iE);
            case 6 %% Saccade end
                Saccades(iS).eye=eye;
                Saccades(iS).sttime=SaccadeStart(eye+1)-StartTime;
                Saccades(iS).entime=Trials(iT).Events.entime(iE)-StartTime;
                Saccades(iS).time=Saccades(iS).entime-Saccades(iS).sttime;
                Saccades(iS).gstx=Trials(iT).Events.gstx(iE);
                Saccades(iS).gsty=Trials(iT).Events.gsty(iE);
                Saccades(iS).genx=Trials(iT).Events.genx(iE);
                Saccades(iS).geny=Trials(iT).Events.geny(iE);
                Saccades(iS).avel=Trials(iT).Events.avel(iE);
                Saccades(iS).pvel=Trials(iT).Events.pvel(iE);
                Saccades(iS).ampl=hypot((Saccades(iS).genx-Saccades(iS).gstx)/mean([Trials(iT).Events.eupd_x(iE) Trials(iT).Events.supd_x(iE)]),...
                    (Saccades(iS).geny-Saccades(iS).gsty)/mean([Trials(iT).Events.eupd_y(iE) Trials(iT).Events.supd_y(iE)]));
                Saccades(iS).phi=atan2(Saccades(iS).geny-Saccades(iS).gsty, Saccades(iS).genx-Saccades(iS).gstx)*180/pi;
                Saccades(iS).PixInDegX=mean([Trials(iT).Events.supd_x(iE) Trials(iT).Events.eupd_x(iE)]);
                Saccades(iS).PixInDegY=mean([Trials(iT).Events.supd_y(iE) Trials(iT).Events.eupd_y(iE)]);
                iS=iS+1;
            case 7 %% Fixation start
                FixationStart(eye+1)= Trials(iT).Events.sttime(iE);
            case 8 %% Fixation end
                Fixations(iF).eye=eye;
                Fixations(iF).sttime=FixationStart(eye+1)-StartTime;
                Fixations(iF).entime=Trials(iT).Events.entime(iE)-StartTime;
                Fixations(iF).time=Fixations(iF).entime-Fixations(iF).sttime;
                Fixations(iF).gavx=Trials(iT).Events.gavx(iE);
                Fixations(iF).gavy=Trials(iT).Events.gavy(iE);
                Fixations(iF).PixInDegX=mean([Trials(iT).Events.supd_x(iE) Trials(iT).Events.eupd_x(iE)]);
                Fixations(iF).PixInDegY=mean([Trials(iT).Events.supd_y(iE) Trials(iT).Events.eupd_y(iE)]);
                iF=iF+1;
            case 24 %% Messageevent
                s=Trials(iT).Events.message{iE};
                if (~isempty(strfind(s,'Trialid T')))
                    Trials(iT).trialid=s(10:end);
                end
                if (~isempty(strfind(s,'Sentid E')))
                    eid = strfind(s,'E');
                    cid = strfind(s,'C');
                    Trials(iT).sentid=str2num(s(eid+1:cid-1));
                    Trials(iT).cond=str2num(s(cid+1:end));
                end
                if (~isempty(strfind(s,'SYNCTIME')))
                    Trials(iT).strec=Trials(iT).Events.sttime(iE)-StartTime;
                end
                if (~isempty(strfind(s,'SYNCEND')))
                    Trials(iT).enrec=Trials(iT).Events.sttime(iE)-StartTime;
                end
%                 
%                 if (~isempty(strfind(s,'Sent MYKEYWORD 100')))
%                     Trials(iT).strec=Trials(iT).Events.sttime(iE)-StartTime;
%                 end
                if (~isempty(strfind(s,'Sent MYKEYWORD 200')))
                    Trials(iT).enrec=Trials(iT).Events.sttime(iE)-StartTime;
                end
                
                if (strcmp(s,'L')||strcmp(s,'R'))
                    Trials(iT).ans=s;
                end
            case 25 %% Change in button state
                if (Trials(iT).Events.sttime(iE)-StartTime>0)
                    for iButton= 1:4,
                        NewButtonState=bitand(Trials(iT).Events.buttons(iE), 2^(iButton-1))>0;
                        if (NewButtonState~=ButtonState(iButton))
                            Buttons(iBut).ID=iButton;
                            Buttons(iBut).Pressed=NewButtonState;
                            Buttons(iBut).time=Trials(iT).Events.sttime(iE)-StartTime;
                            iBut=iBut+1;
                        end;
                        ButtonState(iButton)=NewButtonState;
                    end;
                end;
        end;
    end;
    
    %% copying results
    Trials(iT).Fixations=Fixations;
    Trials(iT).Saccades=Saccades;
    Trials(iT).Blinks=Blinks;
    Trials(iT).Buttons=Buttons;
end
end
