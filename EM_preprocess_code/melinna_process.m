% date: 2023/01/12 contact: melinna@live.cn
% subject 1 was no longer in consideration, because of the incomplete
% recording.

clear;clc;
destination=pwd;
D=dir([destination(1:end-6),'data/*.EDF']);

s=2;
while (s<=32)    % the biggest sbj number is 32
    
    filename=[D(1).folder,'\sub',num2str(s)]
    Subs(s)=loadSub(filename);
    s=s+1;
end

[sp]=loadProperties();
mc_extractEMS(Subs,sp);
