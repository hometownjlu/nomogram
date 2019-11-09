##A Tidy Approach to a Classification Problem
source(file="~/Dropbox/Nomogram/nomogram/Additional_functions_nomogram.R")

#https://www.benjaminsorensen.me/post/modeling-with-parsnip-and-tidymodels/
#https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/

#--------------------------------------------------- Splitting -----------------------------------------------#
#Tidymodels - Splitting data by proportion not by year.  
#Completing example from https://towardsdatascience.com/modelling-with-tidymodels-and-parsnip-bae2c01c131c
set.seed(seed = 1978) 
all_data$Age <- as.numeric(all_data$Age)
all_data <- all_data  %>% select(-Year)
data_split <- rsample::initial_split(data = all_data, 
                                     strata = "Match_Status", 
                                     prop = 0.8)
data_split

train_tbl <- data_split %>% training() %>% glimpse()
test_tbl  <- data_split %>% testing() %>% glimpse()


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
#1 - Recipe - Define a specification for preprocessing steps.  The recipe knows the structure of the data with columns and roles but not the actual data.  
#2 - Preparation - For a recipe with at least one preprocessing steps, estimate the required parameters from a training set that can be later applie to other data sets.  
#3 - Bake applies the recipe to the test set.  This is like running predict on a model.  
#https://www.youtube.com/watch?v=VYCZFKlUaq4&feature=share
#https://ryjohnson09.netlify.com/post/caret-and-tidymodels/

recipe_simple <- recipe_simple(dataset = train_tbl)


#--------------------------------------------------- Preparing the recipe  -----------------------------------------------#
recipe_prepped <- prep(recipe_simple)  #Data brought in with the recipe_simple step above for ease.  


#--------------------------------------------------- Bake  -----------------------------------------------#
#I “bake the recipe” to apply all preprocessing to the data sets.
train_baked <- bake(recipe_prepped, new_data = train_tbl)
test_baked  <- bake(recipe_prepped, new_data = test_tbl)

#--------------------------------------------------- Create Models  -----------------------------------------------#
# 1) Pick the model you want
# 2) set the type of model you want to fit (here is a logistic regression) and its mode (classification)
# 3) decide which computational engine to use (glm in this case)
# 4) spell out the exact model specification to fit (I’m using all variables here) and what data to use (the baked train dataset)
# classification models in parsnip: boost_tree(), decision_tree(), logistic_reg(), mars(), mlp(), multinom_reg(), nearest_neighbor(), null_model(), rand_forest(), svm_poly(), svm_rbf()

args(boost_tree)
model_boost_trees <- 
  parsnip::boost_tree(mode = "classification", trees = 2000, mtry = floor(.preds() * 0.75), min_n = 2, tree_depth = 6, learn_rate = 0.35, loss_reduction = 0.0001) %>%
  parsnip::set_engine("xgboost", seed = 1978) %>%
  parsnip::fit(Match_Status ~ ., data= train_baked)
model_boost_trees

# Explanation
model_boost_trees$fit %>%
  xgb.importance(model = .) %>%
  xgb.plot.importance(main = "XGBoost Feature Importance")


args(decision_tree)
set.seed(1978)
decision_tree <- 
  parsnip::decision_tree(mode = "classification", cost_complexity = varying(), min_n = 20, tree_depth = 6) %>%
  parsnip::set_engine("rpart") %>%   #Explain what model we want
  parsnip::set_args(cost_complexity = 0.01) %>%  #Can tinker with this variable  
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
decision_tree

decision_tree$fit%>%
  rpart.plot(
    yesno = 2, type = 5, extra = +100, fallen.leaves = TRUE, varlen = 0, faclen = 0, roundint = TRUE, clip.facs = TRUE, shadow.col = "gray", main = "Tree Model of Medical Students Matching into OBGYN Residency\n(Matched or Unmatched)", box.palette = c("red", "green"))  



args(logistic_reg)  #Check what parameters exist with the model you want to use.  
set.seed(1978)
logistic_glm <-
  parsnip::logistic_reg(mode = "classification", penalty = 0) %>%   #Regression vs. classification
  parsnip::set_engine("glm") %>%   #Explain what machine learning tool we want
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the parsnip::fit() function is used. 
logistic_glm


args(rand_forest)
random_forest <-
  parsnip::rand_forest(mtry = floor(.preds() * 0.75), mode = "classification", trees = 2000, min_n = 3) %>%   
  parsnip::set_engine("randomForest", seed = 1978) %>%   #Explain what model we want
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
random_forest






args(svm_poly)
svm <-
  parsnip::svm_poly(mode = "classification") %>%
  parsnip::set_engine("kernlab") %>%
  parsnip::fit(Match_Status ~ ., data = train_baked)
svm

args(mars)
mars <- 
  parsnip::mars(mode = "classification") %>%
  parsnip::set_engine("earth") %>%
  parsnip::fit(Match_Status ~ ., data=train_baked)
mars

#--------------------------------------------------- Predict  -----------------------------------------------#
# parsnip models always return the results as a data frame.  
predictions_glm <- logistic_glm %>%
  stats::predict(new_data = test_baked) %>%
  bind_cols(test_baked %>% select(Match_Status))


#--------------------------------------------------- Predict  -----------------------------------------------#
# When truth is a factor like Match_Status there are rows for accuracy.
predictions_glm %>%
  yardstick::conf_mat(Match_Status, .pred_class) %>%
  purrr::pluck(1) %>%
  tibble::as_tibble() %>%
  ggplot2::ggplot(aes(Prediction, Truth, alpha = n)) +
  ggplot2::geom_tile(show.legend = FALSE) +
  ggplot2::geom_text(aes(label = n), colour = "white", alpha = 1, size = 8) +
  labs(
    title = "Confusion matrix using glm model"
  )

#Accuracy
predictions_glm %>%
  yardstick::metrics(Match_Status, .pred_class) %>%  #Use the metrics() function to measure the performance of the model. It will automatically choose metrics appropriate for a given type of model. The function expects a tibble that contains the actual results (truth) and what the model predicted (estimate).
  select(-.estimator) %>%
  filter(.metric == "accuracy") 

#PRecision and recall
tibble(
  "precision" = 
    yardstick::precision(predictions_glm, Match_Status, .pred_class) %>%
    select(.estimate),
  "recall" = 
    yardstick::recall(predictions_glm, Match_Status, .pred_class) %>%
    select(.estimate)
) %>%
  unnest() 

#F measure
predictions_glm %>%
  f_meas(Match_Status, .pred_class) %>%
  dplyr::select(-.estimator)



# Let's do some RF Cross-validation
set.seed(1978)
# Create a 5 fold cross validation dat set
cv_splits <- rsample::vfold_cv(train_tbl, 
                                   v = 10,
                                   strata = "Match_Status")
cv_splits
cv_splits$splits[[1]]  #Let’s look a the first fold just to see how the data will be split
cv_splits$splits[[1]] %>% analysis() %>% dim()  # This will extract the 4/5ths analysis data part

cv_splits$splits[[1]] %>% assessment() %>% dim() # This will extract the 1/5th assessment data part

#Now I need to create a function that contains my model that can be iterated over each split of the data. I also want a function that will make predictions using said model.

# Make prediction
spec_rf <- parsnip::rand_forest(mtry = 5, mode = "classification", trees = 2000, min_n = 3) %>% 
  set_engine("ranger", seed = 1978)

cv_splits <- cv_splits %>% 
  mutate(models_rf = purrr::map(.x = splits, .f = fit_mod_func, spec = spec_rf))
cv_splits
cv_splits$models_rf[[1]]  #Inspect each model.    

cv_splits <- cv_splits %>% #add a column that contains the predictions
  mutate(pred_rf = map2(.x = splits, .y = models_rf, .f = predict_func))
cv_splits


perf_metrics <- yardstick::metric_set(accuracy) # Will calculate accuracy of classification

cv_splits <- cv_splits %>% 
  mutate(perf_rf = map(pred_rf, rf_metrics))


#Update the recipe to be used in RANDOM FOREST with dummy variables and centered and scaled data   
recipe_rf <- function(dataset) {
  recipe(Match_Status ~ ., data = dataset) %>%
    step_dummy(all_nominal(), -all_outcomes()) %>%
    step_center(all_numeric()) %>%
    step_scale(all_numeric()) %>%
    prep(data = dataset)
}

recipe_rf(dataset = train_tbl)


rf_fun <- function(split, try, tree) {   #Needed the original data object data_split  #removed id field
  analysis_set <- split %>% analysis()
  analysis_prepped <- analysis_set %>% recipe_rf()
  analysis_baked <- analysis_prepped %>% bake(new_data = analysis_set)
  model_rf <-
    rand_forest(
      mode = "classification",
      mtry = try,
      trees = tree
    ) %>%
    set_engine("ranger", seed = 1978,
               importance = "impurity"
    ) %>%
    fit(Match_Status ~ ., data = analysis_baked)
  assessment_set <- split %>% assessment()
  assessment_prepped <- assessment_set %>% recipe_rf()
  assessment_baked <- assessment_prepped %>% bake(new_data = assessment_set)
  tibble(
    #"id" = id,
    "truth" = assessment_baked$Match_Status,
    "prediction" = model_rf %>%
      predict(new_data = assessment_baked) %>%
      unlist())
}

rf_fun(split = data_split, try = 5, tree = 500)

pred_rf <- map2_df(
  .x = cross_val_tbl$splits,
  .y = cross_val_tbl$id,
  ~ rf_fun(split = .x, try = 3, tree = 200)  #removed y = .id
)
head(pred_rf)

pred_rf %>%
  conf_mat(truth, prediction) %>%
  summary() %>%
  select(-.estimator) #%>%
  #filter(.metric %in%
  #         c("accuracy", "precision", "recall", "f_meas")) 






#Recipes handles the pre-processing. Given a sample of training data, you first specify a model formula using add_role() (or the traditional y ~ x notation). Once roles are assigned, variables can be referenced with dplyr-like helper functions such as all_predictors() or all_nominal() — this comes in handy for the processing steps that follow.

#The various step_ functions allow for easy rescaling and transformation, but more importantly they allow you to specify a routine that will consistently reshape all the data you’re feeding into your model. 

# Pre-processing
credit_rec <- 
  train %>%
  recipe(Match_Status ~ .) %>%
  add_role(Match_Status, new_role = "outcome") %>% 
  add_role(starts_with("Count_of_"), new_role = "predictor") %>% 
  add_role(white_non_white, Age, Gender, Couples_Match, US_or_Canadian_Applicant, Medical_Education_Interrupted, Alpha_Omega_Alpha, Military_Service_Obligation, USMLE_Step_1_Score, Visa_Sponsorship_Needed, Medical_Degree, new_role = "predictor") %>% 
  step_dummy(all_nominal(), -Match_Status) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep(training = train, retain = TRUE)  # Prep step included here.  Once we’ve created a recipe() object, the next step is to prep() it. In the baking analogy, the recipe we created is simply a specification for how we want to process our data, and prepping is the process of getting our ingredients and tools in order so that we can bake it. We specify retain = TRUE in the prepping process if we want to hold onto the recipe’s initial training data for later.


#Now that we have a recipe and a prepped object, we’re ready to start baking. The bake() function allows us to apply a prepped recipe to new data, which will be processed according to our exact specifications. The juice() function is essentially a shortcut for bake() that’s useful when we want to process and output the training data used to originally specify the recipe (with retain = TRUE during prepping).
train <- 
  credit_rec %>% 
  juice()

test <- 
  credit_rec %>% 
  bake(new_data = test)

#Random Forest Model
## Model specification
rf_mod <- 
  rand_forest(
    mode = "classification",
    trees = 200
  )

## Fitting
rf_fit <- 
  fit(
    object = rf_mod,
    formula = formula(credit_rec),
    data = train,
    set_engine = "ranger", seed = 1978
  )

## Predict using the random forest model above on new data 
predictions_rf_fit <- rf_fit %>%
  predict(new_data = test) %>%
  bind_cols(test %>% select(Match_Status))

#Measuring Model PErformance
predictions_rf_fit %>%
  conf_mat(Match_Status, .pred_class) %>%
  pluck(1) %>%
  as_tibble() %>%
  ggplot(aes(Prediction, Truth, alpha = n)) +  #Not plotting
  geom_tile(show.legend = FALSE) +
  geom_text(aes(label = n), colour = "white", alpha = 1, size = 8)

# Accuracy - The model’s Accuracy is the fraction of predictions the model got right and can be easily calculated by passing the predictions_rf to the metrics function. However, accuracy is not a very reliable metric as it will provide misleading results if the data set is unbalanced.

predictions_rf_fit %>%
  metrics(Match_Status, .pred_class) %>%
  select(-.estimator) %>%
  filter(.metric == "accuracy") 

#Precision shows how sensitive models are to False Positives (i.e. predicting a customer is leaving when he-she is actually staying) whereas Recall looks at how sensitive models are to False Negatives (i.e. forecasting that a customer is staying whilst he-she is in fact leaving).

tibble( 
  "precision" = 
    precision(predictions_rf_fit, Match_Status, .pred_class) %>%  
    select(.estimate),
  "recall" = 
    recall(predictions_rf_fit, Match_Status, .pred_class) %>%
    select(.estimate)
) %>%
  unnest() 

predictions_rf_fit %>%
  f_meas(Match_Status, .pred_class) %>%
  select(-.estimator) 

#Cross-validation - To further refine the model’s predictive power, I am implementing a 10-fold cross validation using vfold_cv from rsample, which splits again the initial training data.
cross_val_tbl <- rsample::vfold_cv(train, v = 10)

cross_val_tbl$splits %>%
  pluck(1)



## Predicting!
results <-
  tibble(
    actual = test$Match_Status,
    predicted = predict_class(rf_fit, test)
  )



## Assessment -- test error
metrics(results, truth = actual, estimate = predicted) %>% 
  knitr::kable()


conf_mat(results, truth = actual, estimate = predicted)[[1]] %>% 
  as_tibble() %>% 
  ggplot(aes(Prediction, Truth, alpha = n)) + 
  geom_tile(fill = custom_palette[4], show.legend = FALSE) +
  geom_text(aes(label = n), color = "white", alpha = 1, size = 8) +
  custom_theme +
  labs(
    title = "Confusion matrix"
  )






--------------------------------------------------------------------------------------
test_normalized <- bake(credit_rec, new_data = test, all_predictors())

set.seed(1978)
nnet_fit <-
  mlp(epochs = 100, hidden_units = 5, dropout = 0.1) %>%
  set_mode("classification") %>% 
  # Also set engine-specific arguments: 
  set_engine("keras", verbose = 0, validation_split = .20, seed = 1978) %>%
  fit(Match_Status ~ ., data = juice(credit_rec))

nnet_fit

test_results <- 
  test %>%
  select(Match_Status) %>%
  as_tibble() %>%
  mutate(
    nnet_class = predict(nnet_fit, new_data = test_normalized) %>% 
      pull(.pred_class),
    nnet_prob  = predict(nnet_fit, new_data = test_normalized, type = "prob") %>% 
      pull(.pred_Matched)
  )

test_results %>% roc_auc(truth = Match_Status, nnet_prob)

test_results %>% accuracy(truth = Match_Status, nnet_class)
test_results %>% conf_mat(truth = Match_Status, nnet_class)



#Another example, https://tidymodels.github.io/parsnip/articles/articles/Regression.html
#LASSO
train <- filter(all_data, Year %in% c("2015", "2016"))  #Train on years 2015, 2016
nrow(train) 
test <- filter(all_data, Year %in%  c("2017", "2018")) #Test on 2017, 2018 data
nrow(test)
test <- test %>% select(-"Year")
train <- train %>% select(-"Year")

train$Age <- round(train$Age, digits=2)

norm_recipe <- 
  recipe(
    Match_Status ~ ., 
    data = train) %>%
  step_dummy(all_nominal()) %>%
  step_center(all_predictors()) %>%
  step_center(Age) %>%
  step_scale(all_predictors()) %>%
  # estimate the means and standard deviations
  prep(training = train, retain = TRUE)

# Now let's fit the model using the processed version of the data

glmn_fit <- 
  logistic_reg(penalty = 0.001, mixture = 0.5) %>% 
  set_engine("glmnet", seed = 1978) %>%
  fit(Match_Status ~ ., data = train)
glmn_fit


# First, get the processed version of the test set predictors:
test_normalized <- bake(norm_recipe, new_data = ames_test, all_predictors())

test_results <- 
  test_results %>%
  rename(`random forest` = .pred) %>%
  bind_cols(
    predict(glmn_fit, new_data = test_normalized) %>%
      rename(glmnet = .pred)
  )
test_results

test_results %>% metrics(truth = Sale_Price, estimate = glmnet) 


test_results %>% 
  gather(model, prediction, -Sale_Price) %>% 
  ggplot(aes(x = prediction, y = Sale_Price)) + 
  geom_abline(col = "green", lty = 2) + 
  geom_point(alpha = .4) + 
  facet_wrap(~model) + 
  coord_fixed()

#youtube.com data preprocessing using recipes
#Original usage of lm model
install.packages("AmesHousing")
library(AmesHousing)
ames <- make_ames()
levels(ames$Alley)
modl <- lm(log(Sale_Price) ~ Alley + Lot_Area, data = ames, subset = Year_Sold > 2000)

#recipes() is a specification of intent
#prepare() is estimation to prepare the data
#back() and juice() is equivalent to apply, juice()

library (recipes)
library(tidyverse)
library(rsample)

ames_train <- filter(all_data, Year %in% c("2015", "2016"))  #Train on years 2015, 2016
nrow(train) 
ames_test <- filter(all_data, Year %in%  c("2017", "2018")) #Test on 2017, 2018 data
nrow(test)
test <- test %>% select(-"Year")
train <- train %>% select(-"Year")


set.seed(4595)
# data_split <- initial_split(ames, prop = 3/4)
# ames_train <- training(data_split)
# ames_test <- testing(data_split)

rec <- recipe(Match_Status ~ ., data = ames_train) %>% 
  #step_log(starts_with ("Count_of_")) %>%
  #step_log(Age) %>%
  step_log(all_numeric()) %>%
  step_dummy(all_nominal())

#Retain = TRUE keeps the processed training set that is created during the estimation phase
rec_trained <- prep(rec, training = ames_train, retain=TRUE, verbose = TRUE) #%>%
  #step_center(all_numeric()) %>%
  #step_scale(all_numeric())

# Get the processed training set:
design_mat <- juice(rec_trained)

#Apply to other data sets:
rec_test <- bake (rec_trained, new_data = ames_test)

library(sparklyr)
rf_3 <- ml_random_forest(
  dat, 
  intercept = FALSE, 
  response = "y", 
  features = names(dat)[names(dat) != "y"], 
  col.sample.rate = 12,
  num.trees = 2000
)

#https://towardsdatascience.com/modelling-with-tidymodels-and-parsnip-bae2c01c131c


# https://github.com/tidymodels/parsnip/issues/152
suppressPackageStartupMessages({
  library("yardstick")
  library("parsnip")
  library("dials")
  library("recipes")
  library("rsample")
  library("readr")
  library("ggplot2")
  library("dplyr")
  library("purrr")
  library("mice")
})

titanic <- all_data

# splits
train_test_split <- initial_split(titanic, prop = 0.9)
titanic_train <- training(train_test_split)
titanic_test <- testing(train_test_split)

# Don't dummy the outcome!
rec <- recipe(Match_Status ~ ., data = titanic_train) %>%
  step_dummy(all_nominal(), -Match_Status)

# Prep ONLY on the training data
# Use juice() to extract the prepped training data
# Use bake() on the test data, but with the prepped recipe from the training data
prepped_rec <- prep(rec, titanic_train)
train_data <- juice(prepped_rec)
test_data <- bake(prepped_rec, new_data = titanic_test)

# We can now try basic logistic regression
logistic_regression <- logistic_reg() %>% 
  set_engine("glm", seed = 1978) %>% 
  fit(Match_Status ~ ., data = train_data)

predict(logistic_regression, new_data = test_data)
predict(logistic_regression, new_data = test_data, type = "prob")




### Random Forest

rf_with_seed <- 
  rand_forest(trees = 2000, mode = "classification") %>%
  set_args(mtry = 5) %>% 
  set_engine("randomForest", seed = 1978) %>%
  fit(Match_Status ~ ., data = train)
rf_with_seed



#####################################################################
# https://www.alexpghayes.com/blog/implementing-the-super-learner-with-tidymodels/

prediction_train <- predict(limited.vif.model.kitchen.sink, newdata = train, 
                            type = "response")




# Estimate the stepwise matching probability
prediction_test <- predict.lm(lm.fit2, newdata = test, 
                              type = "response")
back_step_prob <- predict(back_step_model, type = "response")
solution_tree <- predict(t.model, newdata = test, type="class") 
solution_tree <- predict(pruned.t.model, newdata = test, type = "class")
solution_rf <- predict(caret_matrix, newdata = test, type = "raw")
solution_boost <- predict(caret_boost, newdata = test, type = "raw")

