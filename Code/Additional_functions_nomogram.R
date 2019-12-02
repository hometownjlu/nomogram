########################################################################
# This R script implements additional functions for the nomogram database
#
# Author: Tyler Muffly
# Date: 10/19/2019

#Instillation packages
#dev.off()

#Paths
data_folder <- "~/Dropbox/Nomogram/nomogram/data"#paste0(getwd(), "/Data/")
results_folder <- "~/Dropbox/Nomogram/nomogram/results"#paste0(getwd(), "/Results/")
data_file <- "all_years_filter_112.rds"

#Install and Load needed R packages.
# Set libPaths.
.libPaths("/Users/tylermuffly/.exploratory/R/3.6")


pkg <- (c('R.methodsS3', 'caret', 'readxl', 'XML', 'reshape2', 'devtools', 'purrr', 'readr', 'ggplot2', 'dplyr', 'magick', 'janitor', 'lubridate', 'hms', 'tidyr', 'stringr', 'openxlsx', 'forcats', 'RcppRoll', 'tibble', 'bit64', 'munsell', 'scales', 'rgdal', 'tidyverse', "foreach", "PASWR", "rms", "pROC", "ROCR", "nnet", "packrat", "DynNom", "export", "caTools", "mlbench", "randomForest", "ipred", "xgboost", "Metrics", "RANN", "AppliedPredictiveModeling", "nomogramEx", "shiny", "earth", "fastAdaboost", "Boruta", "glmnet", "ggforce", "tidylog", "InformationValue", "pscl", "scoring", "DescTools", "gbm", "Hmisc", "arsenal", "pander", "moments", "leaps", "MatchIt", "car", "mice", "rpart", "beepr", "fansi", "utf8", "zoom", "lmtest", "ResourceSelection", "rmarkdown", "rattle", "rmda", "funModeling", "tinytex", "caretEnsemble", "Rmisc", "corrplot", "GGally", "alluvial", "progress", "perturb", "vctrs", "highr", "labeling", "DataExplorer", "rsconnect", "inspectdf", "ggpubr", "esquisse", "stargazer", "tableone", "knitr", "drake", "visNetwork", "woeBinning", "OneR", "rpart.plot", "RColorBrewer", "kableExtra", "kernlab", "naivebayes", "e1071", "data.table", "skimr", "naniar", "english", "mosaic", "broom", "mltools", "tidymodels", "tidyquant", "plotly", "rsample", "yardstick", "parsnip", "tensorflow", "keras", "sparklyr", "dials", "cowplot"))
#install.packages(pkg, dependencies = TRUE)
lapply(pkg, require, character.only = TRUE)

#install.packages("dplR", dependencies = TRUE)
#library(dplR)
#devtools::install_github("tidymodels/discrim") #for naive bayes with tidymodels
library(discrim)

#install.packages("tensorflow") #https://appdividend.com/2019/01/29/how-to-install-tensorflow-on-mac-tutorial-from-scratch/
#library(tensorflow)
#install_tensorflow()
sess = tf$Session()
hello <- tf$constant('Hello Tyler and TensorFlow!')
sess$run(hello)

#pacman::p_install_gh("cran/doMC")
library("doMC")
doMC::registerDoMC(cores = detectCores()-1) #Use multiple cores for processing

### Skimr set up
skim_with(numeric = list(hist = NULL), integer = list(hist = NULL))

#####  Functions for nomogram
create_plot_num <- 
  function(data) {
    funModeling::plot_num(data, path_out = results_folder)
  } 

create_plot_cross_plot <- 
  function(data) {
    funModeling::cross_plot(data, 
                            input=(colnames(data)), 
                            target="Match_Status", 
                            path_out = results_folder,
                            auto_binning = TRUE)
  } #, auto_binning = FALSE, #Export results

create_profiling_num <- 
  function(data) {
    funModeling::profiling_num(data)
  }


#####  Load in the data
#Create a dataframe of independent and dependent variables. 
## Here are the data for download
URL<- paste0("https://www.dropbox.com/s/qbykb8sl2c8z3me/", (data_file), "?raw=1")
download.file(url = URL, destfile = paste0(data_file), method = "curl")

# read in data
all_data <- 
  read_rds(paste0(data_folder, "/", data_file)) %>%
  select(-"Gold_Humanism_Honor_Society", 
         -"Sigma_Sigma_Phi", 
         -"Misdemeanor_Conviction", 
         -"Malpractice_Cases_Pending", 
         -"Citizenship", 
         -"BLS", 
         -"Positions_offered") 

all_data <- 
  all_data[c(
    'white_non_white', 
    'Age',  
    'Year', 
    'Gender', 
    'Couples_Match', 
    'US_or_Canadian_Applicant', 
    "Medical_Education_or_Training_Interrupted", 
    "Alpha_Omega_Alpha",  
    "Military_Service_Obligation", 
    "USMLE_Step_1_Score", 
    "Count_of_Poster_Presentation",  
    "Count_of_Oral_Presentation", 
    "Count_of_Peer_Reviewed_Journal_Articles_Abstracts", 
    "Count_of_Peer_Reviewed_Book_Chapter", 
    "Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published", 
    "Count_of_Peer_Reviewed_Online_Publication", 
    "Visa_Sponsorship_Needed", 
    "Medical_Degree", 
    'Match_Status')]

#Rename columns with more human readable names
colnames(all_data)[colnames(all_data)=="Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published"] <- "Count_of_Other_than_Published"

colnames(all_data)[colnames(all_data)=="Count_of_Peer_Reviewed_Journal_Articles_Abstracts"] <- "Count_of_Articles_Abstracts"

colnames(all_data)[colnames(all_data)=="Medical_Education_or_Training_Interrupted"] <- 
  "Medical_Education_Interrupted"

colnames(all_data)[colnames(all_data)=="Count_of_Peer_Reviewed_Online_Publication"] <- 
  "Count_of_Online_Publications"

colnames(all_data)[colnames(all_data)=="Match_Status_Dichot"] <- 
  "Match_Status"

#factor_columns <- all_data %>%  select_if(is.factor) %>% colnames()
#factor_columns

all_data$Count_of_Online_Publications <- as.numeric(all_data$Count_of_Online_Publications)

all_data$white_non_white <- forcats::fct_explicit_na(all_data$white_non_white, na_level="(Missing)")
all_data$Year <- forcats::fct_explicit_na(all_data$Year, na_level="(Missing)")
all_data$Gender <- forcats::fct_explicit_na(all_data$Gender, na_level="(Missing)")
all_data$Couples_Match <- forcats::fct_explicit_na(all_data$Couples_Match, na_level="(Missing)")
all_data$US_or_Canadian_Applicant <- forcats::fct_explicit_na(all_data$US_or_Canadian_Applicant, na_level="(Missing)")
all_data$Medical_Education_Interrupted <- forcats::fct_explicit_na(all_data$Medical_Education_Interrupted, na_level="(Missing)")
all_data$Alpha_Omega_Alpha <- forcats::fct_explicit_na(all_data$Alpha_Omega_Alpha, na_level="(Missing)")
all_data$Military_Service_Obligation <- forcats::fct_explicit_na(all_data$Military_Service_Obligation, na_level="(Missing)")
all_data$Visa_Sponsorship_Needed <- forcats::fct_explicit_na(all_data$Visa_Sponsorship_Needed, na_level="(Missing)")
all_data$Medical_Degree <- forcats::fct_explicit_na(all_data$Medical_Degree, na_level="(Missing)")
all_data$Match_Status <- forcats::fct_explicit_na(all_data$Match_Status, na_level="(Missing)")

all_data$Count_of_Articles_Abstracts <- as.numeric(all_data$Count_of_Articles_Abstracts)
all_data$Age <- as.numeric(all_data$Age)
all_data$Count_of_Poster_Presentation <- as.numeric(all_data$Count_of_Poster_Presentation)
all_data$USMLE_Step_1_Score <- as.numeric(all_data$USMLE_Step_1_Score)
all_data$Count_of_Oral_Presentation <- as.numeric(all_data$Count_of_Oral_Presentation)
all_data$Count_of_Other_than_Published <- as.numeric(all_data$Count_of_Other_than_Published)
all_data$Count_of_Peer_Reviewed_Book_Chapter <- as.numeric(all_data$Count_of_Peer_Reviewed_Book_Chapter)
all_data$Count_of_Online_Publications <- as.numeric(all_data$Count_of_Online_Publications)

all_data <- na.omit(all_data)

#Set reference category for each variable
#donors$wealth_rating <- relevel(donors$wealth_rating, ref = "Medium")
contrasts(all_data$US_or_Canadian_Applicant)
all_data$US_or_Canadian_Applicant <- relevel(all_data$US_or_Canadian_Applicant, ref = "US senior")
contrasts(all_data$white_non_white)
all_data$white_non_white <- relevel(all_data$white_non_white, ref = "White")
all_data$Gender <- relevel(all_data$Gender, ref = "Female")
all_data$Couples_Match <- relevel(all_data$Couples_Match, ref = "No")
all_data$Medical_Education_Interrupted <- relevel(all_data$Medical_Education_Interrupted, ref = "No")
all_data$Alpha_Omega_Alpha <- relevel(all_data$Alpha_Omega_Alpha, ref = "No")
all_data$Military_Service_Obligation <- relevel(all_data$Military_Service_Obligation, ref = "No")
all_data$Medical_Degree <- relevel (all_data$Medical_Degree, ref = "MD")
all_data$Visa_Sponsorship_Needed <- relevel(all_data$Visa_Sponsorship_Needed, ref = "No")

write_csv(all_data, "~/all_data.csv")

#### https://stirlingcodingclub.github.io/Manuscripts_in_Rmarkdown/Rmarkdown_notes.html
knitr::opts_chunk$set(fig.width=7, 
                      fig.height=5,
                      fig.align="center",
                      include=FALSE,
                      echo=FALSE, # does not show R code
                      warning=FALSE,  # does not show warnings during generation
                      message=FALSE, # shows no messages
                      tidy = TRUE, 
                      comment="",
                      align = 'left',
                      cache = TRUE,
                      dev = "png",   #Will need to change for manuscript
                      dpi = 200)   #Will need to change for manuscript


custom_theme <- function(...){   ##My ggplot theme
  theme(legend.position = "bottom", 
        legend.text = element_text(size = 8),
        panel.background = element_rect(fill = "white"),
        strip.background = element_rect(fill = "white"),
        axis.line.x = element_line(color="black"),
        axis.line.y = element_line(color="black"))
}

pander::panderOptions("table.split.table", Inf)
options(width = 100) # ensure skim results fit on one line
set.seed(123456)

###tableby labels
mylabels <- list(white_non_white = "Race", Age = "Age, years", Gender = "Sex", Couples_Match = "Participating in the Couples Match", US_or_Canadian_Applicant = "US or Canadian Applicant", Medical_Education_Interrupted = "Medical Education Process was Interrupted", Alpha_Omega_Alpha = "Alpha Omega Alpha", Military_Service_Obligation = "Military Service Obligation", USMLE_Step_1_Score = "USMLE Step 1 Score", Military_Service_Obligation = "Military Service Obligations", Count_of_Poster_Presentation = "Count of Poster Presentations", Count_of_Oral_Presentation = "Count of Oral Presentations", Count_of_Articles_Abstracts = "Count of Published Abstracts", Count_of_Peer_Reviewed_Book_Chapter = "Count of Peer Reviewed Book Chapters", Count_of_Other_than_Published = "Count of Other Published Products", Count_of_Online_Publications = "Count of Online Publications", Visa_Sponsorship_Needed = "Visa Sponsorship is Needed", Medical_Degree = "Medical Degree Training")

##Custom Functions that I made to eliminate repetition from my code
#https://www.kaggle.com/pjmcintyre/titanic-first-kernel#final-checks
tm_nomogram_prep <- function(df){  #signature of the function
  set.seed(1978)                  #body of the function
  test <- rms::nomogram(df,
                #lp.at = seq(-3,4,by=0.5),
                fun = plogis,
                fun.at = c(0.001, 0.01, 0.05, seq(0.2, 0.8, by = 0.2), 0.95, 0.99, 0.999),
                funlabel = "Chance of Matching in OBGYN",
                lp =FALSE,
                #conf.int = c(0.1,0.7),
                abbrev = F,
                minlength = 9)
  
  tm_plot <- plot(test, lplabel="Linear Predictor",
       cex.sub = 0.3, cex.axis=0.4, cex.main=1, cex.lab=0.2, ps=10, xfrac=1,
       col.conf=c('red','green'),
       conf.space=c(0.1,0.5),
       label.every=1,
       col.grid = gray(c(0.8, 0.95)),
       which="Match_Status")
  return(tm_plot)
  }

tm_rpart_plot = function(df){
  tm_rpart_plot_leaves <- rpart.plot::rpart.plot(df, yesno = 2, type = 5, extra = +100, fallen.leaves = TRUE, varlen = 0, faclen = 0, roundint = TRUE, clip.facs = TRUE, shadow.col = "gray", main = "Tree Model of Medical Students Matching into OBGYN Residency\n(Matched or Unmatched)", box.palette = c("red", "green"))  
  tm_fancy_rpart <- fancyRpartPlot(df)
  return(c(tm_rpart_plot_leaves, tm_fancy_rpart))
  }

# Draws a nice table one plot
tm_arsenal_table = function(df, by){
  table_variable_within_function <- arsenal::tableby(by ~ .,
                 data=df, control = tableby.control(test = TRUE,
                                                                total = F,
                                                                digits = 1L,
                                                                digits.p = 2L,
                                                                digits.count = 0L,
                                                                numeric.simplify = F,
                                                                numeric.stats =
                                                                  c("median",
                                                                    "q1q3"),
                                                                cat.stats =
                                                                  c("Nmiss",
                                                                    "countpct"),
                                                                stats.labels = list(Nmiss = "N Missing",
                                                                                    Nmiss2 ="N Missing",
                                                                                    meansd = "Mean (SD)",
                                                                                    medianrange = "Median (Range)",
                                                                                    median ="Median",
                                                                                    medianq1q3 = "Median (Q1, Q3)",
                                                                                    q1q3 = "Q1, Q3",
                                                                                    iqr = "IQR",
                                                                                    range = "Range",
                                                                                    countpct = "Count (Pct)",
                                                                                    Nevents = "Events",
                                                                                    medSurv ="Median Survival",
                                                                                    medTime = "Median Follow-Up")))
  final <- summary(table_variable_within_function,
          text=T,
          title = 'Table: Applicant Descriptive Variables by Matched or Did Not Match from 2015 to 2018',
          labelTranslations = mylabels, #Seen in additional functions file
          pfootnote=TRUE)
  return(final)
}

#Draws a nice plot of the variable strengths using ANOVA.  
tm_chart_strength_of_variables <- function(df) {
  plot <- plot(anova(df), cex=1, cex.lab=1.3, cex.axis = 0.9)
  return(plot)
}

#Helpful plot of variable importance for variable selection
tm_variable_importance = function(df) {
  rf_imp <- varImp(df, scale = FALSE)
  rf_imp <- rf_imp$importance
  rf_gini <- data.frame(Variables = row.names(rf_imp), MeanDecreaseGini = rf_imp$Overall)
  
  rf_plot <- ggplot(rf_gini, aes(x=reorder(Variables, MeanDecreaseGini), y=MeanDecreaseGini, fill=MeanDecreaseGini)) +
    geom_bar(stat='identity') + coord_flip() + theme(legend.position="none") + labs(x="") +
    ggtitle('Variable Importance Random Forest') + theme(plot.title = element_text(hjust = 0.5))
  return(rf_plot)
}

calc_metrics <- function(model, new_data, truth) {
  truth_expr <- enquo(truth)
  
  suppressWarnings({
    model %>%
      stats::predict(new_data = new_data) %>%
      bind_cols(new_data %>% select(!! truth_expr)) %>%
      yardstick::metrics(truth = !! truth_expr, 
              estimate = .pred) %>%
      dplyr::select(-.estimator) %>%
      tidyr::spread(.metric, .estimate)
  })
  
}

#Tidymodels feature plots
box_fun_plot = function(data, x, y) {
  ggplot(data = data, aes(x = .data[[x]],
                          y = .data[[y]],
                          fill = .data[[x]])) +
    geom_boxplot() +
    labs(title = y,
         x = x,
         y = y) +
    theme(
      legend.position = "none"
    )
}

density_fun_plot = function(data, x, y) {
  ggplot(data = data, aes(x = .data[[y]],
                          fill = .data[[x]])) +
    geom_density(alpha = 0.7) +
    labs(title = y,
         x = y) +
    theme(
      legend.position = "none"
    )
}

#Recipe function - First, I create a recipe where I define the transformations I want to apply to my data. In this case I create a simple recipe to change all character variables to factors.
#https://ryjohnson09.netlify.com/post/caret-and-tidymodels/

#The order in which you infer, center, scale, etc does matter (see this post).

# 1) Impute
# 2) Individual transformations for skewness and other issues
# 3) Discretize (if needed and if you have no other choice)
# 4) Create dummy variables
# 5) Create interactions
# 6) Normalization steps (center, scale, range, etc)
# 7) Multivariate transformation (e.g. PCA, spatial sign, etc)

recipe_simple <- function(dataset) {
  recipe(Match_Status ~ ., data = dataset) %>%
  recipes::step_string2factor(all_nominal(), -all_outcomes()) %>%
    add_role(Match_Status, new_role = "outcome") %>% 
    add_role(starts_with("Count_of_"), new_role = "predictor") %>% 
    add_role(white_non_white, Age, Gender, Couples_Match, US_or_Canadian_Applicant, Medical_Education_Interrupted, Alpha_Omega_Alpha, Military_Service_Obligation, USMLE_Step_1_Score, Visa_Sponsorship_Needed, Medical_Degree, new_role = "predictor") %>%
  recipes::step_corr(all_numeric(), method = "pearson", threshold = 0.9)
  }   #Cool looks for correlation
    # Add dummy variables for "class" variables
    #recipes::step_dummy(all_nominal(), -all_outcomes(), one_hot = TRUE) %>%  #Deal with categories
    # Center and Scale
    # recipes::step_center(all_predictors()) %>% 
    # recipes::step_scale(all_predictors())


#Now I need to create a function that contains my model that can be iterated over each split of the data. I also want a function that will make predictions using said model.
fit_mod_func <- function(split, spec){
  parsnip::fit(object = spec,
      formula = Match_Status ~ .,
      data = rsample::analysis(split))
}

predict_func <- function(split, model){
  # Extract the assessment data
  assess <- rsample::assessment(split)
  # Make prediction
  pred <- stats::predict(model, new_data = assess)
  dplyr::as_tibble(cbind(assess, pred[[1]]))
}

# Will calculate accuracy of classification
perf_metrics <- yardstick::metric_set(accuracy)

# Create a function that will take the prediction and compare to truth
rf_metrics <- function(pred_df){
  perf_metrics(
    pred_df,
    truth = Match_Status,
    estimate = res # res is the column name for the predictions
  )
}

#https://tidymodels.github.io/rsample/articles/Working_with_rsets.html
tm_holdout_results <- function(splits, ...) {
  # Fit the model to the 90%
  mod <- glm(..., data = analysis(splits), family = binomial)
  # Save the 10%
  holdout <- assessment(splits)
  # `augment` will save the predictions with the holdout data set
  res <- broom::augment(mod, newdata = holdout)
  # Class predictions on the assessment set from class probs
  lvls <- levels(holdout$Match_Status)
  predictions <- factor(ifelse(res$.fitted > 0, lvls[2], lvls[1]),
                        levels = lvls)
  # Calculate whether the prediction was correct
  res$correct <- predictions == holdout$Match_Status
  # Return the assessment data set with the additional columns
  res
}

tm_confusion_matrix_graph <- function (model_name, label) {  #label should be in quotation marks
model_name %>%  #Plug in the model using the training data
  stats::predict(new_data = test_baked) %>%  #Predict the test_data with the new model
  bind_cols(test_baked) %>%
  conf_mat(Match_Status, .pred_class) %>%
  purrr::pluck(1) %>%
  tibble::as_tibble() %>%
  ggplot2::ggplot(aes(Prediction, Truth, alpha = n)) +  
  ggplot2::geom_tile(show.legend = FALSE) +
  ggplot2::geom_text(aes(label = n), colour = "white", alpha = 1, size = 8) +
  labs(
    title = paste('Confusion matrix using:', label, sep = " ")) }

