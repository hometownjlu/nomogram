

#Load for TIDYMODELS version of modeling

#Load for TIDYMODELS version of modeling
gc()
#setwd("~/Dropbox/Nomogram/nomogram/")
source(file="~/Dropbox/Nomogram/nomogram/Code/Additional_functions_nomogram.R", echo=TRUE, verbose=TRUE)

library(h2o)
library(recipes)
library(readxl)
library(tidyverse)
library(tidyquant)
library(stringr)
library(forcats)
library(cowplot)
library(fs)
library(glue)
library(tidyverse)
library(magrittr)
library(tidymodels)

path_data_definitions <- "~/Downloads/telco_data_definitions.xlsx"
train_raw_tbl       <- train
test_raw_tbl        <- test
definitions_raw_tbl <- read_excel(path_data_definitions, sheet = 1, col_names = FALSE)

# Processing Pipeline
source("~/Dropbox/Nomogram/nomogram/00_Scripts/data_processing_pipeline.R")


#Split the data using `rsample`.  
# ------------------------------ Get data from source
set.seed(seed = 1978) 
all_data$Age <- as.numeric(all_data$Age)
all_data <- all_data 
data_split <- rsample::initial_split(data = all_data, # rsample::initial_split() For sampling
                                     strata = "Match_Status", 
                                     prop = 0.8)
data_split

train <- data_split %>% training() %>% glimpse()  # Extract the training dataframe
test  <- data_split %>% testing() %>% glimpse() # Extra


#https://university.business-science.io/courses/246843/lectures/5021219
#Is skew present
skewed_feature_names <- train %>%
  dplyr::select_if(is.numeric) %>%
  map_df(PerformanceAnalytics::skewness) %>% #returns a single row tibble 
  tidyr::gather(factor_key = TRUE) %>% #transposes into a long data column
  arrange(desc(value)) %>% #Look for low and high values, high values have a fat tail on right, low has fat tail on left side
  filter(value>2.0) %>% #eyeballed cutoff for value cut off
  pull(key) %>%
  as.character()

train %>%
  dplyr::select(skewed_feature_names) %>% #Look to make sure these variables are not factors
  #NB:  Skew is present in everything starting with count and age
  plot_hist_facet()

#Centering and Scaling ----
train %>%
  dplyr::select_if(is.numeric) %>%
  plot_hist_facet()  #Variables like age and Step 1 scores have different ranges.  Age has 25 to 60 years and Step 1 score has 180 to 280.  Algorithm needs all data on the same scale.  USMLE data would dominate Age because of different ranges.  
# SVMs require centered and scaled data

#--------------------------------------------------- Feature Analysis  -----------------------------------------------#
#Feature Analysis, https://ryjohnson09.netlify.com/post/caret-and-tidymodels/
#Graphing the Outcomes
all_data %>%
  count(Match_Status) %>% 
  ggplot(aes(Match_Status, n, fill = Match_Status)) + 
  geom_col(width = .5, show.legend = FALSE) + 
  scale_y_continuous(labels = scales::comma) +
  #scale_fill_manual(values = custom_palette[3:2]) +
  #custom_theme + 
  labs(
    x = NULL,
    y = NULL,
    title = "Distribution of cases"
  )

# Create vector of predictors by removing column 19 that is Match_Status
expl <- names(train_tbl)[-19]

# Loop vector with map, moved here so we don't have to deal with dummy variables
expl_plots_box <- map(expl, ~box_fun_plot(data = train_tbl, x = "Match_Status", y = .x) )
cowplot::plot_grid(plotlist = expl_plots_box)  #Must view with zoom function

# Loop vector with map
expl_plots_density <- map(expl, ~density_fun_plot(data = train_tbl, x = "Match_Status", y = .x) )
cowplot::plot_grid(plotlist = expl_plots_density) #Must view with zoom function

#--------------------------------------------------- Preprocessing  -----------------------------------------------#


# ML Preprocessing 

# --------------------------------------------------
#Recipe function - First, I create a recipe where I define the transformations I want to apply to my data. In this case I create a simple recipe to change all character variables to factors.
#https://ryjohnson09.netlify.com/post/caret-and-tidymodels/
#- tidymodels: https://github.com/tidymodels
#- recipes: https://tidymodels.github.io/recipes/


# --------------------------------------------------
#The order in which you infer, center, scale, etc does matter (see this post).  Artificial Neural Networks are best when the data is one-hot encoded, scaled and centered. In addition, other transformations may be beneficial as well to make relationships easier for the algorithm to identify.
#https://topepo.github.io/recipes/

# 1) Impute/Zero variance features that would add nothing to the data
# 2) Individual transformations for skewness and other issues -
# 3) Discretize (if needed and if you have no other choice)
# 4) Create dummy variables
# 5) Create interactions
# 6) Normalization steps (center, scale, range, etc)
# 7) Multivariate transformation (e.g. PCA, spatial sign, etc)


recipe_simple <- recipe(Match_Status ~ ., data = train) %>%     
  update_role(Match_Status, new_role = "outcome") %>%
  #Using the formula sets the predictors and the outcome
  recipes::step_zv(all_predictors()) #%>%  
  #removes zero variance functions where every value is the same for every observation
  #recipes::step_YeoJohnson(skewed_feature_names) #%>%  
# The data is transformed for skewness (Age, Count of poster presentations)
#step_center(all_numeric(), -all_outcomes()) %>%
# step_scale(all_numeric(), -all_outcomes())
# #center subtracts out the means for numerics
# recipes::step_dummy(all_nominal(), -all_outcomes()))
#Process of converting categorical data to sparse data, which has columns of only zeros and ones. (a.k.a. dummy variables or a design matrix.) All Non-Numeric Data need to be coverted to Dummy Variables].
#dummying fixes factors with skew
#Helps with factor variables

recipe_obj <- recipe_simple


#Prep and bake the data here.  

recipe_obj %>%  
  recipes::prep() %>%
  recipes::bake(new_data = train) %>%
  dplyr::select(skewed_feature_names)

prepared_object <- recipe_obj %>%  
  recipes::prep()  #Does calculations to ready the data

prepared_object$steps[[3]] #Shows all the means for centered data

prepared_object %>%
  bake(new_data = train) %>% #Can also do one hot encoding
  dplyr::select(contains("Gender")) %>%
  plot_hist_facet(ncol = 3)


train_tbl <- bake(prepared_object, new_data = train)
train_tbl %>% glimpse()  #This is a well formed machine readable data set


# --------------------Correlation ---------
args(get_cor)

train_tbl %>%
  get_cor(target = Match_Status, fct_reorder = TRUE, fct_rev = TRUE)

train_tbl %>%
  #select(Match_Status_Matched, contains("Count_of_")) %>%
  plot_cor(target = Match_Status, fct_reorder = TRUE, fct_rev = FALSE)


# Finally, let's load H2O and start up an H2O cluster
library(h2o)
h2o.init()
h2o.getVersion()
h2o.clusterIsUp()
h2o.getConnection()
h2o.clusterStatus()

h2o.no_progress()  # Turn off progress bars
h2o.removeAll() # Cleans h2o cluster state.


#Split the train_tbl into h2o training, grid search, and testing data sets.  
split_h2o <- h2o.splitFrame(as.h2o(train_tbl), ratios = c(0.85), seed = 1978)

train_h2o <- split_h2o[[1]]
valid_h2o <- split_h2o[[2]]
test_h2o  <- as.h2o(test)

y <- "Match_Status"
x <- setdiff(names(train_h2o), y)

# # #Models run for 10 hours on 11/25/2019.
automl_models_h2o <- h2o.automl(
  x = x,
  y = y,
  training_frame = train_h2o, #training data set
  validation_frame = valid_h2o, #grid tuning data set, done automatically by H2O.ai
  leaderboard_frame = test_h2o, #test data set
  max_runtime_secs = 30, #originally was 60 secs #36000
  nfolds = 10, #K-fold cross-validation: duplicate the train data into 10 sets.  9 of the 10 are used for training and 1 of the 10 is used for validation.  Different parameters are being evaluate but NOT using a different model.  AUC is generated to measure model effectiveness for each fold and mean is used.
  seed = 1978,
  stopping_metric = "AUC",
  verbosity = "info"
)


