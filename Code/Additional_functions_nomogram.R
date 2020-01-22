########################################################################
# This R script implements additional functions for the nomogram database
#
# Author: Tyler Muffly
# Date: 10/19/2019

#Instillation packages
#dev.off()

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
# Directory Paths for Data and Results
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 

#Builds the file directory structure necessary for the project
# getwd()
# library(fs)
# make_project_dir <- function() {
#     
#     dir_names <- c("Code",
#         "results",
#         "tables",
#         "Saved_Models")
#     dir_create(dir_names)
#     dir_ls()
# }
# make_project_dir()
#system("ls ..")

data_folder <- paste0(getwd(), "/Data/")
results_folder <- paste0(getwd(), "/Results/")

#data_file <- "all_years_mutate_124.csv"
data_file <- "all_years_filter_112.rds" 

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#Install and Load needed R packages.
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####
# Set libPaths.
.libPaths("/Users/tylermuffly/.exploratory/R/3.6")

pkg <- (c('R.methodsS3', 'caret', 'readxl', 'XML', 'reshape2', 'devtools', 'purrr', 'readr', 'ggplot2', 'dplyr', 'magick', 'janitor', 'lubridate', 'hms', 'tidyr', 'stringr', 'openxlsx', 'forcats', 'RcppRoll', 'tibble', 'bit64', 'munsell', 'scales', 'rgdal', 'tidyverse', "foreach", "PASWR", "rms", "pROC", "ROCR", "nnet", "packrat", "DynNom", "export", "caTools", "mlbench", "randomForest", "ipred", "xgboost", "Metrics", "RANN", "AppliedPredictiveModeling", "nomogramEx", "shiny", "earth", "fastAdaboost", "Boruta", "glmnet", "ggforce", "tidylog", "InformationValue", "pscl", "scoring", "DescTools", "gbm", "Hmisc", "arsenal", "pander", "moments", "leaps", "MatchIt", "car", "mice", "rpart", "beepr", "fansi", "utf8", "zoom", "lmtest", "ResourceSelection", "rmarkdown", "rattle", "rmda", "funModeling", "tinytex", "caretEnsemble", "Rmisc", "corrplot", "progress", "perturb", "vctrs", "highr", "labeling", "DataExplorer", "rsconnect", "inspectdf", "ggpubr", "tableone", "knitr", "drake", "visNetwork", "rpart.plot", "RColorBrewer", "kableExtra", "kernlab", "naivebayes", "e1071", "data.table", "skimr", "naniar", "english", "mosaic", "broom", "mltools", "tidymodels", "tidyquant", "rsample", "yardstick", "parsnip", "tensorflow", "keras", "sparklyr", "dials", "cowplot", "lime", "flexdashboard", "shinyjs", "shinyWidgets", "plotly", "odbc", "BH", "discrim", "vip", "ezknitr", "here", "usethis", "gbm", "corrgram", "BiocManager", "factoextra", "parallel", "doParallel", "GA", "PCAtools", "odbc", "RSQLite", "discrim", "doMC", "BiocManager", "summarytools", "pander", "remotes", "fs"))

#install.packages(pkg,dependencies = c("Depends", "Suggests"), repos = "https://cloud.r-project.org")  #run this first time
lapply(pkg, require, character.only = TRUE)
doMC::registerDoMC(cores = detectCores()-1) #Use multiple cores for processing

#BiocManager::install('PCAtools')

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
# Package functions customization
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### ####

packrat::set_opts(auto.snapshot = TRUE, use.cache = TRUE)

#### https://stirlingcodingclub.github.io/Manuscripts_in_Rmarkdown/Rmarkdown_notes.html
knitr::opts_chunk$set(fig.width=7, 
                      fig.height=5,
                      fig.align="center",
                      include=TRUE,
                      echo=TRUE, # does not show R code
                      warning=FALSE,  # does not show warnings during generation
                      message=FALSE, # shows no messages
                      tidy = TRUE, 
                      comment="",
                      align = 'left',
                      cache = FALSE,  #keep as false so I don't get random error messages later on
                      dev = "png",   #Will need to change for manuscript
                      dpi = 200)   #Will need to change for manuscript


### Skimr set up
skim_with(numeric = list(hist = NULL), integer = list(hist = NULL))

## TinyTex
options(tinytex.verbose = FALSE)
#tinytex::tlmgr_update()  # update LaTeX packages

custom_theme <- function(...){   ##My ggplot theme
  theme(legend.position = "bottom", 
        legend.text = element_text(size = 8),
        panel.background = element_rect(fill = "white"),
        strip.background = element_rect(fill = "white"),
        axis.line.x = element_line(color="black"),
        axis.line.y = element_line(color="black"))
}

pander::panderOptions("table.split.table", Inf)
options(width = 100) # ensures skimr results fit on one line
set.seed(123456)

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#####  Functions for nomogram
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
create_plot_num <- 
  function(data) {
    print("Function Sanity Check: Plot Numeric Features")
    funModeling::plot_num(data, path_out = results_folder)
  } 

create_plot_cross_plot <- 
  function(data) {
    print("Function Sanity Check: Cross Plot Features")
    funModeling::cross_plot(data, 
                            input=(colnames(data)), 
                            target="Match_Status", 
                            path_out = results_folder,
                            auto_binning = TRUE)
  } #, auto_binning = FALSE, #Export results
#For numerical variables, cross_plot has by default the auto_binning=T, which automatically calls the equal_freq function with n_bins=10 (or the closest number).

create_profiling_num <- 
  function(data) {
    print("Function Sanity Check: Plot Numeric Features")
    funModeling::profiling_num(data)
  }

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#####  Load in the data
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#Create a dataframe of independent and dependent variables. 
## Here are the data for download
URL<- paste0("https://www.dropbox.com/s/qbykb8sl2c8z3me/", (data_file), "?raw=1") #This works
download.file(url = URL, destfile = paste0(data_file), method = "wget") #this works
#wget (http://www.gnu.org/software/wget/) is commonly installed on Unix-alikes (but not macOS).


#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#####  Read in the data
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
all_data <- 
  read_rds(paste0(data_folder, "/", data_file)) %>%
  #read_csv(paste0(data_folder, "/", data_file)) %>%
  select(-"Gold_Humanism_Honor_Society", 
         -"Sigma_Sigma_Phi", 
         -"Misdemeanor_Conviction", 
         -"Malpractice_Cases_Pending", 
         -"Citizenship", 
         -"BLS", 
         -"Positions_offered") 

colnames(all_data)

all_data <- 
  all_data[c(
    'white_non_white', 
    'Age',  
    #'Year', 
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
       # 'Rank',
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
#all_data$Year <- forcats::fct_explicit_na(all_data$Year, na_level="(Missing)")
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


#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#####  Set reference category for each variable
#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
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



###tableby labels
mylabels <- list(white_non_white = "Race", Age = "Age, years", Gender = "Sex", Couples_Match = "Participating in the Couples Match", US_or_Canadian_Applicant = "US or Canadian Applicant", Medical_Education_Interrupted = "Medical Education Process was Interrupted", Alpha_Omega_Alpha = "Alpha Omega Alpha", Military_Service_Obligation = "Military Service Obligation", USMLE_Step_1_Score = "USMLE Step 1 Score", Military_Service_Obligation = "Military Service Obligations", Count_of_Poster_Presentation = "Count of Poster Presentations", Count_of_Oral_Presentation = "Count of Oral Presentations", Count_of_Articles_Abstracts = "Count of Published Abstracts", Count_of_Peer_Reviewed_Book_Chapter = "Count of Peer Reviewed Book Chapters", Count_of_Other_than_Published = "Count of Other Published Products", Count_of_Online_Publications = "Count of Online Publications", Visa_Sponsorship_Needed = "Visa Sponsorship is Needed", Medical_Degree = "Medical Degree Training")

##Custom Functions that I made to eliminate repetition from my code
#https://www.kaggle.com/pjmcintyre/titanic-first-kernel#final-checks
tm_nomogram_prep <- function(df){  #signature of the function
  set.seed(1978)                  #body of the function
  print("Function Sanity Check: Creation of Nomogram")
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
  print("Function Sanity Check: Plot Decision Trees using package rpart with Leaves")
  tm_rpart_plot_leaves <- rpart.plot::rpart.plot(df, yesno = 2, type = 5, extra = +100, fallen.leaves = TRUE, varlen = 0, faclen = 0, roundint = TRUE, clip.facs = TRUE, shadow.col = "gray", main = "Tree Model of Medical Students Matching into OBGYN Residency\n(Matched or Unmatched)", box.palette = c("red", "green"))  
  tm_fancy_rpart <- fancyRpartPlot(df)
  return(c(tm_rpart_plot_leaves, tm_fancy_rpart))
  }

# Draws a nice table one plot
tm_arsenal_table = function(df, by){
  print("Function Sanity Check: Create Arsenal Table using arsenal package")
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
  print("Function Sanity Check: Plotting ANOVA dataframe for variable strength")
  plot <- plot(anova(df), cex=1, cex.lab=1.3, cex.axis = 0.9)
  return(plot)
}

#Helpful plot of variable importance for variable selection
tm_variable_importance = function(df) {
  print("Function Sanity Check: Evaluate Variable Importance")
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
  print("Function Sanity Check: Function to fit her model using parsnip package")
  parsnip::fit(object = spec,
      formula = Match_Status ~ .,
      data = rsample::analysis(split))
}

predict_func <- function(split, model){
  print("Function Sanity Check: Prediction Function")
  # Extract the assessment data
  assess <- rsample::assessment(split)
  # Make prediction
  pred <- stats::predict(model, new_data = assess)
  dplyr::as_tibble(cbind(assess, pred[[1]]))
}

# Will calculate accuracy of classification
#perf_metrics <- yardstick::metric_set(accuracy)

# Create a function that will take the prediction and compare to truth
rf_metrics <- function(pred_df){
  print("Function Sanity Check: Compare the truth to the predictions")
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
  print("Function Sanity Check: Create Confusino Matrix Graphs")
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

# HR 201: PREDICTING EMPLOYEE ATTRITION WITH H2O AND LIME ----
# CHAPTER 4: H2O MODELING ----
# Extracts and H2O model name by a position so can more easily use h2o.getModel()
extract_h2o_model_name_by_position <- function(h2o_leaderboard, n = 1, verbose = T) {
  print("Function Sanity Check: Extracts H2O model name as a position")
  
  model_name <- h2o_leaderboard %>%
    as.tibble() %>%
    dplyr::slice(n) %>%
    pull(model_id)
  
  if (verbose) message(model_name)
  
  return(model_name)
  
}


# Visualize the H2O leaderboard to help with model selection
plot_h2o_leaderboard <- function(h2o_leaderboard, order_by = c("auc", "logloss"), 
                                 n_max = 20, size = 4, include_lbl = TRUE) {
  print("Function Sanity Check: H2O leaderboard visualization")
  # Setup inputs
  order_by <- tolower(order_by[[1]])
  
  leaderboard_tbl <- h2o_leaderboard %>%
    as.tibble() %>%
    dplyr::mutate(model_type = str_split(model_id, "_", simplify = T) %>% .[,1]) %>%
    rownames_to_column(var = "rowname") %>%
    dplyr::mutate(model_id = paste0(rowname, ". ", as.character(model_id)) %>% as.factor())
  
  # Transformation
  if (order_by == "auc") {
    
    data_transformed_tbl <- leaderboard_tbl %>%
      dplyr::slice(1:n_max) %>%
      dplyr::mutate(
        model_id   = as_factor(model_id) %>% reorder(auc),
        model_type = as.factor(model_type)
      ) %>%
      tidyr::gather(key = key, value = value, 
             -c(model_id, model_type, rowname), factor_key = T)
    
  } else if (order_by == "logloss") {
    
    data_transformed_tbl <- leaderboard_tbl %>%
      dplyr::slice(1:n_max) %>%
      dplyr::mutate(
        model_id   = as_factor(model_id) %>% reorder(logloss) %>% fct_rev(),
        model_type = as.factor(model_type)
      ) %>%
      tidyr::gather(key = key, value = value, -c(model_id, model_type, rowname), factor_key = T)
    
  } else {
    stop(paste0("order_by = '", order_by, "' is not a permitted option."))
  }
  
  # Visualization
  print("Function Sanity Check: Creating Visualization")
  g <- data_transformed_tbl %>%
    ggplot(aes(value, model_id, color = model_type)) +
    geom_point(size = size) +
    facet_wrap(~ key, scales = "free_x") +
    #tidyquant::theme_tq() +
    scale_color_tq() +
    labs(title = "Leaderboard Metrics",
         subtitle = paste0("Ordered by: ", toupper(order_by)),
         y = "Model Postion, Model ID", x = "")
  
  if (include_lbl) g <- g + geom_label(aes(label = round(value, 2), hjust = "inward"))
  
  return(g)
  
}


# Convert a leaderboard into a Performance Diagnostic Dashboard
# containing an ROC Plot, Precision vs Recall Plot, Gain Plot, and Lift Plot
plot_h2o_performance <- function(h2o_leaderboard, newdata, order_by = c("auc", "logloss"),
                                 max_models = 3, size = 1.5) {
  print("Function Sanity Check: Plot H2O performance")
  # Inputs
  
  leaderboard_tbl <- h2o_leaderboard %>%
    as.tibble() %>%
    dplyr::slice(1:max_models)
  
  newdata_tbl <- newdata %>%
    as.tibble()
  
  order_by <- tolower(order_by[[1]])
  order_by_expr <- rlang::sym(order_by)
  
  h2o.no_progress()
  
  # 1. Model metrics
  print("Function Sanity Check: Check Model Performance Metrics")
  get_model_performance_metrics <- function(model_id, test_tbl) {
    
    model_h2o <- h2o.getModel(model_id)
    perf_h2o  <- h2o.performance(model_h2o, newdata = as.h2o(test_tbl))
    
    perf_h2o %>%
      h2o.metric() %>%
      as.tibble() %>%
      select(threshold, tpr, fpr, precision, recall)
    
  }
  
  model_metrics_tbl <- leaderboard_tbl %>%
    dplyr::mutate(metrics = map(model_id, get_model_performance_metrics, newdata_tbl)) %>%
    unnest() %>%
    dplyr::mutate(
      model_id = as_factor(model_id) %>% 
        fct_reorder(!! order_by_expr, .desc = ifelse(order_by == "auc", TRUE, FALSE)),
      auc  = auc %>% 
        round(3) %>% 
        as.character() %>% 
        as_factor() %>% 
        fct_reorder(as.numeric(model_id)),
      logloss = logloss %>% 
        round(4) %>% 
        as.character() %>% 
        as_factor() %>% 
        fct_reorder(as.numeric(model_id))
    )
  
  
  # 1A. ROC Plot
  
  p1 <- model_metrics_tbl %>%
    ggplot(aes_string("fpr", "tpr", color = "model_id", linetype = order_by)) +
    geom_line(size = size) +
    #tidyquant::theme_tq() +
    scale_color_tq() +
    labs(title = "ROC", x = "FPR", y = "TPR") +
    theme(legend.direction = "vertical")
  
  # 1B. Precision vs Recall
  
  p2 <- model_metrics_tbl %>%
    ggplot(aes_string("recall", "precision", color = "model_id", linetype = order_by)) +
    geom_line(size = size) +
    #tidyquant::theme_tq() +
    scale_color_tq() +
    labs(title = "Precision Vs Recall", x = "Recall", y = "Precision") +
    theme(legend.position = "none")
  
  
  # 2. Gain / Lift
  
  get_gain_lift <- function(model_id, test_tbl) {
    
    model_h2o <- h2o.getModel(model_id)
    perf_h2o  <- h2o.performance(model_h2o, newdata = as.h2o(test_tbl)) 
    
    perf_h2o %>%
      h2o.gainsLift() %>%
      as.tibble() %>%
      select(group, cumulative_data_fraction, cumulative_capture_rate, cumulative_lift)
    
  }
  
  gain_lift_tbl <- leaderboard_tbl %>%
    dplyr::mutate(metrics = map(model_id, get_gain_lift, newdata_tbl)) %>%
    unnest() %>%
    dplyr::mutate(
      model_id = as_factor(model_id) %>% 
        fct_reorder(!! order_by_expr, .desc = ifelse(order_by == "auc", TRUE, FALSE)),
      auc  = auc %>% 
        round(3) %>% 
        as.character() %>% 
        as_factor() %>% 
        fct_reorder(as.numeric(model_id)),
      logloss = logloss %>% 
        round(4) %>% 
        as.character() %>% 
        as_factor() %>% 
        fct_reorder(as.numeric(model_id))
    ) %>%
    rename(
      gain = cumulative_capture_rate,
      lift = cumulative_lift
    ) 
  
  # 2A. Gain Plot
  
  p3 <- gain_lift_tbl %>%
    ggplot(aes_string("cumulative_data_fraction", "gain", 
                      color = "model_id", linetype = order_by)) +
    geom_line(size = size) +
    geom_segment(x = 0, y = 0, xend = 1, yend = 1, 
                 color = "black", size = size) +
    #tidyquant::theme_tq() +
    scale_color_tq() +
    expand_limits(x = c(0, 1), y = c(0, 1)) +
    labs(title = "Gain",
         x = "Cumulative Data Fraction", y = "Gain") +
    theme(legend.position = "none")
  
  # 2B. Lift Plot
  
  p4 <- gain_lift_tbl %>%
    ggplot(aes_string("cumulative_data_fraction", "lift", 
                      color = "model_id", linetype = order_by)) +
    geom_line(size = size) +
    geom_segment(x = 0, y = 1, xend = 1, yend = 1, 
                 color = "black", size = size) +
    #tidyquant::theme_tq() +
    scale_color_tq() +
    expand_limits(x = c(0, 1), y = c(0, 1)) +
    labs(title = "Lift",
         x = "Cumulative Data Fraction", y = "Lift") +
    theme(legend.position = "none")
  
  
  # Combine using cowplot
  p_legend <- get_legend(p1)
  p1 <- p1 + theme(legend.position = "none")
  
  p <- cowplot::plot_grid(p1, p2, p3, p4, ncol = 2) 
  
  p_title <- ggdraw() + 
    draw_label("H2O Model Metrics", size = 18, fontface = "bold", 
               colour = palette_light()[[1]])
  
  p_subtitle <- ggdraw() + 
    draw_label(glue("Ordered by {toupper(order_by)}"), size = 10,  
               colour = palette_light()[[1]])
  
  ret <- plot_grid(p_title, p_subtitle, p, p_legend, 
                   ncol = 1, rel_heights = c(0.05, 0.05, 1, 0.05 * max_models))
  
  h2o.show_progress()
  
  return(ret)
  
}

# Precision vs Recall
load_model_performance_metrics <- function(path, test_tbl) {
  print("Function Sanity Check: Load Model Performance Metrics")
  model_h2o <- h2o.loadModel(path)
  perf_h2o  <- h2o.performance(model_h2o, newdata = as.h2o(test_tbl)) 
  
  perf_h2o %>%
    h2o.metric() %>%
    as.tibble() %>%
    mutate(auc = h2o.auc(perf_h2o)) %>%
    select(tpr, fpr, auc, precision, recall)
}


plot_features_tq <- function(explanation, ncol) {
  print("Function Sanity Check: Plot Features using the TQ theme")
  data_transformed <- explanation %>%
    as.tibble() %>%
    mutate(
      feature_desc = as_factor(feature_desc) %>% 
        fct_reorder(abs(feature_weight), .desc = FALSE),
      key     = ifelse(feature_weight > 0, "Supports", "Contradicts") %>% 
        fct_relevel("Supports"),
      case_text    = glue("Case: {case}"),
      label_text   = glue("Label: {label}"),
      prob_text    = glue("Probability: {round(label_prob, 2)}"),
      r2_text      = glue("Explanation Fit: {model_r2 %>% round(2)}")
    ) %>%
    select(feature_desc, feature_weight, key, case_text:r2_text)
  
  
  data_transformed %>%
    ggplot(aes(feature_desc, feature_weight, fill = key)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    #theme_tq() +
    scale_fill_tq() +
    labs(y = "Weight", x = "Feature") +
    theme(title = element_text(size = 9)) +
    facet_wrap(~ case_text + label_text + prob_text + r2_text,
               ncol = ncol, scales = "free")
  
}



plot_explanations_tq <- function(explanation) {
  
  data_transformed <- explanation %>%
    as.tibble() %>%
    dplyr::mutate(
      case    = as_factor(case),
      order_1 = rank(feature) 
    ) %>%
    dplyr::group_by(feature) %>%
    dplyr::mutate(
      order_2 = rank(feature_value)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      order = order_1 * 1000 + order_2
    ) %>%
    dplyr::mutate(
      feature_desc = as.factor(feature_desc) %>% 
        fct_reorder(order, .desc =  T) 
    ) %>%
    dplyr::select(case, feature_desc, feature_weight, label)
  
  data_transformed %>%
    ggplot(aes(case, feature_desc)) +
    geom_tile(aes(fill = feature_weight)) +
    facet_wrap(~ label) +
    #theme_tq() +
    scale_fill_gradient2(low = palette_light()[[2]], mid = "white",
                         high = palette_light()[[1]]) +
    theme(
      panel.grid = element_blank(),
      legend.position = "right",
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)
    ) +
    labs(y = "Feature", x = "Case", 
         fill = glue("Feature
                         Weight"))
  
}


plot_hist_facet <- function(data, fct_reorder = FALSE, fct_rev = FALSE, 
                            bins = 10, fill = palette_light()[[3]], color = "white", ncol = 5, scale = "free") {
  print("Function Sanity Check: Plot Histogram that is Faceted")
  data_factored <- data %>%
    mutate_if(is.character, as.factor) %>%
    mutate_if(is.factor, as.numeric) %>%
    tidyr::gather(key = key, value = value, factor_key = TRUE) 
  
  if (fct_reorder) {
    data_factored <- data_factored %>%
      mutate(key = as.character(key) %>% as.factor())
  }
  
  if (fct_rev) {
    data_factored <- data_factored %>%
      mutate(key = fct_rev(key))
  }
  
  g <- data_factored %>%
    ggplot(aes(x = value, group = key)) +
    geom_histogram(bins = bins, fill = fill, color = color) +
    facet_wrap(~ key, ncol = ncol, scale = scale) #+ 
    #theme_tq()
  
  return(g)
  
}


get_cor <- function(data, target, use = "pairwise.complete.obs",
                    fct_reorder = FALSE, fct_rev = FALSE) {
  print("Function Sanity Check: Get Correlation of Features")
  feature_expr <- enquo(target)
  feature_name <- quo_name(feature_expr)
  
  data_cor <- data %>%
    mutate_if(is.character, as.factor) %>%
    mutate_if(is.factor, as.numeric) %>%
    cor(use = use) %>%
    as.tibble() %>%
    mutate(feature = names(.)) %>%
    select(feature, !! feature_expr) %>%
    filter(!(feature == feature_name)) %>%
    mutate_if(is.character, as_factor)
  
  if (fct_reorder) {
    data_cor <- data_cor %>% 
      mutate(feature = fct_reorder(feature, !! feature_expr)) %>%
      arrange(feature)
  }
  
  if (fct_rev) {
    data_cor <- data_cor %>% 
      mutate(feature = fct_rev(feature)) %>%
      arrange(feature)
  }
  
  return(data_cor)
  
}

plot_cor <- function(data, target, fct_reorder = FALSE, fct_rev = FALSE, 
                     include_lbl = TRUE, lbl_precision = 2, lbl_position = "outward",
                     size = 2, line_size = 1, vert_size = 1, 
                     color_pos = palette_light()[[1]], color_neg = palette_light()[[2]]) {
  print("Function Sanity Check: Plot Correlation of Features")
  feature_expr <- enquo(target)
  feature_name <- quo_name(feature_expr)
  
  data_cor <- data %>%
    get_cor(!! feature_expr, fct_reorder = fct_reorder, fct_rev = fct_rev) %>%
    mutate(feature_name_text = round(!! feature_expr, lbl_precision)) %>%
    mutate(Correlation = case_when(
      (!! feature_expr) >= 0 ~ "Positive",
      TRUE                   ~ "Negative") %>% as.factor())
  
  g <- data_cor %>%
    ggplot(aes_string(x = feature_name, y = "feature", group = "feature")) +
    geom_point(aes(color = Correlation), size = size) +
    geom_segment(aes(xend = 0, yend = feature, color = Correlation), size = line_size) +
    geom_vline(xintercept = 0, color = palette_light()[[1]], size = vert_size) +
    expand_limits(x = c(-1, 1)) +
    #theme_tq() +
    scale_color_manual(values = c(color_neg, color_pos)) 
  
  if (include_lbl) g <- g + geom_label(aes(label = feature_name_text), hjust = lbl_position)
  
  return(g)
  
}


# ggpairs: A lot of repetitive typing can be reduced 
plot_ggpairs <- function(data, color = NULL, density_alpha = 0.5) {
  print("Function Sanity Check: Plot ggpairs")
  color_expr <- enquo(color)
  
  if (rlang::quo_is_null(color_expr)) {
    
    g <- data %>%
      ggpairs(lower = "blank") 
    
  } else {
    
    color_name <- quo_name(color_expr)
    
    g <- data %>%
      ggpairs(mapping = aes_string(color = color_name), 
              lower = "blank", legend = 1,
              diag = list(continuous = wrap("densityDiag", 
                                            alpha = density_alpha))) +
      theme(legend.position = "bottom")
  }
  
  return(g)
  
}


###Genetic algorithm

custom_fitness <- function(vars, data_x, data_y, p_sampling)
{
  # speeding up things with sampling
  ix=get_sample(data_x, percentage_tr_rows = p_sampling)
  data_2=data_x[ix,]
  data_y_smp=data_y[ix]
  
  # keep only vars from current solution
  names=colnames(data_2)
  names_2=names[vars==1]
  # get the columns of the current solution
  data_sol=data_2[, names_2]
  
  # get the roc value from the created model
  roc_value=get_roc_metric(data_sol, data_y_smp, names_2)
  
  # get the total number of vars for the current selection
  q_vars=sum(vars)
  
  # time for your magic
  fitness_value=roc_value/q_vars
  
  return(fitness_value)
}

get_roc_metric <- function(data_tr_sample, target, best_vars) 
{
  # data_tr_sample=data_sol
  # target = target_var_s
  # best_vars=names_2
  
  fitControl <- caret::trainControl(method = "cv", 
                                    number = 3, 
                                    summaryFunction = twoClassSummary,
                                    classProbs = TRUE)
  
  data_model=select(data_tr_sample, one_of(best_vars))
  
  mtry = sqrt(ncol(data_model))
  tunegrid = expand.grid(.mtry=round(mtry))
  
  fit_model_1 = caret::train(x=data_model, 
                             y= target, 
                             method = "rf", 
                             trControl = fitControl,
                             metric = "ROC",
                             tuneGrid=tunegrid
  )
  
  metric=fit_model_1$results["ROC"][1,1]
  
  return(metric)
}




get_accuracy_metric <- function(data_tr_sample, target, best_vars) 
{
  print("Function Sanity Check: Check Accuracy Metrics")
  data_model=select(data_tr_sample, one_of(best_vars))
  
  fitControl <- trainControl(method = "cv", 
                             number = 3, 
                             summaryFunction = twoClassSummary)
  
  data_model=select(data_tr_sample, one_of(best_vars))
  
  mtry = sqrt(ncol(data_model))
  tunegrid = expand.grid(mtry=round(mtry))
  
  fit_model_1 = caret::train(x=data_model, 
                             y= target, 
                             method = "rf",
                             tuneGrid = tunegrid)
  
  
  
  metric=fit_model_1$results["Accuracy"][1,1]
  return(metric)
}  

# https://github.com/tobiolatunji/Readmission_Prediction/blob/master/diabetes_readmission.R
# pseudo R-squared for logistic regression model
logisticPseudoR2s <- function(LogModel) {
  print("Function Sanity Check: Calculate a logistic PseudoR2s")
  dev <- LogModel$deviance 
  nullDev <- LogModel$null.deviance 
  modelN <-  length(LogModel$fitted.values)
  R.l <-  1 -  dev / nullDev
  R.cs <- 1- exp ( -(nullDev - dev) / modelN)
  R.n <- R.cs / ( 1 - ( exp (-(nullDev / modelN))))
  cat("Pseudo R^2 for logistic regression\n")
  cat("Hosmer and Lemeshow R^2  ", round(R.l, 3), "\n")
  cat("Cox and Snell R^2        ", round(R.cs, 3), "\n")
  cat("Nagelkerke R^2           ", round(R.n, 3),    "\n")
}


#Variable Importance Function
tm_vip <- function (object, title, ...) {
  print("Function Sanity Check: Variable Importance Function")
  vip <- vip::vip(object = object, 
                  bar = TRUE,
                  horizontal = TRUE,
                  shape = 1,
                  color = "grey35",
                  fill = "grey35",
                  all_permutations = TRUE,
                  num_features = 10L,
                  alpha = 1) +
    ggtitle(title)
  return(vip)
}

tm_ggsave <- function (object, filename, ...){  #make sure the file name has quotation marks around it.  
  print("Function Sanity Check: Saving a ggplot image as a TIFF")
  ggplot2::ggsave(here::here("results", filename), object, device = "tiff", width = 10, height = 7, dpi = 200)
}


tm_print_save <- function (filename) {
  print("Function Sanity Check: Saving TIFF of what is in the viewer")
  dev.print(tiff, (here::here("results", filename)), compression = "lzw",width=2000, height=2000, bg="transparent", res = 200, units = "px" )
  dev.off()
}

tm_write2pdf <- function(object, filename) {  
  #pass filename and title with quotations
  print("Function Sanity Check: Creating Arsenal Table as a PDF")
  arsenal::write2pdf(object, (here::here("tables", (paste0(filename, ".pdf")))),
                     keep.md = TRUE,
                     quiet = TRUE) # passed to rmarkdown::render
}


tm_write2word <- function(object, filename) {  
  #pass filename and title with quotations
  print("Function Sanity Check: Creating Arsenal Table as a Word Document")
  arsenal::write2word(object, (here::here("tables", (paste0(filename, ".doc")))),
                      keep.md = TRUE,
                      quiet = TRUE) # passed to rmarkdown::render
}

tm_t_test <- function(variable){
  print("Function Sanity Test: t-test")
  output <- stats::t.test(y=variable[train$Match_Status == "Matched"],
                          x=variable[train$Match_Status == "Did not match"],
                          alternative = ("two.sided"),
                          paired = FALSE,
                          conf.level = 0.95,
                          var.equal = TRUE)
  
  print("X is group that did not match and Y is group that did match:")
  return(output)
}


tm_chi_square_test <- function (variable) {
  print("Function Sanity Test: chi-square test")
  chisq <- stats::chisq.test(variable, train$Match_Status, correct = FALSE)
  return(chisq)
}


