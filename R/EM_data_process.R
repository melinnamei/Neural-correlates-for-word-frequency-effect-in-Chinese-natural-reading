# revised date:2023/11/14
# if you have any questions in processing, please contact:melinna@live.cn
# purpose of this script: 
# 1 preprocessing the ET data, 
# 2 generate guided trials for EEG analysis, 
# 3 do statistics, 
# 4 and generate the output result 

#library(RePsychLing)
library(lmerTest)
library(lme4)
library(ggplot2)
library(dplyr)
library(sjPlot)
library(gridExtra)

# prepare the path
rm(list=ls())
current_path<-getwd()
setwd(current_path)


######## load data
# this file is generatd from the ET preprocessing under the folder /melinna/script
roidat_raw<-read.delim('data/frequency_effect_EEG_EM_2023.txt', header = TRUE)

##------------------------------------First Part-----
# ---------------------- the target word analysis--
roidat<-subset(roidat_raw,curristarget==1)

# calculate the acuracy rate
wrong_idx=which(roidat$acc==0)
the_acc=(nrow(roidat)-length(wrong_idx))/nrow(roidat)
sprintf('The overall acc is %.2f',the_acc)

roidat<-subset(roidat,ffd>50)
roidat<-subset(roidat,ffd<800)
roidat<-subset(roidat,gd<1000)

# remove sbj 10 for the bad EEG recording
roidat<-roidat[roidat$subjectid!=10,]
# 1 stands for target words high frequency condition, and 2 stands for low frequency 
roidat<-mutate(roidat,WF = ifelse(cond==1|cond==2,1, 2))

# remove the outliers based on exceeding 3 SD criterion,

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


# sort the data by subjectid and trialid
attach(data2use)
data2use <- data2use[order(subjectid,trialid),]
detach(data2use)
roidat<-data2use

# select the useful information in the following columns
sentid_from_EM<-roidat[,c(1:4,26)]

# export the preprocessed trails for selection in EEG analysis

write.csv(sentid_from_EM,file='output_result/sentid_from_EM.csv',row.names = FALSE)

## Do the statistical analysis, maily lmer

## It will start from full model measures~ WF+(1+WF)|subjectid+(1+WF)|triaid.
## If the model encounters boundary singular or fails to converge, the slope will be dropped gradually from trailid to subjectid

### FFD
#m0 = lmer(ffd  ~ WF+(1+WF|subjectid)+(1+WF|trialid), data=roidat), dropped because of singular 
#m0 = lmer(ffd  ~ WF+(1+WF|subjectid)+(1|trialid), data=roidat), dropped because of singular 
m0 = lmer(ffd  ~ WF+(1|subjectid)+(1|trialid), data=roidat,REML=F)
summary(m0)

### GD
#m1 = lmer(gd ~ WF+(1+WF|subjectid)+(1+WF|trialid), data=roidat),failed to converge
#m1 = lmer(gd ~ WF+(1+WF|subjectid)+(1|trialid), data=roidat),dropped because of singular 
m1 = lmer(gd ~ WF+(1|subjectid)+(1|trialid), data=roidat,REML=F)
summary(m1)


### TT
m2 = lmer(tt ~ WF+(1+WF|subjectid)+(1+WF|trialid), data=roidat,REML=F)
summary(m2)


sjPlot::tab_model(m0,m1, m2, show.re.var=FALSE,show.ci = FALSE,show.obs = FALSE,
          show.se = TRUE,emph.p = TRUE,show.icc = FALSE,show.ngroups = FALSE,
          show.r2 = FALSE,auto.label = FALSE,pred.labels = c('intercept','WF'),show.stat = TRUE,
          dv.labels=c('FFD','GD','TT'),string.se = 'SE',file='output_result/target_ET.doc')


##-------step 2 do extra analysis on the first fixation duration of pre-target  ----

roidat<-subset(roidat_raw,nextistarget==1)

roidat<-subset(roidat,ffd>50)
roidat<-subset(roidat,ffd<800)
roidat<-subset(roidat,gd<1000)

# remove sbj 10 for the bad EEG recording
roidat<-roidat[roidat$subjectid!=10,]
# 1 stands for target words high frequency condition, and 2 stands for low frequency 
roidat<-mutate(roidat,WF = ifelse(cond==1|cond==2,1, 2))

# remove the outliers based on exceeding 3 SD criterion,

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


# sort the data by subjectid and trialid
attach(data2use)
data2use <- data2use[order(subjectid,trialid),]
detach(data2use)
roidat<-data2use

# select the useful information in the following columns
sentid_from_EM<-roidat[,c(1:4,26)]

# export the preprocessed trails for selection in EEG analysis

write.csv(sentid_from_EM,file='output_result/sentid_from_EM_pretarget_ffd.csv',row.names = FALSE)

## Do the statistical analysis, maily lmer

## It will start from full model measures~ WF+(1+WF)|subjectid+(1+WF)|triaid.
## If the model encounters boundary singular or fails to converge, the slope will be dropped gradually from trailid to subjectid

#m0 = lmer(ffd  ~ WF+(1+WF|subjectid)+(1+WF|trialid), data=roidat) failed to converge
m0 = lmer(ffd  ~ WF+(1+WF|subjectid)+(1|trialid), data=roidat,REML=F)
summary(m0)

m1 = lmer(gd ~ WF+(1+WF|subjectid)+(1+WF|trialid), data=roidat,REML=F)
summary(m1)

m2 = lmer(tt ~ WF+(1+WF|subjectid)+(1+WF|trialid), data=roidat,REML=F)
summary(m2)


sjPlot::tab_model(m0,m1, m2, show.re.var=FALSE,show.ci = FALSE,show.obs = FALSE,
                  show.se = TRUE,emph.p = TRUE,show.icc = FALSE,show.ngroups = FALSE,
                  show.r2 = FALSE,auto.label = FALSE,pred.labels = c('intercept','WF'),show.stat = TRUE,
                  dv.labels=c('FFD','GD','TT'),string.se = 'SE',file='output_result/target_ET_pretarget_ffd.doc')



