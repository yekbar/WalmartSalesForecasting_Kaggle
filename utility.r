library(forecast)

loadTest <- function() { # load testing data
  cls <- c('integer', 'integer', 'Date', 'logical')
  test <- read.csv("all/test.csv", colClasses = cls)
  
}


loadTrain <- function() { # load train data
  cls <- c('integer', 'integer', 'Date', 'double', 'logical')
  train <- read.csv("all/train.csv", colClasses = cls)
}


###  pull dates from store 1, dept 1, to get master lister of dates for forecasting function
getDates1set<- function(train){ 
  store1_1Dates <- train[train$Store == 1 & train$Dept == 1 , ]
  Dates <- store1_1Dates$Date
}


###   creates unique subset of store & dept, loop through all for preprocessing
getuniqueStoreDeptCombos <- function(train){
  uniqueStoreDeptC <- unique(train[c("Store", "Dept")])  
}


### This function gets unique combinations of store/dept and loops through them
### filling in missing dates with the fillinData function
### .rds files are written out PER STORE
### This file only needs to be run once, then predictions can be made.
cleanTrain <- function(numStores, uniqueStoreDeptC){
  
  for (j in 1:numStores) {  # for all 45 stores
    uniqueStoreDept <- uniqueStoreDeptC[uniqueStoreDeptC$Store == j,]
    
    # define clean_train outside of 2nd loop
    clean_traindf <- data.frame(Store=numeric(), Dept=numeric(), Date=as.Date(character()), Weekly_Sales=double(), IsHoliday=logical())
    
    # loop for all stores & 
    for(i in 1:nrow(uniqueStoreDept)){   
      #subset out individual dept            
      temp_sub<- train[train$Store == uniqueStoreDept[i,1]  & train$Dept == uniqueStoreDept[i,2],]
      # call fill in data function
      temp_df <- fillinData(uniqueStoreDept[i,1], uniqueStoreDept[i,2], Dates, temp_sub)
      clean_traindf <- rbind(clean_traindf, temp_df)
      saveRDS(clean_traindf, file= paste("fullTrainData/store", j, ".rds", sep="") )
    }
  }
}



#   creates vector of dates to predict (34 in total)
#   some stores do not need all 34 predictions
#   but later forecasting function predicts for all 34 and only # pulls what it needs for submission
getPredictionDates <- function(test){
  store1Test <- test[test$Store ==1 & test$Dept == 1, ]
  testDates <- store1Test$Date
}


### Fills in missing dates for store/dept combos that do not have all 143
fillinData <- function(store, dept, Dates, df_sub) {
  for(i in 1:length(Dates)){
    if(Dates[i] %in% df_sub$Date){
    } else{
      a<- data.frame(Store=store, Dept=dept, Date=Dates[i], Weekly_Sales=0, IsHoliday=FALSE)
      df_sub <- rbind(df_sub, a)
    }
  }
  df_sub <- df_sub %>% arrange(Date)
  #return(df_sub)
}


### create a time series & predict for each store dept
### This function is inside makePrediction()

TSforStoreDept <- function(store_temp_file_READ, dept, testDates){
  testDates <- getPredictionDates(test)  
  
  # testDates <- readRDS("testDates.rds")
  temp_subset <- store_temp_file_READ[store_temp_file_READ$Dept == dept, ]
  library(lubridate)
  mth <-  month(store_temp_file_READ[1,3])
  dy <-  day(store_temp_file_READ[1,3])
  yr <-  year(store_temp_file_READ[1,3])
  temp_sales <- temp_subset$Weekly_Sales
  ts_Sales <- ts(temp_sales, start=c(2010,2,05), frequency=52)
  
  #### ONE MODEL
  #fit <- stl(ts_Sales, s.window="periodic")#create model
  #forecastLM <- forecast(fit , h=39) # for 39 days
  

  ###ANOTHER MODEL
  forecastLM <- stlf(ts_Sales, h=39, s.window=13)  # 
  
  
  temp_forecast <- (as.numeric(forecastLM$mean))
  final <- data.frame(Store = rep(temp_subset[1,1], 39), 
                      Dept = rep(temp_subset[1,2], 39) , 
                      Weekly_Sales = round(temp_forecast, 2),
                      Date=as.Date(as.character(testDates)))
}





### Argument is variable with file names created by cleanTrain.R
### Reads in files created by cleanTrain.R
### Creates individual store/dept time series, predicts, adds to master DF
FinalPredictions <- function(file.names){  
  ### Initialize data frame for final predictions
  final_pred <- data.frame(Store=numeric(), 
                           Dept=numeric(), 
                           Weekly_Sales=numeric(), 
                           Date=as.Date(character()))
  for(i in file.names){  
    temp_file <- readRDS(paste("fullTrainData/", i, sep=""))
    for(j in unique(temp_file$Dept)){  # for each dept in that store.
      store_dept_pred <- TSforStoreDept(temp_file, j)  #forecast & write
      final_pred <- rbind(final_pred, store_dept_pred)
    }
  }
  return(final_pred)
}

### Argument is test, and final_pred created with FinalPredictions
### Testing is left joined with final_pred to keep dates for final submission only
###
mergeTrainTest <- function(test, final_pred) {
  test$Date <- as.Date(as.character(test$Date))
  submission_pre <- merge(test, final_pred, by=c("Store", "Dept", "Date"), all.x=TRUE)
}


### Writing submission
###
###
writesubmission <- function(mergedPredFile, filename) {
  mergedPredFile$Id <- paste(mergedPredFile$Store, mergedPredFile$Dept, mergedPredFile$Date, sep="_")
  mergedPredFile <- mergedPredFile[,c(6,5)]
  mergedPredFile$Weekly_Sales[is.na(mergedPredFile$Weekly_Sales)] <- 0 # some store/dept in submission file are not in my data - change NA to 0
  write.csv(mergedPredFile, filename, row.names=FALSE)
}

