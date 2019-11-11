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
#Recipes handles the pre-processing. Given a sample of training data, you first specify a model formula using add_role() (or the traditional y ~ x notation). Once roles are assigned, variables can be referenced with dplyr-like helper functions such as all_predictors() or all_nominal() — this comes in handy for the processing steps that follow.

#The various step_ functions allow for easy rescaling and transformation, but more importantly they allow you to specify a routine that will consistently reshape all the data you’re feeding into your model. 

#1 - Recipe - Define a specification for preprocessing steps.  The recipe knows the structure of the data with columns and roles but not the actual data.  
#2 - Preparation - For a recipe with at least one preprocessing steps, estimate the required parameters from a training set that can be later applie to other data sets.  
#3 - Bake applies the recipe to the test set.  This is like running predict on a model.  
#https://www.youtube.com/watch?v=VYCZFKlUaq4&feature=share
#https://ryjohnson09.netlify.com/post/caret-and-tidymodels/

recipe <- recipe_simple(dataset = train_tbl)


#--------------------------------------------------- Preparing the recipe  -----------------------------------------------#
## Prep step included here.  Once we’ve created a recipe() object, the next step is to prep() it. In the baking analogy, the recipe we created is simply a specification for how we want to process our data, and prepping is the process of getting our ingredients and tools in order so that we can bake it. We specify retain = TRUE in the prepping process if we want to hold onto the recipe’s initial training data for later.

recipe_prepped <- recipes::prep(x = recipe, training = train_tbl, retain=TRUE)   #Data brought in with the recipe_simple step above for ease.  
recipe_prepped
recipe_prepped %>% recipes::juice(composition = "tibble")

#--------------------------------------------------- Bake  -----------------------------------------------#
#I “bake the recipe” to apply all preprocessing to the data sets. #Now that we have a recipe and a prepped object, we’re ready to start baking. The bake() function allows us to apply a prepped recipe to new data, which will be processed according to our exact specifications. The juice() function is essentially a shortcut for bake() that’s useful when we want to process and output the training data used to originally specify the recipe (with retain = TRUE during prepping).
train_baked <- bake(recipe_prepped, new_data = train_tbl)
test_baked  <- bake(recipe_prepped, new_data = test_tbl)

#--------------------------------------------------- Create Models  -----------------------------------------------#
# 1) Pick the model you want
# 2) set the type of model you want to fit (here is a logistic regression) and its mode (classification)
# 3) decide which computational engine to use (glm in this case but I do have tensorflow set up)
# 4) spell out the exact model specification to fit (I’m using all variables here) and what data to use (the baked train dataset)
# classification models in parsnip: boost_tree(), decision_tree(), logistic_reg(), mars(), mlp(), multinom_reg(), nearest_neighbor(), null_model(), rand_forest(), svm_poly(), svm_rbf()

#--------------------------------------------------- Model: xgBoost  -----------------------------------------------#
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

#--------------------------------------------------- Model: Decision Tree  -----------------------------------------------#
args(decision_tree)
set.seed(1978)
decision_tree <- 
  parsnip::decision_tree(mode = "classification", cost_complexity = varying(), min_n = 20, tree_depth = 6) %>%
  #set_engine("C5.0") %>%
  parsnip::set_engine("rpart") %>%   #Explain what model we want
  parsnip::set_args(cost_complexity = 0.01) %>%  #Can tinker with this variable  
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
decision_tree

decision_tree$fit%>%
  rpart.plot(
    yesno = 2, type = 5, extra = +100, fallen.leaves = TRUE, varlen = 0, faclen = 0, roundint = FALSE, clip.facs = TRUE, shadow.col = "gray", main = "Tree Model of Medical Students Matching into OBGYN Residency\n(Matched or Unmatched)", box.palette = c("red", "green"))  


#--------------------------------------------- Model: Logistic Regression  -----------------------------------------------#
args(logistic_reg)  #Check what parameters exist with the model you want to use.  
set.seed(1978)
logistic_glm <-
  parsnip::logistic_reg(mode = "classification", penalty = 0) %>%   #Regression vs. classification
  parsnip::set_engine("glm") %>%   #Explain what machine learning tool we want
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the parsnip::fit() function is used. 
logistic_glm


#--------------------------------------------------- Model: Random Forest  -----------------------------------------------#
args(rand_forest)
random_forest <-
  parsnip::rand_forest(mtry = floor(.preds() * 0.75), mode = "classification", trees = 2000, min_n = 3) %>%   
  parsnip::set_engine("randomForest", seed = 1978) %>%   #Explain what model we want
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
random_forest


#https://cdn.rawgit.com/ClaytonJY/tidymodels-talk/145e6574/slides.html#64
#Training error
set.seed(1978)
rset <- rsample::vfold_cv(data = train_baked, v = 10, repeats = 1, strata = Match_Status) #V-fold cross-validation, creates folds
rset
rset$splits[[1]]
analysis(rset$splits[[1]]) # Anatomy of a split
assessment(rset$splits[[1]])  # test
rset$recipes <- map(rset$splits, prepper, recipe = recipe, retain = TRUE)
rset
rset$models <- map(rset$recipes, ~ranger(formula = formula(.x), juice(.x)))
rset

predict_rf <- function(split, rec, model) {
  test <- bake(rec, assessment(split))
  tibble(
    actual    = test_tbl$Match_Status,
    predicted = predict(model, test)$predictions
  )
}
rset <- rset %>%
  mutate(
    predictions = pmap(list(splits, recipes, models), predict_rf),
    metrics     = map(predictions, metrics, actual, predicted)
  )
  
#--------------------------------------------------- Model: Random Forest  -----------------------------------------------#
args(rand_forest)
ranger_random_forest <-
  parsnip::rand_forest(mtry = floor(.preds() * 0.75), mode = "classification", trees = 2000, min_n = 3) %>%   
  parsnip::set_engine("ranger", seed = 1978) %>%   #Explain what model we want
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
ranger_random_forest


#----------------------------------------- Model: Support Vector Machines  -----------------------------------------------#
args(svm_poly)
svm <-
  parsnip::svm_poly(mode = "classification") %>%
  parsnip::set_engine("kernlab") %>%
  parsnip::fit(Match_Status ~ ., data = train_baked)
svm

#--------------------------------------------------- Model: MARS  -----------------------------------------------#
args(mars)
mars <- 
  parsnip::mars(mode = "classification") %>%
  parsnip::set_engine("earth") %>%
  parsnip::fit(Match_Status ~ ., data=train_baked)
mars


#--------------------------------------------------- Model: glmnet  -----------------------------------------------#
args(multinom_reg)
set.seed(1978)
glmn_fit <- 
  parsnip::multinom_reg(penalty = 0.01, mixture = 0.5, mode = "classification") %>% 
  parsnip::set_engine("glmnet") %>%
  parsnip::fit(Match_Status ~ ., data=train_baked) 
glmn_fit

#--------------------------------------------------- Model: Single Layer Neural Network  ----------------------------#
args(mlp)
mlp <- 
  parsnip::mlp(mode = "classification", hidden_units = 5, penalty = 0.01, dropout = 0, epochs = 20, activation = NULL) %>%
  parsnip::set_engine("nnet", seed = 1978) %>%
  parsnip::fit(Match_Status ~ ., data=train_baked) 
mlp

#--------------------------------------------------- Model: General Interface for K-Nearest Neighbor Models -------------#
args(nearest_neighbor)
set.seed(1978)
nearest_neighbor <- 
  parsnip::nearest_neighbor(mode = "classification", neighbors = 5) %>%
  parsnip::set_engine("kknn") %>%
  parsnip::fit(Match_Status ~ ., data=train_baked) 
nearest_neighbor

#--------------------------------------------------- Model: Naive Bayes------------------------------------ -------------#
args(naive_Bayes)  #https://tidymodels.github.io/discrim/reference/index.html
set.seed(1978)
naive_Bayes <- 
  naive_Bayes(mode = "classification") %>%
  parsnip::set_engine("klaR") %>%
  parsnip::fit(Match_Status ~ ., data=train_baked) 
naive_Bayes

tibble_of_model_names <- as_tibble(c("model_boost_trees", "decision_tree", "logistic_reg", "rand_forest", "ranger_random_forest","svm", "mars", "multinom_reg", "mlp", "nearest_neighbor", "naive_Bayes"))
#--------------------------------------------------- Predict on new data -----------------------------------------------#
# parsnip models always return the results as a data frame.  
# Accuracy - The model’s Accuracy is the fraction of predictions the model got right and can be easily calculated by passing the predictions_rf to the metrics function. However, accuracy is not a very reliable metric as it will provide misleading results if the data set is unbalanced.
#https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/

#Per classifier metrics - It is easy to obtain the probability for each possible predicted value by setting the type argument to prob. That will return a tibble with as many variables as there are possible predicted values. Their name will default to the original value name, prefixed with .pred_.

#Model validation
tm_model_metrics <- random_forest %>%  #Plug in the model using the training data
  stats::predict(new_data = test_baked) %>%  #Predict the test_data with the new model
  bind_cols(test_baked) %>%
  yardstick::metrics(truth = Match_Status, estimate = .pred_class) %>%
  select(-.estimator) 
tm_model_metrics

#Measuring Model Performance
confusion_matrix_graph <- random_forest %>%  #Plug in the model using the training data
  stats::predict(new_data = test_baked) %>%  #Predict the test_data with the new model
  bind_cols(test_baked) %>%
  conf_mat(Match_Status, .pred_class) %>%
  purrr::pluck(1) %>%
  tibble::as_tibble() %>%
  ggplot2::ggplot(aes(Prediction, Truth, alpha = n)) +  #Not plotting
  ggplot2::geom_tile(show.legend = FALSE) +
  ggplot2::geom_text(aes(label = n), colour = "white", alpha = 1, size = 8) +
  labs(
    title = "Confusion matrix using randomForest model"
  )
plot(confusion_matrix_graph)



# Estimate the stepwise matching probability
prediction_test <- predict.lm(lm.fit2, newdata = test, 
                              type = "response")
back_step_prob <- predict(back_step_model, type = "response")
solution_tree <- predict(t.model, newdata = test, type="class") 
solution_tree <- predict(pruned.t.model, newdata = test, type = "class")
solution_rf <- predict(caret_matrix, newdata = test, type = "raw")
solution_boost <- predict(caret_boost, newdata = test, type = "raw")

# Training set performance summary
x <- caret::postResample(pred = .pred_class, obs = as.factor(train$Match_Status))

#https://tidymodels.github.io/rsample/articles/Working_with_rsets.html
#Cross-validation - To further refine the model’s predictive power, I am implementing a 10-fold cross validation using vfold_cv from rsample, which splits again the initial training data.

set.seed(1978)
# First, let’s make the splits of the data:
rs_obj <- rsample::vfold_cv(train_tbl, 
                                   v = 10, repeats = 10, 
                                   strata = "Match_Status")

#Now let’s write a function (tm_holdout_results) that will, for each resample:obtain the analysis data set (i.e. the 90% used for modeling)fit a logistic regression model predict the assessment data (the other 10% not used for the model) using the broom package determine if each sample was predicted correctly.
## splits will be the `rsplit` object with the 90/10 partition

#Example of how splits will be handled.  
example <- tm_holdout_results(rs_obj$splits[[1]],  Match_Status ~ .)  #Use function called tm_holdout_results
dim(example)
dim(assessment(rs_obj$splits[[1]]))
example[1:10, setdiff(names(example), names(attrition))]

#Handle all split data at once with map.  
rs_obj$results <- purrr::map(rs_obj$splits,  #Applies the function against all the splits
                             tm_holdout_results,
                             Match_Status ~ .)
rs_obj

rs_obj$accuracy <- map_dbl(rs_obj$results, function(x) mean(x$correct)) #Now we can compute the accuracy values for all of the assessment data sets
summary(rs_obj$accuracy)


--------------------------------------------------------------------------------------
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
  set_engine("glm") %>% 
  fit(Match_Status ~ ., data = train_data)

predict(logistic_regression, new_data = test_data)
predict(logistic_regression, new_data = test_data, type = "prob")

