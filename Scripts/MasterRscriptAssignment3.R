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
install.packages("knitr")
install.packages("xfun")
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
head(long_data_covid19_confirmed_data)

#New Variable that shows Days since start of Data Collection
library(dplyr)

long_data_covid19_confirmed_data <- long_data_covid19_confirmed_data %>%
  mutate(Days_Since_Data_Collection_Started = as.numeric(Date - min(Date)))

is.na(UID_ISO_FIPS_LookUp_Table_data)
is.na(long_data_covid19_confirmed_data)
complete.cases(UID_ISO_FIPS_LookUp_Table_data)
complete.cases(long_data_covid19_confirmed_data)


#View the structure of new data set
str(long_data_covid19_confirmed_data)
long_data_covid19_confirmed_data$Days_Since_Data_Collection_Started


#Save long data set as .CSV in the Clean Data folder
write.csv(long_data_covid19_confirmed_data, file = "Data/Clean Data/Long_data_Covid19.csv")

#Save edited version of UID_ISO_FIPS_LookUp_Table_data
write.csv(UID_ISO_FIPS_LookUp_Table_data, file = "Data/Clean Data/Country_Lookup_Table.csv" )


#Connecting to Spark

#Install Java
system("java -version")

sparklyr::spark_install()
sparklyr::spark_installed_versions()

sc <- sparklyr::spark_connect(master = "local", config = list(spark.driver.memory = "6g"))

#Load CSV into Spark
Confirmed_Cases <- spark_read_csv(sc, "Data/Clean Data/Long_data_Covid19.csv")

Country_Table <- spark_read_csv(sc, "Data/Clean Data/Country_Lookup_Table.csv")

head(Confirmed_Cases)
show(Confirmed_Cases)
head(Country_Table)
show(Country_Table)


#Combining both data frames within Spark

Country_Confirmed_Cases <- Confirmed_Cases %>%
  inner_join(Country_Table, by = "Country_Region")

head(Country_Confirmed_Cases)

str(Country_Confirmed_Cases)

show(Country_Confirmed_Cases)

Country_Confirmed_Cases <- Country_Confirmed_Cases[!is.na(Country_Confirmed_Cases$Population), ]


#Making smaller Data frame that contains the information Germany, China, United Kingdom
#US, Brazil and Mexico

#The countries I want to look at in the new data frame
selected_countries <- c("Germany", "China", "Japan", "United Kingdom", "US", "Brazil", "Mexico")

Specific_Country_Confirmed_Cases <- Country_Confirmed_Cases %>%
  filter(Country.Region %in% selected_countries) %>%
  mutate(
    Population = as.numeric(Population),
    rate_of_cases = Confirmed_Cases / Population)

show(Specific_Country_Confirmed_Cases)

head(Specific_Country_Confirmed_Cases)

Spe

Clean_Specific_Country_Confirmed_Cases <- Specific_Country_Confirmed_Cases %>%
  select(-iso2, -iso3, -FIPS, -Admin2, -Lat_y, -Long_, -code3, -UID, -Combined_Key, -Province_State_y, -`_c0_x`, -`_c0_y`, -Lat_x, -Lat_y)
Clean_Specific_Country_Confirmed_Cases <- Clean_Specific_Country_Confirmed_Cases[!is.na(Clean_Specific_Country_Confirmed_Cases$Population), ]


# Calculate the number of cases by country and day
cases_by_country_day <- Clean_Specific_Country_Confirmed_Cases %>%
  group_by(Country_Region, Date) %>%
  mutate(total_cases = max(Confirmed_Cases)) %>%
  ungroup() %>%
  distinct(Country_Region, Date, total_cases)

show(cases_by_country_day)
head(cases_by_country_day)


library(sparklyr)
library(dplyr)
library(ggplot2)


# Convert the Spark DataFrame to a local R DataFrame
local_cases_by_country_day <- collect(cases_by_country_day)

# Convert Country_Region and Date to factors
local_cases_by_country_day$Country_Region <- as.factor(local_cases_by_country_day$Country_Region)
local_cases_by_country_day$Date <- as.Date(local_cases_by_country_day$Date)

# Create a custom color palette for the countries
country_colors <- rainbow(length(unique(local_cases_by_country_day$Country_Region)))

#Graph Change in the number of cases per country
# Create the ggplot
ggplot(local_cases_by_country_day, aes(x = Date, y = total_cases, color = Country_Region)) +
  geom_line() +
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "24 week") +
  labs(title = "Change in the Number of Cases per Country",
       x = "Date",
       y = "Total Cases",
       color = "Country") +
  scale_color_manual(values = country_colors) +  # Assign custom colors
  theme_minimal() +
  scale_y_continuous(labels = scales::comma_format()) +
  theme(axis.text.x = element_text(size = 7))
 
library(dplyr)

#Calculate rate of cases by country and date

# Group by Country_Region and Date, and calculate the rate of cases
rate_by_country_day <- Clean_Specific_Country_Confirmed_Cases %>%
  group_by(Country.Region, Date) %>%
  mutate(rate_of_cases = sum(Confirmed_Cases) / max(Population, na.rm = TRUE)) %>%
  ungroup() %>%
  distinct(Country.Region, Date, rate_of_cases)
str(Clean_Specific_Country_Confirmed_Cases)

head(rate_by_country_day)

local_rate_by_country_day <- collect(rate_by_country_day)

local_rate_by_country_day$Country.Region <- as.factor(local_rate_by_country_day$Country.Region)
local_rate_by_country_day$Date <- as.Date(local_rate_by_country_day$Date)
head(local_rate_by_country_day)

library(sparklyr)

#Graph of change in rate of cases by country

ggplot(local_rate_by_country_day, aes(x = Date, y = rate_of_cases, color = Country.Region)) +
  geom_line() +
  labs(title = "Change in Rate of Cases by Country",
       x = "Date",
       y = "Rate of Cases",
       color = "Country") +
  theme_minimal() +
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "30 week") +
  scale_color_discrete(name = "Country") +
  coord_cartesian(ylim = c(0, max(local_rate_by_country_day$rate_of_cases, na.rm = TRUE) * 1.1))

#Run a linear regression explaining the log number of cases using country, population, and day since the start of the pandemic

# Log transform the Confirmed_Cases column
log_cases_by_country_day <- Clean_Specific_Country_Confirmed_Cases %>%
  group_by(Country.Region, Date) %>%
  mutate(log_Confirmed_Cases = log(Confirmed_Cases + 1)) %>%
  ungroup() %>%
  mutate(Confirmed_Cases = ifelse(is.na(Confirmed_Cases), 0, Confirmed_Cases),
         log_Confirmed_Cases = ifelse(log_Confirmed_Cases == 0, NA, log_Confirmed_Cases)) %>%
  distinct(Country.Region, log_Confirmed_Cases, Population, Days_Since_Data_Collection_Started)

# Remove rows with NA values in the log_Confirmed_Cases column
log_cases_by_country_day <- log_cases_by_country_day %>%
  filter(!is.na(log_Confirmed_Cases))

# Remove all rows with NA values in any column
log_cases_by_country_day <- na.omit(log_cases_by_country_day)

#Summary Data
summary_data <- log_cases_by_country_day %>%
  group_by(Country.Region) %>%
  summarize(
    Total_Log_Confirmed_Cases = sum(log_Confirmed_Cases, na.rm = TRUE),
    Total_Population = sum(Population, na.rm = TRUE),
    Days_Since_Data_Collection_Started = max(Days_Since_Data_Collection_Started, na.rm = TRUE)
  )



local_summary_data <- collect(summary_data)

local_summary_data$Country.Region <- as.factor(local_summary_data$Country.Region)

# Convert Total_Population to numeric
local_summary_data$Total_Population <- as.numeric(local_summary_data$Total_Population)

# Convert Days_Since_Data_Collection_Started to numeric
local_summary_data$Days_Since_Data_Collection_Started <- as.numeric(local_summary_data$Days_Since_Data_Collection_Started)


# Run the linear regression model
Regression_data <- spark_read_csv(sc, "Data/Clean Data/local_sum_data.csv")

head(Regression_data)

selected_Regression_data <- Regression_data %>%
  select(Country.Region, Total_Log_Confirmed_Cases, Total_Population, Days_Since_Data_Collection_Started)

# Perform linear regression
model_forlogcases <- ml_linear_regression(
  selected_Regression_data, 
  formula = Total_Log_Confirmed_Cases ~ Country_Region + Total_Population + Days_Since_Data_Collection_Started
)

print(model_forlogcases)

# Save the model
saveRDS(model_forlogcases, file = "linear_regression_model.rds")


# Disconnect from Spark
spark_disconnect(sc)

#Model function in R
#Model using lm() function in R
model_forlogcasesR <- lm(log_Confirmed_Cases ~ Country.Region + Population + Days_Since_Data_Collection_Started, data = log_cases_by_country_day)

print(model_forlogcasesR)

#Model Summary

# Extract tidy summary of coefficients
tidy_summary <- tidy(model_forlogcasesR)

# Extract model performance metrics
glance_summary <- glance(model_forlogcasesR)

# View the results
print(tidy_summary)
print(glance_summary)

# Create a table using screenreg
screenreg(model_forlogcasesR)
readmemodel <- screenreg(model_forlogcasesR)

print(readmemodel)

#Create .CSV for data frame for Spark Regression Table
write.csv(local_summary_data, file = "Data/Clean Data/local_sum_data.csv")

session_info <- capture.output(sessionInfo())

session_info

# Append session info to RMD file
cat("\n\n```{r}\n", session_info, "\n```", file = "Test2.rmd", append = TRUE)

#Troubleshooting for .RMD file
Country_Table <- read.csv("Data/Clean Data/Country_Lookup_Table.csv")
Confirmed_Cases <- read.csv("Data/Clean Data/Long_data_Covid19.csv")

str(Confirmed_Cases)
str(Country_Table)

#Create Readme.md


