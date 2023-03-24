

#saveRDS(tedsa_puf_2000_2019,"tedsA2000to2019.rds")
#saveRDS(tedsa_puf_1995_1999,"tedsA1995to1999.rds")
#saveRDS(tedsa_puf_1992_1994,"tedsA1992to1994.rds")

#TOT_MEM <- as.numeric(gsub("\r","",gsub("TotalVisibleMemorySize=","",system('wmic OS get TotalVisibleMemorySize /Value',intern=TRUE)[3])))/1024
#memory.limit(size=TOT_MEM)
#rm(list=ls(all=TRUE))
#gc()

library(survival)
library(Formula)
library(Hmisc)
library(utils)
library(aod)
library(ggplot2)
library(foreign)
library(MASS)
library(reshape2)
library(tidyverse)
library(caret)
library(nnet)
library(beepr)

#install.packages("aws.s3")
library(aws.s3)

#S3 Keys

bucketlist()


#setwd ("D:/ML_Code")

#teds2000to2019 <- readRDS("tedsA2000to2019.rds")
teds2000to2019 <- s3read_using(FUN = readRDS, bucket = "mikemorgananalyticsbucket", object = "tedsA2000to2019.rds")

#check the data range
distinct(teds2000to2019, ADMYR)

#Change ADMYR to YEAR for the 2000 to 2019 set
print(colnames(teds2000to2019)[1])
colnames(teds2000to2019)[1] <- "YEAR"
print(colnames(teds2000to2019)[1])

#take random sample from 2000 to 2019
#randsamp_2000to2019 <- sample_n( teds2000to2019, 100000)
#distinct(randsamp_2000to2019, YEAR)

#saveRDS(randsamp_2000to2019,"randsamp_2000to2019.rds")

#rm(list=ls(all=TRUE))

##############################################################Grab the other years

#teds1992to1994 <- readRDS("tedsA1992to1994.rds")
teds1992to1994 <- s3read_using(FUN = readRDS, bucket = "mikemorgananalyticsbucket", object = "tedsA1992to1994.rds")

#teds1995to1999 <- readRDS("tedsA1995to1999.rds")
teds1995to1999 <- s3read_using(FUN = readRDS, bucket = "mikemorgananalyticsbucket", object = "tedsA1995to1999.rds")

#randsamp_92to94 <- sample_n( teds1992to1994, 20000)
#distinct(randsamp_92to94, YEAR)

#randsamp_95to99 <- sample_n( teds1995to1999, 20000)
#distinct(randsamp_95to99, YEAR)

#saveRDS(randsamp_92to94,"randsamp_1992to1994.rds")
#saveRDS(randsamp_95to99,"randsamp_1992to1994.rds")

##############################################################Combine the data
#rm(list=ls(all=TRUE))
#gc()

#A <- readRDS("randsamp_1992to1994.rds")
#B <- readRDS("randsamp_1995to1999.rds")
#C <- readRDS("randsamp_2000to2019.rds")

#Make the column names match
teds1992to1994 <- subset(teds1992to1994, select = -c(NUMSUBS,PMSA,CBSA,SERVSETA) )
teds1995to1999 <- subset(teds1995to1999, select = -c(NUMSUBS,PMSA,CBSA,SERVSETA) )
teds2000to2019 <- subset(teds2000to2019, select = -c(ARRESTS,FREQ_ATND_SELF_HELP,CBSA2010,SERVICES) )

saveRDS(teds1992to1994,"teds1992to1994_my.rds")
saveRDS(teds1995to1999,"teds1995to1999_my.rds")
saveRDS(teds2000to2019,"teds2000to2019_my.rds")

#merge all the years into one file
CombinedSample <- rbind(teds1992to1994,teds1995to1999,teds2000to2019)

saveRDS(CombinedSample,"teds1992to2019.rds")

put_object(file = "teds1992to2019.rds", object = "teds1992to2019.rds", bucket = "mikemorgananalyticsbucket",multipart = TRUE)

put_object(file = "Aug 2022 Multi-year Model.R", object = "Aug 2022 Multi-year Model.R", bucket = "mikemorgananalyticsbucket",multipart = TRUE)


#################################################################Build the model, predict COKE use SUB1 = 3
#################################################################against the baseline SUB1 = NO DRUGS or SUB1 = 1
rm(list=ls(all=TRUE))
gc()

CombinedSample <- readRDS("teds1992to2019.rds")
distinct(CombinedSample, YEAR)

#Grab the base case "none'
none_sub1 <- CombinedSample %>% filter(CombinedSample$SUB1 == 1 & (CombinedSample$SUB2 == 1 | CombinedSample$SUB2 == -9)  )
#Grab a sample target variable, in this case, where SUB1 = 3 or coke. 
#Predict if they use coke and compare it to the baseline of having no drug use
randsamp_target <- CombinedSample %>% filter(CombinedSample$SUB1 == 3 & CombinedSample$SUB1 != 1) 
randsamp_nontarget <- CombinedSample %>% filter(CombinedSample$SUB1 != 3 & CombinedSample$SUB1 != 1)
distinct(none_sub1, SUB1)
distinct(randsamp_target, SUB1)
distinct(randsamp_nontarget, SUB1)

#add an identifying column about which subset they came from
randsamp_target$base_case <- 0
randsamp_nontarget$base_case <- 0
none_sub1$base_case <- 1

#Combine the three sets and shuffle the data
CombinedSampleV2 <- rbind(randsamp_target,randsamp_nontarget, none_sub1)
CombinedSampleV2 <- CombinedSampleV2[sample(1:nrow(CombinedSampleV2)), ]

#select only 1 substance to predict and then create a yes/no flag so that I can compare the base case to it
#I'm arbitraily picking the second most common substance COKE/CRACK SUB1 = 3
CombinedSampleV2 <-  CombinedSampleV2 %>% mutate(target_variable = ifelse(CombinedSampleV2$SUB1 == 3,1,0) )

#clear space
rm(CombinedSample)
rm(randsamp_target)
rm(randsamp_nontarget)
rm(none_sub1)

#filter a subset of the total columns
CombinedSampleV2 <- CombinedSampleV2 %>% select(GENDER,RACE,ETHNIC,MARSTAT,EDUC,SUB1,EMPLOY,
                                                AGE,EMPLOY,LIVARAG,PRIMINC,STFIPS,REGION,
                                                DIVISION,PSOURCE,NOPRIOR,FRSTUSE1,
                                                base_case,target_variable)

#drop rows with ANY missing data
CombinedSampleV2 <- CombinedSampleV2[!(  
  CombinedSampleV2$GENDER==-9 |
    CombinedSampleV2$RACE==-9 |
    CombinedSampleV2$ETHNIC==-9 |
    CombinedSampleV2$MARSTAT==-9 |
    CombinedSampleV2$EDUC==-9 |
    CombinedSampleV2$SUB1==-9 |
    CombinedSampleV2$AGE==-9 |
    CombinedSampleV2$EMPLOY==-9 |
    CombinedSampleV2$LIVARAG==-9 |   
    CombinedSampleV2$PRIMINC==-9 |   
    CombinedSampleV2$STFIPS==-9 |   
    CombinedSampleV2$REGION==-9 |   
    CombinedSampleV2$DIVISION==-9 | 
    CombinedSampleV2$PSOURCE==-9 |   
    CombinedSampleV2$NOPRIOR==-9 |   
    CombinedSampleV2$FRSTUSE1==-9    ),]

# all columns to factor:
sapply(CombinedSampleV2, class)
CombinedSampleV2 <- mutate_if(CombinedSampleV2, is.numeric, as.factor)
#age is numeric and needs to be ordinal
CombinedSampleV2$AGE = as.numeric(CombinedSampleV2$AGE)
sapply(CombinedSampleV2, class)
table(CombinedSampleV2$target_variable)

######################################################################Train the Predictive Model
set.seed(9560)
inTraining <- createDataPartition(CombinedSampleV2$SUB1, p = .6, list = FALSE)
training <- CombinedSampleV2[ inTraining,]
testing  <- CombinedSampleV2[-inTraining,]

# AGE,EMPLOY,LIVARAG,PRIMINC,STFIPS,REGION,
# DIVISION,SERVSETA,PSOURCE,NOPRIOR,FRSTUSE1,

RF <- train(target_variable ~ 
              GENDER+RACE+ETHNIC+MARSTAT+EDUC+
              AGE+EMPLOY+LIVARAG+PRIMINC+STFIPS+REGION+
              DIVISION+PSOURCE+NOPRIOR+FRSTUSE1,
            data = training,
            method = "rf",
            metric = "Accuracy"
)

print("training complete")
RF
varImp(RF)
varImp(RF,scale = FALSE)

################################################################################## Compare the output of base class to other

#https://www.edureka.co/blog/random-forest-classifier/
testing$Prediction <- predict(RF, newdata = testing)

testing_base <- testing %>% filter(testing$base_case==1)
testing_nonbase <- testing %>% filter(testing$base_case==0)
table(testing_base$Prediction)
table(testing_nonbase$Prediction)

write.csv(testing_nonbase,"testing_nonbase_third_iteration.csv", row.names = TRUE)

#save the model
saveRDS(RF, file = "D:/Documents/Aug_2022_third_iteration.rda")

