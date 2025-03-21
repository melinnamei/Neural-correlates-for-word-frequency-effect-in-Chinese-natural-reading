function [st]=replicateStruct(thest,st,i)
% Dr. Yanping Liu
% Yanping0000@gmail.com
% replicate a struct field by field
%
fn = fieldnames(thest);
for n = 1:length(fn)
    st=setfield(st,{i},fn{n},getfield(thest,fn{n}));
end