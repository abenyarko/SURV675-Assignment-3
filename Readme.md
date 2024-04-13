# **Analytical Notebook - Change in Covid Cases by Countries**


## **1. Introduction**

This report presents an analysis of COVID-19 data using Spark and R. We have performed various data manipulation and modeling task to gain insights into two data sets that give us information about COVID-19 and information about various countries. 


## **2. Setup**

In order to perform the various data manipulation and modeling task in Spark and R, we deployed various packages and libraries to complete each task.


## **3. Data Preparation**

We were tasked with downloading two data sets about COVID-19 from a GitHub Repository.

### *3.1.  Load Data*

We loaded the data into R using the read.csv function.


### *3.2.  Data Cleaning*

Preparing our data for analysis.
We created a long version of our COVID-19 data set.

###### **After this step, we continued our data manipulation in Spark**
###### **There is code you will need to adjust to run in Spark environment**

We merged our two data sets.
We took that merged data set and prepared the data for visualization.


## 4. **Exploratory Data Analysis**

### *4.1 Visualization*

#### *4.1.1 Change in the number of COVID-19 cases per country*

![Change in the number of COVID-19 cases per country](C:/Users/abeny/Documents/SURV675-Assignment-3/Documentation/Change in the number of cases per country.png)

This visualization depicts the evolving number of cases across the selected countries. Notably, the United States exhibited the most significant surge 
in cases during the specified time frame, while China experienced the most 
modest increase over the same period.


#### *4.1.2 Change in rate of COVID-19 cases by country*

![Change in rate of COVID-19 cases by country](C:/Users/abeny/Documents/SURV675-Assignment-3/Documentation/Change in rate of cases by country.png)

This graph illustrates the fluctuation in the rate of cases across different countries. 
Notably, the United States demonstrated the most substantial escalation in its rate of cases during this time frame.


## 5. **Modeling**

### 5.1 *Linear Regression*

Run a linear regression explaining the log number of cases using country, population, and day since the start of the pandemic

### 5.2 *Extract Model Statistics*

Extract tidy summary of coefficients, and extract model performance metrics

### 5.3 *Model Summary* 


| Variable                               | Estimate | Std. Error | t-value | p-value |
|----------------------------------------|----------|------------|---------|---------|
| (Intercept)                            | 12.43*** | 0.01       | 912.00  | < 0.001 |
| Country.RegionChina                    | -8.96*** | 0.01       | -655.00 | < 0.001 |
| Country.RegionGermany                  | -1.12*** | 0.02       | -51.70  | < 0.001 |
| Country.RegionJapan                    | -2.39*** | 0.02       | -142.00 | < 0.001 |
| Country.RegionMexico                   | -1.67*** | 0.02       | -91.10  | < 0.001 |
| Country.RegionUnited Kingdom           | -8.73*** | 0.01       | -612.00 | < 0.001 |
| Country.RegionUS                       | 0.66***  | 0.01       | 48.80   | < 0.001 |
| Population                             | 0.00     | 0.00       | 0.00    | 1.00    |
| Days_Since_Data_Collection_Started     | 0.01***  | 0.00       | 1900.00 | < 0.001 |

**Notes:** 
- ***p < 0.001; **p < 0.01; *p < 0.05*** denote significance levels.
- R-squared: 0.80
- Adjusted R-squared: 0.80
- Number of observations: 5,406,274

#### **Summary**
China, Germany, Japan, Mexico, the United Kingdom, and the United States, they all show big differences in the number of confirmed cases compared to other countries. 

China exhibits a considerably lower log confirmed cases compared to the reference, with a coefficient of approximately -8.96, indicating a logarithmic decrease. Conversely, the United States displays a positive coefficient of around 0.66, signifying a logarithmic increase in confirmed cases compared to the reference.

When we consider population size, it doesn't seem to make much of a difference in predicting the number of confirmed cases.

As time goes by and we collect more data, it seems like the number of confirmed cases tends to go up. 


## 6. **Conclusion / Session Info**

### 6.1.1 *Conclusion*

The United States exhibited the most significant surge 
in cases during the specified time frame, while China experienced the most 
modest increase over the same period. The United States demonstrated the most substantial escalation in its rate of cases during this time frame.

China exhibits a considerably lower log confirmed cases compared to the reference, with a coefficient of approximately -8.96, indicating a logarithmic decrease. Conversely, the United States displays a positive coefficient of around 0.66, signifying a logarithmic increase in confirmed cases compared to the reference.
Population size is not a good predictor of the number of confirmed cases of
COVID-19. As time goes by and we collect more data, it seems like the number of confirmed cases tends to go up. 
    
### 6.1.2 *Session Info from Local R

[1] "R version 4.3.1 (2023-06-16 ucrt)"                                   
 [2] "Platform: x86_64-w64-mingw32/x64 (64-bit)"                           
 [3] "Running under: Windows 11 x64 (build 22631)"                         
 [4] ""                                                                    
 [5] "Matrix products: default"                                            
 [6] ""                                                                    
 [7] ""                                                                    
 [8] "locale:"                                                             
 [9] "[1] LC_COLLATE=English_United States.utf8 "                          
[10] "[2] LC_CTYPE=English_United States.utf8   "                          
[11] "[3] LC_MONETARY=English_United States.utf8"                          
[12] "[4] LC_NUMERIC=C                          "                          
[13] "[5] LC_TIME=English_United States.utf8    "                          
[14] ""                                                                    
[15] "time zone: America/New_York"                                         
[16] "tzcode source: internal"                                             
[17] ""                                                                    
[18] "attached base packages:"                                             
[19] "[1] stats     graphics  grDevices utils     datasets  methods  "     
[20] "[7] base     "                                                       
[21] ""                                                                    
[22] "other attached packages:"                                            
[23] " [1] texreg_1.39.3   broom_1.0.5     ggmosaic_0.3.3  DBI_1.2.2      "
[24] " [5] sparklyr_1.8.5  lubridate_1.9.3 forcats_1.0.0   stringr_1.5.1  "
[25] " [9] dplyr_1.1.4     purrr_1.0.2     readr_2.1.5     tidyr_1.3.1    "
[26] "[13] tibble_3.2.1    ggplot2_3.5.0   tidyverse_2.0.0"                
[27] ""                                                                    
[28] "loaded via a namespace (and not attached):"                          
[29] " [1] plotly_4.10.4     utf8_1.2.4        generics_0.1.3   "          
[30] " [4] stringi_1.8.3     hms_1.1.3         digest_0.6.34    "          
[31] " [7] magrittr_2.0.3    evaluate_0.23     grid_4.3.1       "          
[32] "[10] timechange_0.3.0  fastmap_1.1.1     jsonlite_1.8.8   "          
[33] "[13] ggrepel_0.9.5     backports_1.4.1   httr_1.4.7       "          
[34] "[16] fansi_1.0.6       viridisLite_0.4.2 scales_1.3.0     "          
[35] "[19] lazyeval_0.2.2    cli_3.6.2         rlang_1.1.3      "          
[36] "[22] dbplyr_2.5.0      munsell_0.5.0     yaml_2.3.8       "          
[37] "[25] withr_3.0.0       tools_4.3.1       tzdb_0.4.0       "          
[38] "[28] colorspace_2.1-0  vctrs_0.6.5       R6_2.5.1         "          
[39] "[31] lifecycle_1.0.4   htmlwidgets_1.6.4 pkgconfig_2.0.3  "          
[40] "[34] pillar_1.9.0      gtable_0.3.4      rsconnect_1.2.1  "          
[41] "[37] data.table_1.15.0 glue_1.7.0        Rcpp_1.0.12      "          
[42] "[40] xfun_0.43         tidyselect_1.2.1  rstudioapi_0.15.0"          
[43] "[43] knitr_1.46        htmltools_0.5.7   rmarkdown_2.26   "          
[44] "[46] compiler_4.3.1    askpass_1.2.0     openssl_2.1.1    "

### 6.1.3 *Session Info from Instance on AWS*

R version 4.3.2 (2023-10-31)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 22.04.4 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so;  LAPACK version 3.10.0

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

time zone: Etc/UTC
tzcode source: system (glibc)

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] shiny_1.8.0     sparklyr_1.8.4  lubridate_1.9.3 forcats_1.0.0   stringr_1.5.1   dplyr_1.1.4     purrr_1.0.2    
 [8] readr_2.1.5     tidyr_1.3.1     tibble_3.2.1    ggplot2_3.5.0   tidyverse_2.0.0

loaded via a namespace (and not attached):
 [1] utf8_1.2.4        generics_0.1.3    stringi_1.8.3     hms_1.1.3         digest_0.6.34     magrittr_2.0.3   
 [7] evaluate_0.23     grid_4.3.2        timechange_0.3.0  fastmap_1.1.1     jsonlite_1.8.8    DBI_1.2.2        
[13] promises_1.2.1    httr_1.4.7        fansi_1.0.6       scales_1.3.0      cli_3.6.2         rlang_1.1.3      
[19] dbplyr_2.4.0      ellipsis_0.3.2    munsell_0.5.0     yaml_2.3.8        withr_3.0.0       tools_4.3.2      
[25] tzdb_0.4.0        colorspace_2.1-0  httpuv_1.6.14     vctrs_0.6.5       R6_2.5.1          mime_0.12        
[31] lifecycle_1.0.4   pkgconfig_2.0.3   pillar_1.9.0      later_1.3.2       gtable_0.3.4      glue_1.7.0       
[37] Rcpp_1.0.12       xfun_0.42         tidyselect_1.2.0  knitr_1.45        rstudioapi_0.15.0 xtable_1.8-4     
[43] htmltools_0.5.7   rmarkdown_2.25    compiler_4.3.2    askpass_1.2.0     openssl_2.1.1    
