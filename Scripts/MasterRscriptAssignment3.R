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

sc <- sparklyr::spark_connect(master = "local")

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


#Making smaller Data frame that contains the information Germany, China, United Kingdom
#US, Brazil and Mexico

#The countries I want to look at in the new data frame
selected_countries <- c("Germany", "China", "Japan", "United Kingdom", "US", "Brazil", "Mexico")

Specific_Country_Confirmed_Cases <- Country_Confirmed_Cases %>%
  filter(Country_Region %in% selected_countries)

show(Specific_Country_Confirmed_Cases)

head(Specific_Country_Confirmed_Cases)



# Calculate the number of cases by country and day
cases_by_country_day <- Specific_Country_Confirmed_Cases %>%
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
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "22 week") +
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

# Remove duplicate rows
Specific_Country_Confirmed_Cases <- distinct(Specific_Country_Confirmed_Cases)

# Show the first few rows of the cleaned DataFrame
head(Specific_Country_Confirmed_Cases)

#Convert population to a numeric value
Specific_Country_Confirmed_Cases <- Specific_Country_Confirmed_Cases %>%
  mutate(Population = as.numeric(Population))

merged_data_spec_cntry <- inner_join(Specific_Country_Confirmed_Cases, cases_by_country_day, by = "Country_Region", "Date")
show(merged_data_spec_cntry)
str(merged_data_spec_cntry)
summary(merged_data_spec_cntry)

rate_of_cases <- merged_data_spec_cntry %>%
  mutate(rate_of_cases = Confirmed_Cases / Population)
show(rate_of_cases)



# Disconnect from Spark
spark_disconnect(sc)


