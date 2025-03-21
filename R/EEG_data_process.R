# revised date:2023/11/14, first round APP
# revised date:2024/03/25, second round APP

# please contact melinna@live.cn

# the used data here have been already preprocessed by the method reported in (Dimigen, 2011) and (Degno,2021).... 
# purpose of this script:

# 1 Do statistics for the FRPs for target words analysis 
# 2 Generate the output result 

#library(RePsychLing)
library(lmerTest)
library(lme4)
library(ggplot2)
library(dplyr)
library(sjPlot)
library(dplyr)
library(emmeans)

######## load data
rm(list=ls())
c_work<-getwd()
setwd(c_work)

# load the data
# change the filename to get different kinds of  analysis
# file: EEG_result_point_by_point is the target word analysis
roidat<-read.csv('data/EEG_result_point_by_point.csv',header=TRUE) # average as reference 

# condition 1 stands for high frequency, 2 stands for low frequency
roidat<-mutate(roidat,frequency = ifelse(condition==1,'HF', 'LF'))
roidat$frequency <- factor(roidat$frequency,levels=c("HF", "LF"))

# get the electrode number and use them to define ROI from the EEG topo 

Frontal_cen<-c(18,19,20,28)# Fcz, C1,CZ, and C2
CEN_par<-c(37,45,46,47) # CPz, P1,PZ,P2
Left_OT<-c(51,52,53,58) # PO7,PO5,PO3,and o1
Right_OT=c(55,56,57,60) # PO8,PO6,PO4, and O2


roidat$ROI<-roidat$elec

ROI<-list(Frontal_cen,CEN_par,Left_OT,Right_OT)

roidat<- mutate(roidat,ROI = if_else(elec %in% Frontal_cen, "Front",if_else(elec %in% CEN_par, "CEN_par",if_else(elec %in% Left_OT ,'Left_OT',if_else(elec %in% Right_OT,'Right_OT', 'No')))))
roidat$ROI<-factor(roidat$ROI)

#-------------------------- first part  target word analysis----

roidat$BS<-apply(roidat[,104:203],1,mean) # correspond to baseline -100~0 ms Baseline
roidat$P1<-apply(roidat[,304:343],1,mean) # correspond to baseline 100~140 ms P1
roidat$N200<-apply(roidat[,364:503],1,mean) # correspond to baseline 160~300 ms N200
roidat$N400<-apply(roidat[,504:703],1,mean) # correspond to baseline 300~500 ms N400

# narrow down the time window for later extra analysis
roidat$P1_extra<-apply(roidat[,314:333],1,mean) # correspond to baseline 110~130 ms P1

roidat2<-subset(roidat, !(ROI %in% 'No') ) # only select the ROI analysis
roidat2$ROI<-factor(roidat2$ROI)


# do analysis for baseline 
## It will start from full model measures~ frequency*ROI+(1+frequency+ROI|subjectid).
## If the model encounters boundary singular or fails to converge, the slope drops ROI and then frequency
#m1<-lmer(BS ~ frequency*ROI+(1+frequency+ROI|subjectid), data=roidat2),dropped because of singular 

m1<-lmer(BS ~ frequency*ROI+(1+frequency|subjectid), data=roidat2)
anova(m1)
emmeans(m1,pairwise~ROI,adjust='mvt')


# do analysis for P1
n1<-lmer(P1 ~ frequency*ROI+(1+frequency+ROI|subjectid), data=roidat2)
anova(n1)
emmeans(n1,pairwise~frequency|ROI,adjust='mvt')


# check the bilateral occipital seperately, this is extra analysis in P1 time window
rr<-subset(roidat2,ROI=='Left_OT')
r1<-lmer(P1~frequency+(frequency|subjectid),data=rr,REML = F)
summary(r1)

rr<-subset(roidat2,ROI=='Right_OT')
r1<-lmer(P1~frequency+(frequency|subjectid),data=rr,REML = F)
summary(r1)

# narrow down the time window to do P1 extra analysis 

rr<-subset(roidat2,ROI=='Left_OT')
r1<-lmer(P1_extra~frequency+(frequency|subjectid),data=rr)
summary(r1)

rr<-subset(roidat2,ROI=='Right_OT')
r1<-lmer(P1_extra~frequency+(frequency|subjectid),data=rr)
summary(r1)

# end of exploration of P1


# do analysis for N200
t1<-lmer(N200 ~ frequency*ROI+(1+frequency+ROI|subjectid), data=roidat2)
anova(t1)

# post-hoc 
emmeans(t1,pairwise~frequency|ROI,adjust='mvt')


# do analysis for N400
z1<-lmer(N400 ~ frequency*ROI+(1+frequency+ROI|subjectid), data=roidat2)
anova(z1)

# post-hoc 
emmeans(z1,pairwise~frequency|ROI,adjust='mvt')

