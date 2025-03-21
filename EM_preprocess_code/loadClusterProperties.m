function [clusters]=loadClusterProperties()
%
clusters={};
mx=getCodeMX();
for c=1:330
    for r=1:8
        clusters{r,c}=generateSymbol(r,mx(r,c));
    end
end
end

function [cluster]=generateSymbol(r,code)
code=num2str(code);

cluster.id=r;
cluster.istarget=0;
if length(code)>7
    cluster.istarget=1;
    code=code(2:end);
end

cluster.isexemplar = strcmp(code(1),'2')&strcmp(code(4),'2')&strcmp(code(5),'2'); 

cluster.clustersize = str2num(code(1));
cluster.orient      = str2num(code(2));
cluster.gapsize     = str2num(code(3));
cluster.angledev(1) = str2num(code(4)); %1-3 = -1,0,1 angle rotate
cluster.angledev(2) = str2num(code(5));
cluster.angledev(3) = str2num(code(6));
cluster.angledev(4) = str2num(code(7));
cluster.code        = str2num(code);
end