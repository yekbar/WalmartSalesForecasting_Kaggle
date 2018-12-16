#### This file reads in the data from the MYSQL server I created

# to fix connection issue https://stackoverflow.com/questions/50188331/operationalerror-2059-authentication-plugin-caching-sha2-password-cannot-b
# ran this in mysql server ALTER USER 'yourusername'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
setwd("C:/Users/sneakekat/Desktop/Data Science Toolkit/Practicum Regis")


source('credentials.R')
library(RMySQL)
mydb = dbConnect(MySQL(), user=user, password=password, dbname='walmart', host='localhost')

dbListTables(mydb)
dbListFields(mydb, "test")
rs = dbSendQuery(mydb, "select * from train_import")
data = fetch(rs, n=-1)  # above query remains on MySQL server, need to fetch it
data