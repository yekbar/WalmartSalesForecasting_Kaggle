rm(list=ls())
setwd("C:/Users/sneakekat/Desktop/Data Science Toolkit/Practicum Regis")
library(dplyr)
library(tictoc)


##### FIRST: 1. Change the working directory above
#####        2. Make sure train & test files are in a folder called "all" in this directory
#####        3. Create a folder named fullTrainData - this is where the store/combinations will be cleaned 
####            and written out as 45 .rds files. 
####         4. 
                  

######## LOAD DATA & UTILITY FILES
source('utility.R')

train <- loadTrain()
test <- loadTest()

Dates <- getDates1set(train) #using this instead of below line if works, keep
#Dates <- readRDS("completeDates.rds")

######## CLEAN & PRE-PROCESS
############### This section only needs to be RUN ONCE!!!
### This section gets unique department/store combinations from the training set
### then takes each combination and inserts missing weekly sales dates and assigns it to $0
### so it is possible to use the forecasting function
uniqueStoreDeptC <- getuniqueStoreDeptCombos(train)
numStores <- length(unique(uniqueStoreDeptC$Store))
cleanTrain(numStores,uniqueStoreDeptC )
###############


######## CREATE PREDICTIONS & WRITE OUT PREDICTIONS

path = "fullTrainData/"
file.names <- dir(path, pattern =".rds")

final_pred <- FinalPredictions(file.names)

submission_pre <- mergeTrainTest(test, final_pred)

writesubmission(submission_pre, "prediction_stlf_ets_13.csv") # writes out final submission as .csv, specify file name



