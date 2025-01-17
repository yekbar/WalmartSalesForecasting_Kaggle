## Practicum II : Walmart Sales Forecasting Kaggle Competition

### Overview
- There were 2 main goals for this project:
    + Forecast weekly Walmart store sales for the Kaggle competition using a time series and functional programming in R.
    + Practice SQL skills by creating a MySQL server, loading in data, then retrieving it with SQL functions in R.
        + Due to complications with one file, DataGrip was used to load in the test data set.
        
### Motivation
- The motivations behind this project were to learn something new (time series, functional programming) and apply machine learning to business skills (SQL, time series forecasting).

### Data Source
- The competition site can be found here https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting. Data can be downloaded by accepting competition rules. There were 5 files overall, but I used mainly train, test, and submission after discovering that the features and additional store information did not improve the time series model.
- The raw data consisted of 421,571 rows and 5 columns for roughly 2/2010 - 11/2012 weekly sales data for about 3300 unique combinations of stores and departments. Each row represented one week of sales for one department in one store. 

<center>
<img src="data.PNG" width="50%"/>
</center>


### Cleaning
- The data was fairly clean, but some store/department combinations did not have all 143 weekly sales data points, so a function was created to make these weekly sales figures 0 to help with time series forecasting. This was the most significant data cleaning that had to be done. This was done with the cleanTrain() function in the utility.R file.

### EDA
- Since it is very time consuming and impractical to visually inspect all 3300 combinations of stores and departments for model fit, I chose Department 1 from all 45 Stores to do basic EDA. The results of this analysis can be found in HighMidLowTS.rmd. This analysis informed which time series model was best for all stores and departments.
- For a closer analysis, I looked at median weekly sales and picked a high (#13), mid (25), and low (36) weekly sales store. All 45 Stores had season trends no matter how small so I thought this was an efficient way of evaluating time series models.

<center>
<img src="weekly.PNG" width="50%" />
</center>

### Time Series Models & Fit
- Auto-arima, Seasonal Trend D=decomposition using Loess (stl), Error, Trend, Seasonality (stl), Naive forecasting, and Time Series Regression were attempted. Mean absolute error was used to determind the best model because this model fits to the median which seemd like a better metric than the average given that there were such large swings in weekly sales. 
- Assumptions were checked when necessary such as the stationary condition for auto-arima models. Distribution of residuals and autocorrelations were checked to determine model fit. Further analysis can be found in the HighMidLowTS.rmd report.

### Final Model
- The final model was built using the stlf() function from the forecast package in R. The forecasting window was 39 weeks, and s.window = 13 meaning this is the span in lags of the loess window for seasonal extraction. Playing around with t.window (the smoothness of the trend) did not immediately improve the high, medium, or low store sales models.  The Seasonal and Trend decomposition using Loess (stl) model uses loess for estimating non-linear relationships (Hyndman & Anthanasopoulos, 2016).
- STL is more robust in handling seasonality that is not monthly or quarterly. It is also more robust to outliers which is important for this data since there are large spikes in sales for seasonal events. 

### Future Investigations
- A drawback to STL is that it does not handle calendar changes automatically. There was a rougly 5 week period in March where sales spike about a week apart from each year that may be due to Easter. This holiday is tricky because the data varies by weeks from year to year. I would like to look at how to move the forecast by a few weeks to better align with this holiday as well as adjusting the Thanksgiving and Christmas spike in sales.
- I would also like to include a parameter in the function that specifies which model was used for forecasting since right now I am changing it in my utlity.r script.

### Explanation of Files

- **Bardash_Walmart_Presentation.ppt** - This is the final PPT presentation for my Practicum II
- **HighMidLowTS.rmd** - this report explores a high, medium, and low weekly store sales to determine the best time series model. 
- **data.PNG** - this is the data image in the read me file
- **predict.R** - this script when run utilitizes the function in utility.R and creates forecasts for all store/department combinations using the STL model described above. Follow the instructions on the top of predict.R to have it run correctly.
- **sql.r** - this script reads in the data that I loaded from the MySQL server. This file is not connected to the others as it was intended as practice for me and not a necessary step in forecasting or predicting. 
- **utlity.R** - this script contains all the functions used to clean, predict, and write out the final time series prediction for the competition.
- **weekly.PNG** - this image is the time series in the read me file




### Blog & Record of Progress
- A blog was kept of my weekly progress. Check it out at https://somanyvariables.wordpress.com/2018/11/04/sales-forecasting-project-week-2-update/

### Tools
- R: main coding language for data manipulation and cleaning
- ggplot2 package visualisations in R
- dplyr for data manipulation
- forecast for time series
- DataGrip - GUI for MySQL server
- MySQL & SQL - for loading data

### Acknowledgements

- Professor Busch for his guidance, patience, and expertise on MySQL and DataGrip.
- Val Bardash for his expertise in programming and help with my functions.
- Christy Pearson for our great discussions and general suggestions on my project. 
- Dr. Siri for providing great resources on time series. 

### References
Hyndman, R., and Anthanasopoulos, G. (2016). Otexts - Forecasting: Principles and practice. Retrieved from   https://otexts.org/fpp2/stl.html


Kabacoff, R. (2015). R in action, second edition: Data Analysis and Graphics with R. 	[Online edition, Safari books].

