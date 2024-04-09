#I am continuing my Assignment 3 on my local computer
#I was able to make an AWS account, launch a succesfull instance.
#I was able to open an online session of R, but I was not able to connect to 
#spark or Github. Due to these reasons I will finsih the assigment locally.
#I will add my sessioninfo from my Rstudio instance to the final report.


#Install packages and load libraries
install.packages("sparklyr")
install.packages("sparklyr.nested")
install.packages("tidyverse")
install.packages("rmarkdown")
install.packages("stargazer")
install.packages("corrr")
install.packages("dbplot")
install.packages("packrat")
library(tidyverse)
library(dplyr)
library(ggplot2)
library(sparklyr)
library(DBI)
library(tidyr)
library(forcats)
library(ggmosaic)
library(broom)
library(texreg)


#Creating Working Directory
getwd()
currentproj3 <- getwd()

#Creating folder named "Scripts" within my working directory
foldername5 <- "Scripts"
dir.create(file.path(currentproj3, foldername5))

#Creating folder named "Data" within my working directory
foldername1 <- "Data"
dir.create(file.path(currentproj3, foldername1))

#Creating folder named "Raw Data" within my "Data" Folder
subfolder1 <- "Raw Data"
dir.create(file.path(currentproj3, foldername1, subfolder1))

#Creating folder named "Clean Data" within my "Data" Folder
subfolder2 <- "Clean Data"
dir.create(file.path(currentproj3, foldername1, subfolder2))

#Creating folder named "Documentation" within my working directory
foldername3 <- "Documentation"
dir.create(file.path(currentproj3, foldername3))


#Load CSV File into a Data set in R
covid19_confirmed_globa_data <- read.csv("Data/Raw Data/time_series_covid19_confirmed_global.csv")

#Load CSV File into a Data set in R
UID_ISO_FIPS_LookUp_Table_data <- read.csv("Data/Raw Data/UID_ISO_FIPS_LookUp_Table.csv")


#Clean Data for Assignment 3 before uploading to Spark

#View the structure of new data set
str(covid19_confirmed_globa_data)

#View rows of new data set
head(covid19_confirmed_globa_data)

#View the structure of new data set
str(UID_ISO_FIPS_LookUp_Table_data)

#View rows of new data set
head(UID_ISO_FIPS_LookUp_Table_data)

#Creating a long version of the data set;Define the time variable as a date
long_data_covid19_confirmed_data <- covid19_confirmed_globa_data %>%
  pivot_longer(cols = starts_with("X"),
               names_to = "Date",
               values_to = "Confirmed_Cases") %>%
  mutate(Date = as.Date(gsub("X", "", Date), format = "%m.%d.%Y"))

#View the structure of new data set
str(long_data_covid19_confirmed_data)
long_data_covid19_confirmed_data

#New Variable that shows Days since start of Data Collection
library(dplyr)

# Assuming your dataframe is named 'df'
long_data_covid19_confirmed_data <- long_data_covid19_confirmed_data %>%
  mutate(Days_Since_Data_Collection_Started = as.numeric(Date - min(Date)))

#View the structure of new data set
str(long_data_covid19_confirmed_data)
long_data_covid19_confirmed_data$Days_Since_Data_Collection_Started


