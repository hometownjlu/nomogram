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

* Predictors under consideration: 2019, 2018
1. `all_data$white_non_white` - Dichotomoized from ethnicity fields in ERAS data, 2 level categorical
2. `all_data$Age` - Age at the time of the match, numerical variable based on Date of Birth POSIXct
3. `all_data$Year` - Year of participation in the match, 4 level categorical
4. `all_data$Gender` - Male or Female, 2 level categorical
5. `all_data$Couples_Match` - PArticipating in the couples match? 2 level categorical
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
26.  `Felony Conviction`

Packrat is in use to control package versions and a packrat.lock file is posted to my github repository.  This will allow for easier reproducibility.  Packrat records the exact package versions you depend on, and ensures those exact versions are the ones that get installed wherever you go.  We can also control the environment by deploying the project inside a Docker container as needed.  The project was created in R version 3.6.1 and run inside RStudio 1.2.5019.  

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

**Use**: `source("Additional_functioins_nomogram.R")` 

1. Library installation.  Sets relative folder paths.  
2. Creation of directory structure.
3. Sets labels for arsenal tableby function.  

**Output**: various functions.


### `All_ERAS_data_merged.R`

**Description**: Pulls data and merges column names

**Use**: `source("All_ERAS_data_merged.R")` 

1. Determine 'Match_Status'
* From ERAS data anyone who applied for a preliminary position ('Ob-Gyn/Preliminary|1076220P0 (Preliminary)') did not match.  This is clearly an assumption and will get checked below. 
* GOBA pull from Dropbox to show who is in an OBGYN residency.
* Cross-reference with Match Lists from various medical schools.  

2. Binds each of the years of Matching Data together from 2020 to 2016 while standardizing column names with parsed case.  Standardize data types.  Age was calculated.  Year columns was added for every year of applicants.  
* Imputed minimal number of 'Self-Identity', 

3. Removes applicants who applied multiple years by using only unique AAMC identification numbers.  
4. Filters applicant age to be greater than 26 years old to account for 6-year undergrad and med school programs.  

**Output**: 
* `Match_Status` (observation): One applicant per row
* `All_ERAS_data_merged_output_2_1_2020.csv` - fully labelled raw dataset containing all rows.

###`Model`
Supervised learning is where you are the teacher in the model is the student. We are training our model to recognize patterns in the data using flashcards. The flashcards for the attributes of applicants to OB/GYN residency in on the back of the flash card is the matching status. Did the applicant match?  Yes or no.￼￼￼￼ Imagine you hand the model a stack of flashcards and we train the model to recognize this pattern future in the wild/with new data that it has never seen before.  

Please contact me with any questions or concerns: tyler (dot) muffly (at) dhha (dot) org.  

###Docker for reproducibilty
Docker allows for stable versions of packages and a similar environment for all authors to work in.  The files to use this docker image are available in `rstudio_v3.tar`.  Thanks to Maksim Boyko.  

In terminal: 

Make sure docker desktop is running.
cd ~/Dropbox/Nomogram/docker/rstudio_v3
At this point you should be in the same directory as the docker-compose.yaml file.  
docker-compose up -d
The result should eventually be: `Creating rstudio_v3_rstudio_1 ... done`
Open browser at http://localhost:8787 with user 'rstudio' and password 'password'

The problem is that the docker image is not linked to the Dropbox directory where I keep the files so I have to download it from github every time.  Rstudio -> File -> New Project -> Check out version -> "https://github.com/mufflyt/nomogram.git".  Please note most of the work I am doing currently is on the `dev_1` branch.  Click on `Git` and then select the branch: `dev_01`.

[![Project flow Data first pass matching](https://github.com/mufflyt/nomogram/blob/dev_0.1/first_pass_who_matched.jpeg?raw=true)](https://github.com/mufflyt/nomogram/blob/dev_0.1/first_pass_who_matched.jpeg?raw=true)

[![Project flow Matching Prediction](https://github.com/mufflyt/nomogram/blob/dev_0.1/project%20data%20flow%20Muffly%20et%20al.jpeg?raw=true)](https://github.com/mufflyt/nomogram/blob/dev_0.1/project%20data%20flow%20Muffly%20et%20al.jpeg?raw=true)

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
