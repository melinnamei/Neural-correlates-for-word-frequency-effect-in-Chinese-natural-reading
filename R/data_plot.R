library(lmerTest)
library(lme4)
library(ggplot2)
library(dplyr)
library(sjPlot)
library(ggsignif)
library(gridExtra)


######## load data
rm(list=ls())

current_wd<-getwd()

setwd(current_wd)

roidat_raw<-read.delim('data/frequency_effect_EEG_EM_2023.txt', sep = '\t',header = TRUE)

roidat<-subset(roidat_raw,curristarget==1)

roidat<-subset(roidat,ffd>50)
roidat<-subset(roidat,ffd<800)
roidat<-subset(roidat,gd<1000)

# remove sbj 10 for the bad EEG recording
roidat<-roidat[roidat$subjectid!=10,]

roidat<-mutate(roidat,WF = ifelse(cond==1|cond==2,1, 2))

# 1 stands for target words high frequency condition, and 2 stands for low frequency 

# remove the outliers based on two criterion, 3 SD outlier or 5% percentile outlier, choose one
data2use<-data.frame()
# no sbj 1
for (i in c(1:32)) {
  data_tmp<-subset(roidat,subjectid == i  )
  tmp_ffd<-mean(data_tmp$ffd)
  ## if use exceeding 3 SD as outliers
  tmp_sd<-sd(data_tmp$ffd)
  out=c(tmp_ffd-tmp_sd*3,tmp_ffd+tmp_sd*3)
  
  ## remove the outliers
  out_v<-c(data_tmp$ffd<out[1]|data_tmp$ffd>out[2])
  print(sum(out_v))
  data2use<- rbind(data2use,subset(data_tmp,ffd>out[1]&ffd<out[2]))
}



roidat<-data2use
roidat<-mutate(roidat,WF = ifelse(cond==1|cond==2,'HF', 'LF'))
roidat$WF <- factor(roidat$WF,levels=c("HF", "LF"))

roidat<-roidat[roidat$subjectid!=10,]


p1 <- ggplot(roidat, aes(x=WF, y=ffd,fill=WF)) + 
    geom_violin(trim=TRUE)

p1<-p1 + scale_y_continuous(limits=c(100,400))+ geom_boxplot(width=0.1)


p1<-p1+scale_x_discrete(name ="", limits=c("HF","LF"))
p1<-p1+scale_fill_manual(values=c("#a4d7eb", "#fcbfa4")) + theme_classic()
p1<-p1+labs(x="Frequency", y = "FFD")+scale_x_discrete(labels=c("HF" = "HF", "LF" = "LF"))
p1<-p1+ geom_segment(aes(x = 1.2, y = 400, xend = 1.8, yend = 400))+ theme(legend.position="none")
p1<-p1+geom_text(x = 1.5, y = 405, label = "*",size=10)
p1<-p1+theme(text = element_text(size = 20)) 

p1

p2 <- ggplot(roidat, aes(x=WF, y=gd,fill=WF)) + 
    geom_violin(trim=TRUE)
p2<-p2 + scale_y_continuous(limits=c(100,400))+ geom_boxplot(width=0.1)
p2<-p2+scale_fill_manual(values=c("#a4d7eb", "#fcbfa4")) + theme_classic()
p2
p2<-p2+labs(x="Frequency", y = "GD")+scale_x_discrete(labels=c("HF" = "HF", "LF" = "LF"))
p2<-p2+ geom_segment(aes(x = 1.2, y = 400, xend = 1.8, yend = 400))+ theme(legend.position="none")
p2<-p2+geom_text(x = 1.5, y = 405, label = "***",size=10)
p2<-p2+theme(text = element_text(size = 20)) 



p3 <- ggplot(roidat, aes(x=WF, y=tt,fill=WF)) + 
    geom_violin(trim=TRUE)

p3<-p3 + scale_y_continuous(limits=c(100,800))+ geom_boxplot(width=0.1)
p3<-p3+scale_fill_manual(values=c("#a4d7eb", "#fcbfa4")) + theme_classic()

#p3<-p3+scale_x_discrete(name ="??F5", limits=c("??F5","??F5"))+ theme(legend.position="none")
p3<-p3+labs(x="Frequency", y = "TT")+scale_x_discrete(labels=c("HF" = "HF", "LF" = "LF"))
p3<-p3+ geom_segment(aes(x = 1.2, y = 800, xend = 1.8, yend = 800))+ theme(legend.position="none")
p3<-p3+geom_text(x = 1.5, y = 805, label = "***",size=10)

p3<-p3+theme(text = element_text(size = 20)) 

p3

bmp("output_result/fig3.bmp",
    width=10, height=8,units="in",res=400)
grid.arrange(p1,p2,p3,nrow=1)
dev.off()


### Pre target
roidat<-subset(roidat_raw,nextistarget==1)
roidat<-subset(roidat,ffd>50)
roidat<-subset(roidat,ffd<800)
roidat<-subset(roidat,gd<1000)

# remove the outliers choose one
data2use<-data.frame()
# no sbj 1
for (i in c(1:32)) {
    data_tmp<-subset(roidat,subjectid == i  )
    tmp_ffd<-mean(data_tmp$ffd)
    ## if use exceeding 3 SD as outliers
    tmp_sd<-sd(data_tmp$ffd)
    out=c(tmp_ffd-tmp_sd*3,tmp_ffd+tmp_sd*3)
    
    ## remove the outliers
    out_v<-c(data_tmp$ffd<out[1]|data_tmp$ffd>out[2])
    print(sum(out_v))
    data2use<- rbind(data2use,subset(data_tmp,ffd>out[1]&ffd<out[2]))
}


roidat<-data2use

roidat<-mutate(roidat,WF = ifelse(cond==1|cond==2,'HF', 'LF'))
roidat$WF <- factor(roidat$WF,levels=c("HF", "LF"))
roidat<-roidat[roidat$subjectid!=10,]


p1 <- ggplot(roidat, aes(x=WF, y=ffd,fill=WF)) + 
    geom_violin(trim=TRUE)

p1<-p1 + scale_y_continuous(limits=c(100,400))+ geom_boxplot(width=0.1)
p1<-p1+scale_x_discrete(name ="??F5", limits=c("HF","LF"))
p1<-p1+scale_fill_manual(values=c("#a4d7eb", "#fcbfa4")) + theme_classic()
p1<-p1+labs(x="?X<???G0", y = "FFD")+scale_x_discrete(labels=c("HF" = "??F5", "LF" = "??F5"))
p1<-p1+ theme(legend.position="none")
p1<-p1+theme(text = element_text(size = 20)) 


p2 <- ggplot(roidat, aes(x=WF, y=gd,fill=WF)) + 
    geom_violin(trim=TRUE)
p2<-p2 + scale_y_continuous(limits=c(100,400))+ geom_boxplot(width=0.1)
p2<-p2+scale_fill_manual(values=c("#a4d7eb", "#fcbfa4")) + theme_classic()
p2<-p2+scale_x_discrete(name ="??F5", limits=c("??F5","??F5"))
p2<-p2+labs(x="?X<???G0", y = "GD")+scale_x_discrete(labels=c("HF" = "??F5", "LF" = "??F5"))
p2<-p2+ theme(legend.position="none")
p2<-p2+theme(text = element_text(size = 20)) 



p3 <- ggplot(roidat, aes(x=WF, y=tt,fill=WF)) + 
    geom_violin(trim=TRUE)
p3<-p3 + scale_y_continuous(limits=c(100,800))+ geom_boxplot(width=0.1)
p3<-p3+scale_fill_manual(values=c("#a4d7eb", "#fcbfa4")) + theme_classic()
p3<-p3+scale_x_discrete(name ="??F5", limits=c("??F5","??F5"))
p3<-p3+labs(x="?X<???G0", y = "??W"??J1??(total viewing time)")+scale_x_discrete(labels=c("HF" = "??F5", "LF" = "??F5"))

p3<-p3+ theme(legend.position="none")
p3<-p3+theme(text = element_text(size = 20)) 
bmp("Study2_Pre_target_Frequency_effect_ET.bmp",
    width=10, height=8,units="in",res=400)
grid.arrange(p1,p2,p3,nrow=1)
dev.off()

