# A Model to Predict Chances of Matching into Obstetrics and Gynecology Residency

*Objective:  *
*We sought to construct and validate a model that predict a medical student's chances of matching into an obstetrics and gynecology residency.*

ERAS is a centralized solution to the medical residency application and documents distribution process. The data source to be used for the project is the Electronic Residency Application Service data that was in discrete fields in the application.  No hand-searching of data was done. The data was exported from the ERAS Program Director Work Station under the Archives menu.The data is collected by the University of Colorado OBGYN residency that has both a categorical and a preliminary position.  Medical students who applied to the preliminary position were considered to be unmatched. The data set of years 2015, 2016, 2017, and 2018 applicants to the University of Colorado OBGYN residency. The data is contained in a data frame called 'all_data'. In advance, we might anticipate that USMLE Step 1 Score and US or Canadian Applicant will be key predictors.  Match Status is the dependent Variable and shows the medical students who applied to the OBGYN residency. 

Matching Data pull and preparation
==========

* [University of Colorado Obstetrics and Gynecology Residency Program] (http://www.ucdenver.edu/academics/colleges/medicalschool/departments/obgyn/Education/ResidentProgram/Pages/default.aspx)
* [Electronic Residency Application Service Program Director Workstation Login](https://apps.aamc.org/account/#/login?gotoUrl=http:%2F%2Fapps.aamc.org%2Feras-pdws-web%2F&allowInternal=false)
* [American Board of Obstetrics and Gynecology](http://www.abog.org/)

These are scripts to pull and prepare data. This is an active project and scripts will change, so please always update to the latest version.

## Caution
### Data security

These are student-level data that contain disclosive information. Only use in a secure environment and do not hold data on a removable device including laptops. 

### Always check the data

It is the end-users responsibility to understand the processes contained in these scripts, the assumptions that are used, and to check the data created conforms to their expectations. 

## Data structure

# Codebook
A codebook is a technical description of the data that was collected for a particular purpose. It describes how the data are arranged in the computer file or files, what the various numbers and letters mean, and any special instructions on how to use the data properly.

* Predictors under consideration:
1. `all_data$white_non_white` - Dichotomoized from ethnicity fields in ERAS data, 2 level categorical
2. `all_data$Age` - Age at the time of the match, numerical variable
3. `all_data$Year` - Year of participation in the match, 4 level categorical
4. `all_data$Gender` - Male or Female, 2 level categorical
5. `all_data$Couples_Match` - PArticipating in the couples match? 2 level categorical
6. `all_data$US_or_Canadian_Applicant` - Are they a US Senior or an IMG, 2 level categorical 
7. `all_data$Medical_Education_Interrupted` - Taking breaks, 2 level categorical
8. `all_data$Alpha_Omega_Alpha` - Membership in AOA, 3 level categorical
9. `all_data$Military_Service_Obligation`
10. `all_data$USMLE_Step_1_Score` - I did not use Step 2 score because most students will not have those numbers at the time they apply, numerical variable
11. `all_data$Count_of_Poster_Presentation` - numerical variable
12. `all_data$Count_of_Oral_Presentation` - numerical variable
13. `all_data$Count_of_Articles_Abstracts` - numerical variable
14. `all_data$Count_of_Peer_Reviewed_Book_Chapter` - numerical variable
15. `all_data$Count_of_Other_than_Published` - numerical variable
16. `all_data$Visa_Sponsorship_Needed` - numerical variable
17. `all_data$Medical_Degree` - Allopathic versus Osteopathic medical school education, 2 level categorical

This data was cleaned in a separate R script with the help of exploratory.io.  

Packrat is in use to control package versions and a packrat.lock file is posted to my github repository.  This will allow for easier reproducibility.  Packrat records the exact package versions you depend on, and ensures those exact versions are the ones that get installed wherever you go.  We can also control the environment by deploying the project inside a Docker container as needed.  The project was created in R version 3.6.1 and run inside RStudio 1.2.5019.  

A vector of quoted variable names is provided, `99_varnames.R`. 

### Events
Within each year of Matching data there is one event.  This is **Match_Status**.  In the final dataset, every applicant gets his/her/their own row. 

### Applicant Identification Number
AAMC ID number is a specific number that every applicant uses to apply to residency, fellowship, etc. (e.g. 12345678)

## Installation and use

### Install packages from the Additional_functions_nomogram.R
```r
rm(list = setdiff(ls(), lsf.str())). #cleans all environment except functions

install.packages("devtools")
devtools::install_github(repo = "exploratory-io/exploratory_func", dependencies = TRUE, upgrade = "never")
library(exploratory)

pkgs <- (c('caret', 'readxl', 'XML', 'reshape2', 'devtools', 'purrr', 'readr', 'ggplot2', 'dplyr', 'magick', 'janitor', 'lubridate', 'hms', 'tidyr', 'stringr', 'openxlsx', 'forcats', 'RcppRoll', 'tibble', 'bit64', 'munsell', 'scales', 'rgdal', 'tidyverse', "foreach", "PASWR", "rms", "pROC", "ROCR", "nnet", "packrat", "DynNom", "export", "caTools", "mlbench", "randomForest", "ipred", "xgboost", "Metrics", "RANN", "AppliedPredictiveModeling", "shiny", "earth", "fastAdaboost", "Boruta", "glmnet", "ggforce", "tidylog", "InformationValue", "pscl", "scoring", "DescTools", "gbm", "Hmisc", "arsenal", "pander", "moments", "leaps", "MatchIt", "car", "mice", "rpart", "beepr", "fansi", "utf8", "lmtest", "ResourceSelection", "rmarkdown", "rattle", "rmda", "funModeling", "tinytex", "caretEnsemble", "Rmisc", "corrplot", "progress", "perturb", "vctrs", "highr", "labeling", "DataExplorer", "rsconnect", "inspectdf", "ggpubr", "tableone", "knitr", "drake", "visNetwork", "rpart.plot", "RColorBrewer", "kableExtra", "kernlab", "naivebayes", "e1071", "data.table", "skimr", "naniar", "english", "mosaic", "broom", "mltools", "tidymodels", "tidyquant", "rsample", "yardstick", "parsnip", "dials", "cowplot", "lime", "flexdashboard", "shinyjs", "shinyWidgets", "plotly", "BH", "vip", "ezknitr", "here", "corrgram", "factoextra", "parallel", "doParallel", "odbc", "RSQLite", "discrim", "doMC",  "summarytools", "remotes", "fs", "PerformanceAnalytics", "correlationfunnel", "psych", "h2o", "ranger", 'R.methodsS3', 'plotROC', 'MLmetrics'))

install.packages(pkgs,dependencies = c("Depends", "Suggests", "Imports", "LinkingTo"), repos = "https://cloud.r-project.org")  #run this first time
lapply(pkgs, require, character.only = TRUE)
rm(pkgs)
```

### Get scripts into a new RStudio project:

`New Project - Version Control - Git -` https://github.com/mufflyt/nomogram/tree/dev_0.1 as `Repository URL`
(Our use your preferred way of cloning/downloading from GitHub.)

## Scripts: purpose and output/return

### `control.R`

**Description**: Runs all current relevant scripts below. 

**Use**: `source("00_source_all.R")` 

**Output**: see individual scripts below. 

These are all run with the single command above. They can be run separately if desired (obvi, :) )

### `Additional_functioins_nomogram.R`

**Description**: Bespoke functions used in scripts.

**Use**: `source("Additional_functioins_nomogram.R")` 

1. Library installation.  Sets relative folder paths.  
2. Creation of directory structure.
3. Sets labels for arsenal tableby function.  

**Output**: various functions.

### `All_ERAS_data_merged.R`

**Description**: Pulls data and merges column names

**Use**: `source("All_ERAS_data_merged.R")` 

1. GOBA pull from Dropbox to show who is in residency.
2. Binds each of the years of Matching Data together from 2019 to 2015 while creating column names.  
3. Removes applicants who applied multiple years by using only unique AAMC identification numbers.  
4. Filters applicant age to be greater than 26 years old to account for 6-year undergrad and med school programs.  

**Output**: 
* `Match_Status` (observation): One applicant per row
* `All_ERAS_data_merged_output_2_1_2020.csv` - fully labelled raw dataset containing all rows.


Please contact me with any questions or concerns: tyler (dot) muffly (at) dhha (dot) org.  
