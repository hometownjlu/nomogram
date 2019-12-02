

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

test_tbl <- bake(prepared_object, new_data = test)
test_tbl %>% glimpse()  #This is a well formed machine readable data set


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

# H2O MODELING -----
typeof(automl_models_h2o)

slotNames(automl_models_h2o)

automl_models_h2o@leaderboard

automl_models_h2o@leader

args(extract_h2o_model_name_by_position)
extract_h2o_model_name_by_position(automl_models_h2o@leaderboard, n=1, verbose = T)
extract_h2o_model_name_by_position(automl_models_h2o@leaderboard, n=3, verbose = T)
extract_h2o_model_name_by_position(automl_models_h2o@leaderboard, n=4, verbose = T)
extract_h2o_model_name_by_position(automl_models_h2o@leaderboard, n=5, verbose = T)

h2o.getModel("StackedEnsemble_BestOfFamily_AutoML_20191201_231543")
h2o.getModel("GLM_grid_1_AutoML_20191201_231543_model_1")
h2o.getModel("XGBoost_3_AutoML_20191201_231543")
h2o.getModel("GBM_1_AutoML_20191201_231543")


# Saving & Loading

h2o.getModel("StackedEnsemble_BestOfFamily_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2o_models/")

h2o.getModel("GLM_grid_1_AutoML_20191201_231543_model_1") %>%
  h2o.saveModel(path = "04_Modeling/h2o_models/")

h2o.getModel("XGBoost_3_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2o_models/")

h2o.getModel("GBM_1_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2omodels/")

h2o.getModel("DRF_1_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2omodels/")

h2o.getModel("GBM_2_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2omodels/")

# Making Predictions
stacked_ensemble_h2o <- h2o.loadModel("04_Modeling/h2o_models/StackedEnsemble_BestOfFamily_AutoML_20191201_231543")
stacked_ensemble_h2o

predictions <- h2o.predict(stacked_ensemble_h2o, newdata = as.h2o(test_tbl))
typeof(predictions)

predictions_tbl <- predictions %>% as.tibble()
predictions_tbl



# 3. Visualizing The Leaderboard ----
data_transformed <- automl_models_h2o@leaderboard %>% 
  as.tibble() %>%
  dplyr::mutate(model_type = str_split(model_id, "_", simplify = T)[,1]) %>%
  dplyr::slice(1:10) %>%
  rownames_to_column() %>%
  dplyr::mutate(
    model_id   = as_factor(model_id) %>% reorder(auc),
    model_type = as.factor(model_type)
  ) %>%
  tidyr::gather(key = key, value = value, -c(model_id, model_type, rowname), factor_key = T) %>%
  dplyr::mutate(model_id = paste0(rowname, ". ", model_id) %>% as_factor() %>% fct_rev()) 

data_transformed %>%
  ggplot(aes(value, model_id, color = model_type)) +
  geom_point(size = 3) +
  geom_label(aes(label = round(value, 2), hjust = "inward")) +
  facet_wrap(~ key, scales = "free_x") +
  #custom_theme () +
  #tidyquant::theme_tq() +
  tidyquant::scale_color_tq() +
  labs(title = "H2O Leaderboard Metrics",
       subtitle = paste0("Ordered by: auc"),
       y = "Model Postion, Model ID", x = "")




h2o_leaderboard <- automl_models_h2o@leaderboard
automl_models_h2o@leaderboard %>%
  plot_h2o_leaderboard(order_by = "logloss")



h2o.getModel("StackedEnsemble_BestOfFamily_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2o_models/")

h2o.getModel("GLM_grid_1_AutoML_20191201_231543_model_1") %>%
  h2o.saveModel(path = "04_Modeling/h2o_models/")

h2o.getModel("XGBoost_3_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2o_models/")

h2o.getModel("GBM_1_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2omodels/")

h2o.getModel("DRF_1_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2omodels/")

h2o.getModel("GBM_2_AutoML_20191201_231543") %>%
  h2o.saveModel(path = "04_Modeling/h2omodels/")

# 4. Assessing Performance ----
stacked_ensemble_h2o <- h2o.loadModel("04_Modeling/h2o_models/StackedEnsemble_BestOfFamily_AutoML_20191201_231543")

performance_h2o <- h2o.performance(stacked_ensemble_h2o, newdata = as.h2o(test_tbl))

typeof(performance_h2o)
performance_h2o %>% slotNames()

performance_h2o@metrics

# Classifier Summary Metrics

h2o.auc(performance_h2o, train = T, valid = T, xval = T)
h2o.giniCoef(performance_h2o)
h2o.logloss(performance_h2o)

h2o.confusionMatrix(stacked_ensemble_h2o)
h2o.confusionMatrix(performance_h2o)

# Precision vs Recall Plot

performance_tbl <- performance_h2o %>%
  h2o.metric() %>%
  as.tibble() 
performance_tbl

performance_tbl %>%
  filter(f1 == max(f1))

performance_tbl %>%
  ggplot(aes(x = threshold)) +
  geom_line(aes(y = precision), color = "blue", size = 1) +
  geom_line(aes(y = recall), color = "red", size = 1) +
  geom_vline(xintercept = h2o.find_threshold_by_max_metric(performance_h2o, "f1")) +
  #theme_tq() +
  labs(title = "Precision vs Recall", y = "value")


# ROC Plot
model_metrics_tbl <- fs::dir_info(path = "04_Modeling/h2o_models/") %>%
  dplyr::select(path) %>%
  dplyr::mutate(metrics = map(path, load_model_performance_metrics, test_tbl)) %>%
  unnest()

model_metrics_tbl %>%
  dplyr::mutate(
    path = str_split(path, pattern = "/", simplify = T)[,3] %>% as_factor(),
    auc  = auc %>% round(3) %>% as.character() %>% as_factor()
  ) %>%
  ggplot(aes(fpr, tpr, color = path, linetype = auc)) +
  geom_line(size = 1) +
  #theme_tq() +
  scale_color_tq() +
  theme(legend.direction = "vertical") +
  labs(
    title = "ROC Plot",
    subtitle = "Performance of 3 Top Performing Models"
  )

model_metrics_tbl <- fs::dir_info(path = "04_Modeling/h2o_models/") %>%
  dplyr::select(path) %>%
  dplyr::mutate(metrics = map(path, load_model_performance_metrics, test_tbl)) %>%
  tidyr::unnest()

model_metrics_tbl %>%
  dplyr::mutate(
    path = str_split(path, pattern = "/", simplify = T)[,3] %>% as_factor(),
    auc  = auc %>% round(3) %>% as.character() %>% as_factor()
  ) %>%
  ggplot(aes(recall, precision, color = path, linetype = auc)) +
  geom_line(size = 1) +
  #theme_tq() +
  scale_color_tq() +
  theme(legend.direction = "vertical") +
  labs(
    title = "Precision vs Recall Plot",
    subtitle = "Performance of 3 Top Performing Models"
  )

# Gain & Lift

ranked_predictions_tbl <- predictions_tbl %>%
  bind_cols(test_tbl) %>%
  dplyr::select(predict:Matched, Match_Status) %>%
  dplyr::arrange(desc(Matched))

calculated_gain_lift_tbl <- ranked_predictions_tbl %>%
  dplyr::mutate(ntile = ntile(Matched, n = 10)) %>%
  dplyr::group_by(ntile) %>%
  dplyr::summarise(
    cases = n(),
    responses = sum(Match_Status == "Matched")
  ) %>%
  dplyr::arrange(desc(ntile)) %>%
  dplyr::mutate(group = row_number()) %>%
  dplyr::select(group, cases, responses) %>%
  dplyr::mutate(
    cumulative_responses = cumsum(responses),
    pct_responses        = responses / sum(responses),
    gain                 = cumsum(pct_responses),
    cumulative_pct_cases = cumsum(cases) / sum(cases),
    lift                 = gain / cumulative_pct_cases,
    gain_baseline        = cumulative_pct_cases,
    lift_baseline        = gain_baseline / cumulative_pct_cases
  )

calculated_gain_lift_tbl 


gain_lift_tbl <- performance_h2o %>%
  h2o.gainsLift() %>%
  as.tibble()

gain_transformed_tbl <- gain_lift_tbl %>% 
  select(group, cumulative_data_fraction, cumulative_capture_rate, cumulative_lift) %>%
  select(-contains("lift")) %>%
  mutate(baseline = cumulative_data_fraction) %>%
  rename(gain = cumulative_capture_rate) %>%
  tidyr::gather(key = key, value = value, gain, baseline)

gain_transformed_tbl %>%
  ggplot(aes(x = cumulative_data_fraction, y = value, color = key)) +
  geom_line(size = 1.5) +
  #theme_tq() +
  scale_color_tq() +
  labs(
    title = "Gain Chart",
    x = "Cumulative Data Fraction",
    y = "Gain"
  )

lift_transformed_tbl <- gain_lift_tbl %>% 
  select(group, cumulative_data_fraction, cumulative_capture_rate, cumulative_lift) %>%
  select(-contains("capture")) %>%
  mutate(baseline = 1) %>%
  rename(lift = cumulative_lift) %>%
  tidyr::gather(key = key, value = value, lift, baseline)

lift_transformed_tbl %>%
  ggplot(aes(x = cumulative_data_fraction, y = value, color = key)) +
  geom_line(size = 1.5) +
  #theme_tq() +
  scale_color_tq() +
  labs(
    title = "Lift Chart",
    x = "Cumulative Data Fraction",
    y = "Lift"
  )


# 5. Performance Visualization ----  

h2o_leaderboard <- automl_models_h2o@leaderboard

automl_models_h2o@leaderboard %>%
  plot_h2o_performance(newdata = test_tbl, order_by = "auc", 
                       size = 1, max_models = 5)


automl_models_h2o@leaderboard %>%
  plot_h2o_performance(newdata = test_tbl, order_by = "logloss", 
                       size = 1, max_models = 3)



# 3. LIME ----

# 3.1 Making Predictions ----

automl_leader <- automl_models_h2o@leader
predictions_tbl <- automl_leader %>% 
  h2o.predict(newdata = as.h2o(test_tbl)) %>%
  as.tibble() %>%
  bind_cols(
    test_tbl %>%
      select(Match_Status, Age, USMLE_Step_1_Score, US_or_Canadian_Applicant)
  )
predictions_tbl


test_tbl %>%
  dplyr::slice(5) %>%
  glimpse()

# 3.2 Single Explanation ----

explainer <- train_tbl %>%
  select(-Match_Status) %>%
  lime(
    model           = automl_leader,
    bin_continuous  = TRUE,
    n_bins          = 4,
    quantile_bins   = TRUE
  )
explainer

explanation <- test_tbl %>%
  dplyr::slice(5) %>%
  select(-Match_Status) %>%
  lime::explain(
    explainer = explainer,
    n_labels   = 1,
    n_features = 8,
    n_permutations = 5000,
    kernel_width   = 1
  )

explanation %>%
  as.tibble() %>%
  dplyr::select(feature:prediction) 

plot_features(explanation = explanation, ncol = 1)


# 3.3 Multiple Explanations ----

explanation <- test_tbl %>%
  dplyr::slice(1:20) %>%
  dplyr::select(-Match_Status) %>%
  lime::explain(
    explainer = explainer,
    n_labels   = 1,
    n_features = 8,
    n_permutations = 5000,
    kernel_width   = 1
  )

explanation %>%
  as.tibble()


plot_features(explanation, ncol = 1)
plot_explanations(explanation)


# 4. Challenge Solutions ----

# 4.1 Recreating plot_features() -----

explanation %>%
  as.tibble()

case_1 <- explanation %>%
  dplyr::filter(case == 1)

case_1 %>%
  plot_features()


library(glue)

# Transformation
data_transformed <- case_1 %>%
  as.tibble() %>%
  dplyr::mutate(
    feature_desc = as_factor(feature_desc) %>% 
      fct_reorder(abs(feature_weight), .desc = FALSE),
    key     = ifelse(feature_weight > 0, "Supports", "Contradicts") %>% 
      fct_relevel("Supports"),
    case_text    = glue("Case: {case}"),
    label_text   = glue("Label: {label}"),
    prob_text    = glue("Probability: {round(label_prob, 2)}"),
    r2_text      = glue("Explanation Fit: {model_r2 %>% round(2)}")
  ) %>%
  dplyr::select(feature_desc, feature_weight, key, case_text:r2_text)

data_transformed


data_transformed %>%
  ggplot(aes(feature_desc, feature_weight, fill = key)) +
  geom_col() +
  coord_flip() +
  #theme_tq() +
  scale_fill_tq() +
  labs(y = "Weight", x = "Feature") +
  facet_wrap(~ case_text + label_text + prob_text + r2_text,
             ncol = 1, scales = "free")

explanation %>%
  dplyr::filter(case %in% 1) %>%
  plot_features_tq(ncol = 2)

explanation %>%
  filter(case %in% 1:6) %>%
  plot_features(ncol = 2)

# 4.2 Recreating plot_explanations ----
explanation %>%
  as.tibble()

plot_explanations(explanation)

data_transformed <- explanation %>%
  as.tibble() %>%
  dplyr::mutate(
    case    = as_factor(case),
    order_1 = rank(feature) 
  ) %>%
  # select(case, feature, feature_value, order_1) %>%
  # arrange(order_1)
  dplyr::group_by(feature) %>%
  dplyr::mutate(
    order_2 = rank(feature_value)
  ) %>%
  dplyr::ungroup() %>%
  # select(case, feature, feature_value, order_1, order_2) %>%
  # arrange(order_1, order_2)
  dplyr::mutate(
    order = order_1 * 1000 + order_2
  ) %>%
  # select(case, feature, feature_value, order_1, order_2, order) %>%
  # arrange(order)
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
  scale_fill_gradient2(low = palette_light()[[2]], 
                       mid = "white",
                       high = palette_light()[[1]]) +
  theme(
    panel.grid = element_blank(),
    legend.position = "right",
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)
  ) +
  labs(y = "Feature", x = "Case", 
       fill = glue("Feature
                    Weight"))

plot_explanations(explanation)

plot_explanations_tq(explanation)


