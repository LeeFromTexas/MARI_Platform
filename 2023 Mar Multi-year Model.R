

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
library(plyr)

setwd ("C:/Users/leetr/OneDrive/Desktop/2023 Morgan Analytics/Modeling")

#download pre-processed multi-year file
#set the target to a new variable

                                                            # boot up S3
#install.packages("aws.s3")
library(aws.s3)

#S3 environment Variables here

bucketlist()

                                                            # load multi-year file

filename <- file.choose()
CombinedSample <- readRDS(filename)

                                                            # Set a new target variable, base case, subset columns, and filter out missing rows

head(CombinedSample)
distinct(CombinedSample, YEAR)

hist(CombinedSample$SUB1,xlab = "Values")
axis(1, at = seq(-9, 21, by = 1))
CombinedSample %>% count(SUB1, sort = TRUE)

table(CombinedSample$SUB1)

#map the drugs into their major categories
CombinedSample$SUB1_GROUPED <- -3

#CombinedSample$SUB1_MAJCAT <- mapvalues(CombinedSample$SUB1, 
#                               from=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,-9), 
#                               to=  c(1,2,3,4,5,5,2,6,7,3 ,3 ,3 ,2 ,2 ,2 ,2 ,8 ,9 ,10,10,-9) )

CombinedSample %>%
  mutate(SUB1_GROUPED = case_when(
    SUB1 == 1 ~ 1,
    SUB1 == 2 ~ 2,
    SUB1 == 3 ~ 3,
    SUB1 == 4 ~ 4,
    SUB1 == 5 ~ 5,
    SUB1 == 6 ~ 5,
    SUB1 == 7 ~ 2,
    SUB1 == 8 ~ 6,
    SUB1 == 9 ~ 7,
    SUB1 == 10 ~ 3,
    SUB1 == 11 ~ 3,
    SUB1 == 12 ~ 3,
    SUB1 == 13 ~ 2,
    SUB1 == 14 ~ 2,
    SUB1 == 15 ~ 2,
    SUB1 == 16 ~ 2,
    SUB1 == 17 ~ 8,
    SUB1 == 18 ~ 9,
    SUB1 == 19 ~ 10,
    SUB1 == 20 ~ 10,
    SUB1 == -9 ~ -9,
  ))


CombinedSample %>% count(SUB1_MAJCAT)

# filter for rows where the primary substance is 'none' aka hasn't been specified
none_sub1 <- CombinedSample %>% filter(CombinedSample$SUB1 == 1 & (CombinedSample$SUB2 == 1 | CombinedSample$SUB2 == -9)  )

# filter the rows with our target variable
randsamp_target <- CombinedSample %>% filter(CombinedSample$SUB1 == 3 ) 

# filter the rows that are not our target and not 'none'
randsamp_nontarget <- CombinedSample %>% filter(CombinedSample$SUB1 != 3 & CombinedSample$SUB1 != 1)

#check your categories
distinct(none_sub1, SUB1)
distinct(randsamp_target, SUB1)
distinct(randsamp_nontarget, SUB1)

# add a column to flag base case
none_sub1$base_case <- 1
randsamp_target$base_case <- 0
randsamp_nontarget$base_case <- 0

# add a label (for training the model) to indicate if this is the targeted substance or not
none_sub1$target_variable <- 0
randsamp_target$target_variable <- 1
randsamp_nontarget$target_variable <- 0

# Combine the three sets and shuffle the data
Shuffled_sub1eq_2 <- rbind(randsamp_target,randsamp_nontarget, none_sub1)
Shuffled_sub1eq_2 <- Shuffled_sub1eq_2[sample(1:nrow(Shuffled_sub1eq_2)), ]

# clear memory space
rm(CombinedSample)
rm(randsamp_target)
rm(randsamp_nontarget)
rm(none_sub1)

# filter a subset of the columns
Shuffled_sub1eq_2 <- Shuffled_sub1eq_2 %>% select(GENDER,RACE,ETHNIC,MARSTAT,EDUC,SUB1,EMPLOY,
                                                AGE,EMPLOY,LIVARAG,PRIMINC,STFIPS,REGION,
                                                DIVISION,PSOURCE,NOPRIOR,FRSTUSE1,
                                                base_case,target_variable)

# filter out missing data
Shuffled_sub1eq_2 <- Shuffled_sub1eq_2[!(  
    Shuffled_sub1eq_2$GENDER==-9 |
    Shuffled_sub1eq_2$RACE==-9 |
    Shuffled_sub1eq_2$ETHNIC==-9 |
    Shuffled_sub1eq_2$MARSTAT==-9 |
    Shuffled_sub1eq_2$EDUC==-9 |
    Shuffled_sub1eq_2$SUB1==-9 |
    Shuffled_sub1eq_2$AGE==-9 |
    Shuffled_sub1eq_2$EMPLOY==-9 |
    Shuffled_sub1eq_2$LIVARAG==-9 |   
    Shuffled_sub1eq_2$PRIMINC==-9 |   
    Shuffled_sub1eq_2$STFIPS==-9 |   
    Shuffled_sub1eq_2$REGION==-9 |   
    Shuffled_sub1eq_2$DIVISION==-9 | 
    Shuffled_sub1eq_2$PSOURCE==-9 |   
    Shuffled_sub1eq_2$NOPRIOR==-9 |   
    Shuffled_sub1eq_2$FRSTUSE1==-9  ),]

# all columns to factor:
sapply(Shuffled_sub1eq_2, class)
Shuffled_sub1eq_2 <- mutate_if(Shuffled_sub1eq_2, is.numeric, as.factor)

# age is numeric and needs to be ordinal
Shuffled_sub1eq_2$AGE = as.numeric(Shuffled_sub1eq_2$AGE)
sapply(Shuffled_sub1eq_2, class)
table(Shuffled_sub1eq_2$target_variable)

# save the shuffled processed training data
