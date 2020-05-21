# A Model to Predict Chances of Matching into Obstetrics and Gynecology Residency

*Objective:  *
*We sought to construct and validate a model that predict a medical student's chances of matching into an obstetrics and gynecology residency.*

ERAS is a centralized solution to the medical residency application and documents distribution process. The data source to be used for the project is the Electronic Residency Application Service data that was in discrete fields in the application.  No hand-searching of data was done. The data was exported from the ERAS Program Director Work Station under the Archives menu.The data is collected by the University of Colorado OBGYN residency that has both a categorical and a preliminary position.  Medical students who applied to the preliminary position were considered to be unmatched. The data set of years 2016, 2017, 2018, 2019, and 2020 applicants to the University of Colorado OBGYN residency. The data is contained in a data frame called 'all_data'. In advance, we might anticipate that USMLE Step 1 Score and US or Canadian Applicant will be key predictors.  Match Status is the dependent Variable and shows the medical students who applied to the OBGYN residency. 

Short Proposal
==========
* [Application to Colorado Multiple Institutional Review Board for Project]
(https://github.com/mufflyt/nomogram/blob/dev_0.1/COMIRB%20protocol%20for%20matching%20nomogram%20study.doc)

Matching Data pull and preparation
==========
* [University of Colorado Obstetrics and Gynecology Residency Program](http://www.ucdenver.edu/academics/colleges/medicalschool/departments/obgyn/Education/ResidentProgram/Pages/default.aspx)
* [Electronic Residency Application Service Program Director Workstation Login](https://apps.aamc.org/account/#/login?gotoUrl=http:%2F%2Fapps.aamc.org%2Feras-pdws-web%2F&allowInternal=false)
* [American Board of Obstetrics and Gynecology](http://www.abog.org/)
* [Blue Ridge Funding of OBGYN Clinical Departments](http://www.brimr.org/NIH_Awards/2019/NIH_Awards_2019.htm)

These are scripts to pull and prepare data. This is an active project and scripts will change, so please always update to the latest version.

## Caution
### Data security

These are student-level data that contain disclosive information. Only use in a secure environment and do not hold data on a removable device including laptops. 

### Always check the data

It is the end-users responsibility to understand the processes contained in these scripts, the assumptions that are used, and to check the data created conforms to their expectations. 

## Data structure

# Codebook
A codebook is a technical description of the data that was collected for a particular purpose. It describes how the data are arranged in the computer file or files, what the various numbers and letters mean, and any special instructions on how to use the data properly.

* Predictors under consideration: 2020, 2019, 2018, 2017
1. `all_data$white_non_white` - Dichotomoized from ethnicity fields in ERAS data, 2 level categorical: white vs. non-white.  
2. `all_data$Age` - Age at the time of the match, numerical variable based on Date of Birth POSIXct
3. `all_data$Year` - Year of participation in the match, 4 level categorical
4. `all_data$Gender` - Male or Female, 2 level categorical
5. `all_data$Couples_Match` - Participating in the couples match? 2 level categorical
6. `all_data$US_or_Canadian_Applicant` - Are they a US Senior or an IMG, 2 level categorical 
7. `all_data$Medical_Education_Interrupted` - Taking breaks, 2 level categorical
8. `all_data$Alpha_Omega_Alpha` - Membership in AOA, 2 level categorical
9. `all_data$Military_Service_Obligation`
10. `all_data$USMLE_Step_1_Score` - I did not use Step 2 score because most students will not have those numbers at the time they apply, numerical variable.  Step 1 is going to pass/fail.  
11. `all_data$Count_of_Poster_Presentation` - numerical variable
12. `all_data$Count_of_Oral_Presentation` - numerical variable
13. `all_data$Count_of_Articles_Abstracts` - numerical variable
14. `all_data$Count_of_Peer_Reviewed_Book_Chapter` - numerical variable
15. `all_data$Count_of_Other_than_Published` - numerical variable
16. `all_data$Visa_Sponsorship_Needed` - numerical variable
17. `all_data$Medical_Degree` - Allopathic versus Osteopathic medical school education, 2 level categorical

This data was cleaned in a separate R script with the help of exploratory.io.  

Additional data not for analysis:
18.  `AAMC_ID`
19.  `Applicant Name`

2017 and earlier does not have SOAP data:
20.  `SOAP Applicant` 
21.  `SOAP Reapply Applicant`
22.  `SOAP Match Status`
23.  `SOAP Reapply Track Applied`

21.  `Track Applied by Applicant` - This variable is complete for all years.  
22.  `Gold Humanism Honor Society`
23.  `Medical School of Graduation`
24.  `Medical School Type`
25.  `Misdemeanor Conviction`
26.  `Felony Conviction` - Zero variance with no one reporting a history of felonies.  
27.  `Malpractice_Cases_Pending` - Near zero variance with only one person with a pending malpractice case.  

To create a clean data set for analysis then remove:
* `Date_of_Birth_year`
* `Self_Identify`
* `Medical_School_of_Graduation`
* `Felony_Conviction`
* `Malpractice_Cases_Pending`
* `Year_numeric`
* `SOAP_Match_Status`
* `Tracks_Considered_by_Program_1`
* `Year`
* `USMLE_Step_1_Score` - We will assume that all students passed at a score of >= 194.  
* `Applicant Name`

We can also control the environment by deploying the project inside a Docker container as needed.  The project was created in R version 3.6.1 and run inside RStudio 1.2.5019.  

### Events
Within each year of Matching data there is one event.  This is **Match_Status**.  In the final dataset, every applicant gets his/her/their own row. 

### Applicant Identification Number
AAMC ID number is a specific number that every applicant uses to apply to residency, fellowship, etc. (e.g. 12345678)

## Installation and use

### Install packages from the Additional_functions_nomogram.R
### Also please see docker image I created for this project below.  
```r
########################################################################
# Logistic Regression Model to Predict Matching for medical students applying to OBGYN: Source All
# Denver Health and Hospital Authority, 2020

#Created using R version 3.6.2
#brew install cask
#brew install wget
#brew cask install basictex
#brew install pandoc
#brew install pkg-config

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

### `000-control.R`

**Description**: Runs all current relevant scripts below. 

**Use**: `source("00_source_all.R")` 

**Output**: see individual scripts below. 

These are all run with the single command above. They can be run separately if desired (obvi, :) )

### `Additional_functions_nomogram.R`

**Description**: Bespoke functions used in scripts.

**Use**: `source("Additional_functions_nomogram.R")` 

1. Library installation.  Sets relative folder paths.  
2. Creation of directory structure.
3. Sets labels for arsenal tableby function.  

**Output**: various functions.


### `All_ERAS_data_merged.R`

**Description**: Pulls data and merges column names

**Use**: `source("All_ERAS_data_merged.R")` 

1. Determine 'Match_Status'
* Applicants can apply to prelim or categorical positions in the ERAS match.  This is defined as the `Tracks_Applied_by_Applicant` variable.  Christine was really helpful in understanding how the ERAS data is used in practice. 
* From ERAS data anyone who applied for a preliminary position `('Ob-Gyn/Preliminary|1076220P0 (Preliminary)')` did not match OR **applied to the prelim as a "backup plan".  Prelim applicants not matching is clearly an assumption and will get checked below.**

Determining `Match_status` - Anyone who applied prelim did not match into a categorical position is a fair assumption.  But in case they applied to both with a prelim as a backup then we need to do something different.  

In GOBA, what year did each person match? - Could decrease the number of people in applicant side trying to match to.  Look at year graduated from medical school in the NPCd and that will tell you what year they started residency.  Alos all the years should be consecutive.  

In GOBA, which residency did each person match? - I did a join on state, city to residency programs and had about a third with exact name matches.  For duplicate matches like matching to ten residency programs in New York, NY then we can google search for their name and each residency program name.  This info needs to be put in by hand and then fed back into the Match_Status variable.  

We do not have as much overlap between applicants and obgyn residents because not everyone applied to CU OBGYN residency.  

* Pull to show who is in an OBGYN residency. `this one works.R` and clean data to look for residents based on NPPES taxonomy code and consecutive order in list.  Make sure pull is up to date by running `this one works.R` with the `startID` at the last known number and `startID` plus 1,200.  

* We need to do a match between names of the applicants and `list_of_people_who_all_matched_into_OBGYN`. See code snippet below about using `humaniformat` to standardize the format of names.    

* `All_Years` has 3,904 residents from `this one works.R`

** Do an inner_join by first_name then by middle_name then last_name between `this one works.R` list and ERAS applicant `All_Years` data: 794/3,904

** Do an inner_join by first_name then last_name: 1,599/3,904

** Do an inner_join by first_name, last_name, suffix: 1,571/3,904

UCLA - 3 prelims
Hawaii - 1 prelim
NY Cornell - 1 prelim
LIJ - 1 prelim
Tufts - 1 prelim
Colorado - 1 prelim

** Do an inner_join by last_name then by first_name then by middle_name
**When downloading files from Dropbox make sure that the suffix is changed from 
* Cross-reference with Match Lists from various medical schools.  Lists are stored on Dropbox at `~/Dropbox/`.

2. Binds each of the years of Matching Data together from 2020 to 2017 while standardizing column names with parsed case.  Standardize data types.  Age was calculated from date of birth to the year they applied.  Year columns was added for every year of applicants.  
* Imputed minimal number of 'Self-Identity', some of the number of poster/peer-reviewed articles.  

3. Removes applicants who applied multiple years by using only unique AAMC identification numbers.  
4. Filters applicant age to be greater than 26 years old to account for 6-year undergrad and med school programs.  

Full Name Cleaning in order to match by name it gets split into the parts of `first_name`, `middle_name`, `last_name`, and `suffix` using the awesome package `humaniformat`:
```r
  install.packages("humaniformat")
  library(humaniformat)
  library(dplyr)
  library(tidyr)
  library(stringr)
  distinct(userid, .keep_all = TRUE) %>%
  mutate(suffix = humaniformat::suffix(name)) %>%
  separate(name, into = c("name", "suffix"), sep = "\\s*\\,\\s*", remove = TRUE, convert = TRUE) %>%
  mutate(period_format = humaniformat::format_period(name)) %>%
  mutate(first_name = humaniformat::first_name(period_format)) %>%
  distinct(period_format, .keep_all = TRUE) %>%
  mutate(middle_name = humaniformat::middle_name(period_format)) %>%
  mutate(last_name = humaniformat::last_name(period_format)) %>%
  mutate(middle_name = impute_na(middle_name, type = "value", val = "") %>%
  mutate_at(vars(period_format, first_name, middle_name, last_name), funs(str_to_title) %>%
  mutate(middle_name = str_remove(middle_name, regex("\\.", ignore_case = TRUE)) %>%
  mutate(suffix = recode(suffix, M.D. = "MD", MD = "MD", D.O. = "DO", DO = "DO", M.D = "MD", Md = "MD", `M. D.` = "MD")) %>%
  mutate(suffix = str_remove(suffix, regex("\\.", ignore_case = TRUE)) %>%
  mutate(middlename = impute_na(middlename, type = "value", val = ""), middlename = na_if(middlename, "Na"), middlename = impute_na(middlename, type = "value", val = "")))
```

**Output**: 
* `Match_Status` (observation): One applicant per row
* `All_ERAS_data_merged_output_2_1_2020.csv` - fully labelled raw dataset containing all rows.


### `google_search.R`
**Description**: Automatic search of Google for the residency program location of OBGYN residents.  Takes data from exploratory `residents` dataframe and runs it through Google to see if there is a hit for the program because they have duplicate rows.  The data is created as a URL that is fed to google based on this tutorial: https://medium.com/@curiositybits/automating-the-google-search-for-the-web-presence-of-8000-organizations-54775e9f6097.  The URL is created with "https://www.google.com/search?q="name[i], suffix[i], city[i], state[i], ProgramName[i]".  It may be giving Google too much information but seems to work well.  Once the data is output then we will need to go through each person by hand to see what is the most promising link.  I used **https://selectorgadget.com/** for identifying the CSS codes to scrape.  Of note, selector gadget is a Chrome plugin.  For the cleaning the URL `exploratory::url_domain` we are going to need exploratory functions:

```r
# Installing
if (packageVersion("devtools") < 1.6) {
  install.packages("devtools")
}
devtools::install_github("paulhendricks/anonymizer")
library(anonymizer)

devtools::install_github("tidyverse/glue")
library(glue)

install.packages("backports")
library(backports)

devtools::install_github("exploratory-io/exploratory_func")
library(exploratory)
```

Build a Google search tool:
```r
timer_value <- runif(dim(d)[1], min=0, max=10)
# new code
for (i in dim(d)[1]:1) {
  
  print(paste0("finding the url for:",d$name[i], d$suffix[i], d$city[i], d$state[i], d$ProgramName[i]))
  Sys.sleep(timer_value)
  
  url1 = utils::URLencode(paste("https://www.google.com/search?q=",d$name[i], d$suffix[i], d$city[i], d$state[i], d$ProgramName[i]))  

  page1 <- xml2::read_html(url1) #reads the html of the page from `url1`

  nodes <- rvest::html_nodes(page1, "a") #reads the nodes with the "a"
  links <- rvest::html_attr(nodes,"href") #reads the hyperlink
 
  link <- links[startsWith(links, "/url?q=")]  #cleans the links

  link <- sub("^/url\\?q\\=(.*?)\\&sa.*$","\\1", link)

  result1 <- as.character(link)
  d$Website[i] <- result1[1]  #writes back to original dataframe called d
}
 gc() #take out the garbage
```

There are duplicate rows because there are multiple programs in Philadelphia, PA or Chicago, IL.  The code could be expanded to search Twitter and Facebook as well.  At the bottom of `google_search.R` there is some code from the original example that can be used this way. 

Create clickable url links in excel by highlighting the column called `website` and go to style box and select hyperlink.  

Our goal is to create a Venn diagram of who applied to CU OBGYN residency program and who is an OBGYN resident.  
```r

set.seed(12)
set1 <-  applicants 
set2 <- residents
colors <- c("#6b7fff", "#c3db0f")

require(gridExtra)
grid.newpage()
venn.plot <- draw.pairwise.venn(length(set1), length(set2), length(intersect(set1,set2)), 
				c("Applicants", "Residents"), 
				fill =  c("red", "blue"), 
				cat.pos = c(0, 0), 
				cat.dist = rep(0.025, 2),
				scaled = FALSE, );


grid.arrange(gTree(children=venn.plot), top="Applicants and Residents")
```

**Use**: `source("google_search.R")` 

**Output**: 
* The output will be an RDS file called `google_search_results.R` with a "underscore 2" suffix on the end to denote the output of results.  

* Geocoding of location.  
```r
# Google geocoding of FPMRS physician locations ----
#Google map API, https://console.cloud.google.com/google/maps-apis/overview?pli=1

#Allows us to map the residency programs to street address, city, state
library(ggmap)
gc(verbose = FALSE)
ggmap::register_google(key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
ggmap::ggmap_show_api_key()
ggmap::has_google_key()
colnames(full_list)

View(full_list$place_city_state)
dim(full_list)
sum(is.na(full_list$place_city_state))

locations_df <- ggmap::mutate_geocode(data = full_list, location = place_city_state, output="more", source="google")
locations <- tibble::as_tibble(locations_df) %>%
   tidyr::separate(place_city_state, into = c("city", "state"), sep = "\\s*\\,\\s*", convert = TRUE) %>%
   dplyr::mutate(state = statecode(state, output_type = "name"))
 colnames(locations)
 write_rds(locations, "geocoded_file_2.rds")

head(locations)
```

###`Model`
Supervised learning is where you are the teacher in the model is the student. We are training our model to recognize patterns in the data using flashcards. The flashcards for the attributes of applicants to OB/GYN residency in on the back of the flash card is the matching status. Did the applicant match?  Yes or no.￼￼￼￼ Imagine you hand the model a stack of flashcards and we train the model to recognize this pattern future in the wild/with new data that it has never seen before.  

###Docker for reproducibilty
Docker allows for stable versions of packages and a similar environment for all authors to work in.  The files to use this docker image are available in `rstudio_v3.tar`.  Thanks to Maksim Boyko.  

In terminal: 

Make sure docker desktop is running.
```r cd ~/Dropbox/Nomogram/docker/rstudio_v3```
At this point you should be in the same directory as the docker-compose.yaml file.  
```r docker-compose up -d```
The result should eventually be: `Creating rstudio_v3_rstudio_1 ... done`
Open browser at ```r http://localhost:8787``` with user 'rstudio' and password 'password'

The problem is that the docker image is not linked to the Dropbox directory where I keep the files so I have to download it from github every time.  Rstudio -> File -> New Project -> Check out version -> "https://github.com/mufflyt/nomogram.git".  Please note most of the work I am doing currently is on the `dev_1` branch.  Click on `Git` and then select the branch: `dev_01`.

[![Project flow Data first pass matching](https://github.com/mufflyt/nomogram/blob/dev_0.1/first_pass_who_matched.jpeg?raw=true)](https://github.com/mufflyt/nomogram/blob/dev_0.1/first_pass_who_matched.jpeg?raw=true)

[![Project flow Matching Prediction](https://github.com/mufflyt/nomogram/blob/dev_0.1/project%20data%20flow%20Muffly%20et%20al.jpeg?raw=true)](https://github.com/mufflyt/nomogram/blob/dev_0.1/project%20data%20flow%20Muffly%20et%20al.jpeg?raw=true)

* We can identify residents by their taxonomy code in the NPI database: `Student Health Care (390200000X`.  
* [AAMC Statement on Residents and Medical Students Needing NPI Numbers](https://www.aamc.org/professional-development/affinity-groups/gir/viewpoint-provider-identifiers)


# Man vs. Machine: Comparing Clerkship Directors to the Model
* [REDCAP survey to clerkship directors](https://is.gd/predictingobgynmatching)
UC Denver REDCAP was used due to ease of use.  

Identifying clerkship directors was challenging.  There is not an up to date list through APGO/CREOG.  Therefore Dr. Nicki Nguyen e-mailed residency clerkship coordinators asking who the clerkship director is.  We also asked through the residency coordinator listserve with Christine Raffaelli.  
* [Curated list of clerkship directors on a Google Drive Spreadsheet](https://docs.google.com/spreadsheets/d/1RRG9rTG8x4mSmO4hiX4AFa5O98WLwIAP92PllGMFdvI/edit?usp=sharing)

* List of residency directors was easier to find with ACGME listings.  
![Interactive map of OBGYN residency programs colored by accrediation status](https://github.com/mufflyt/nomogram/blob/dev_0.1/Map%20of%20OBGYN%20residency%20programs.png?raw=true](https://exploratory.io/viz/8171776323392484/Chart-1-WXe3SSx8Vu)


###`Dynamic Nomogram`
We will use DynNom, an R package, to create a Shiny interactive nomogram.  Demonstrate the results of a statistical model object as a dynamic nomogram in an RStudio panel or web browser. The package provides two generics functions: DynNom, which display statistical model objects as a dynamic nomogram; DNbuilder, which builds required scripts to publish a dynamic nomogram on a web server such as the <https://www.shinyapps.io/>. 

[![Dynamic Nomogram](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Flh6.googleusercontent.com%2FI9HnHUeH_ivyt3A3qnDpAXRpi4kfym4iXGdIraHY1fWzWyJ1beqMVcvAUUmDHFwjDuHRtxDKGzAh_owdQYL0HMAZ2anCfM8leE5-OZtuLX-D9-0NCP1agSMc8c0usox55-p6c0TxRG1vVgzc0g&f=1&nofb=1)](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Flh6.googleusercontent.com%2FI9HnHUeH_ivyt3A3qnDpAXRpi4kfym4iXGdIraHY1fWzWyJ1beqMVcvAUUmDHFwjDuHRtxDKGzAh_owdQYL0HMAZ2anCfM8leE5-OZtuLX-D9-0NCP1agSMc8c0usox55-p6c0TxRG1vVgzc0g&f=1&nofb=1)

## Machine Learning
Excellent video from StatQuest:
https://www.youtube.com/watch?v=yIYKR4sgzI8

[![Machine Learning with Classification](https://www.mathworks.com/help/stats/machinelearning_supervisedunsupervised.png)](https://www.mathworks.com/help/stats/machinelearning_supervisedunsupervised.png)

Classification versus Regression
[![Regression vs. Classification](https://static.javatpoint.com/tutorial/machine-learning/images/regression-vs-classification-in-machine-learning.png)](https://static.javatpoint.com/tutorial/machine-learning/images/regression-vs-classification-in-machine-learning.png)

We are going to use glm because that can be converted into a nomogram.  A nomogram can then be put up on a web site for applicants to use.  

[![Course of Data](https://static.cambridge.org/binary/version/id/urn:cambridge.org:id:binary:20170912084613720-0715:9781139028271:fig16_10.png?pub-status=live)](https://static.cambridge.org/binary/version/id/urn:cambridge.org:id:binary:20170912084613720-0715:9781139028271:fig16_10.png?pub-status=live)


## Evaluating the Model
1. AIC (Akaike Information Criteria) – The analogous metric of adjusted R² in logistic regression is AIC. AIC is the measure of fit which penalizes model for the number of model coefficients. Therefore, we always prefer model with minimum AIC value.

2. Null Deviance and Residual Deviance – Null Deviance indicates the response predicted by a model with nothing but an intercept. Lower the value, better the model. Residual deviance indicates the response predicted by a model on adding independent variables. Lower the value, better the model.

3. Confusion Matrix: It is nothing but a tabular representation of Actual vs Predicted values. This helps us to find the accuracy of the model and avoid overfitting. This is how it looks like:

## Confusion Matrix
[![Confusion Matrix](https://blog-c7ff.kxcdn.com/blog/wp-content/uploads/2017/01/myprobbb.jpg)](https://blog-c7ff.kxcdn.com/blog/wp-content/uploads/2017/01/myprobbb.jpg)

[![Confusion Matrix](https://www.unite.ai/wp-content/uploads/2019/12/Preventive_Medicine-e1576294312614.png)](https://www.unite.ai/wp-content/uploads/2019/12/Preventive_Medicine-e1576294312614.png)

## AUC curve
Receiver Operating Characteristic(ROC) summarizes the model’s performance by evaluating the trade offs between true positive rate (sensitivity) and false positive rate(1- specificity). For plotting ROC, it is advisable to assume p > 0.5 since we are more concerned about success rate. ROC summarizes the predictive power for all possible values of p > 0.5.  The area under curve (AUC), referred to as index of accuracy(A) or concordance index, is a perfect performance metric for ROC curve. Higher the area under curve, better the prediction power of the model. Below is a sample ROC curve. The ROC of a perfect predictive model has TP equals 1 and FP equals 0. This curve will touch the top left corner of the graph.

[![AUC Curve](https://glassboxmedicine.files.wordpress.com/2019/02/roc-curve-v2.png)](https://glassboxmedicine.files.wordpress.com/2019/02/roc-curve-v2.png)
https://glassboxmedicine.com/2019/02/23/measuring-performance-auc-auroc/

The area under the receiver operating characteristic (AUROC) is a performance metric that you can use to evaluate classification models. AUROC tells you whether your model is able to correctly rank examples:

For a clinical risk prediction model, the AUROC tells you the probability that a randomly selected patient who experienced an event will have a higher predicted risk score than a randomly selected patient who did not experience an event.  For a binary handwritten digit classification model (“1” vs. “0”), the AUROC tells you the probability that a randomly selected “1” image will have a higher predicted probability of being a “1” than a randomly selected “0”.  AUROC is thus a performance metric for “discrimination”: it tells you about the model’s ability to discriminate between cases (positive examples) and non-cases (negative examples.) An AUROC of 0.8 means that the model has good discriminatory ability: 80% of the time, the model will correctly assign a higher absolute risk to a randomly selected patient with an event than to a randomly selected patient without an event.


## Brier Score
https://medium.com/@magoo/scoring-a-risk-forecast-58673bb6a05e
A Brier Score allows us to measure and monitor the error of our forecasts. It’s described as the the sum of the squared error of outcomes (simple calculator math).

I ultimately memorize it as:```r (outcome — belief) ^ 2 + ... = Brier Score```

[![Brier Score](https://miro.medium.com/max/2608/1*OfJQVKwGbxiUtmpOSxHS5g.png)](https://miro.medium.com/max/2608/1*OfJQVKwGbxiUtmpOSxHS5g.png)

A lower score is better. The more wrong a forecast is, the higher the Brier Score will be. We want to watch the scores of any forecast source (person, machine, panel, etc) to progressively shrink over time and show improvement of our methods.  A perfect score is 0. A total bust is 2.


Please contact me with any questions or concerns: tyler (dot) muffly (at) dhha (dot) org.  

Questions:



Filter out fellows because they will have a lower userid number?
