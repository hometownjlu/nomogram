##A Tidy Approach to a Classification Problem

#https://www.benjaminsorensen.me/post/modeling-with-parsnip-and-tidymodels/
#https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/
#https://towardsdatascience.com/modelling-with-tidymodels-and-parsnip-bae2c01c131c 
#https://github.com/tidymodels/parsnip/issues/152
#https://www.brodrigues.co/blog/2018-11-25-tidy_cv/ 
#https://www.alexpghayes.com/blog/implementing-the-super-learner-with-tidymodels/
#https://vidyasagar.rbind.io/2019/06/learn-machine-learning-using-kaggle-competition-titanic-dataset/
#https://towardsdatascience.com/decision-trees-in-machine-learning-641b9c4e8052 
#https://tidymodels.github.io/parsnip/articles/articles/Classification.html
#https://community.rstudio.com/t/permutation-variable-importance-using-auc/20573/5


#--------------------------------------------------- Splitting -----------------------------------------------#
#Tidymodels - Splitting data by proportion not by year.  
#Completing example from https://towardsdatascience.com/modelling-with-tidymodels-and-parsnip-bae2c01c131c
source(file="~/Dropbox/Nomogram/nomogram/Code/Additional_functions_nomogram.R", echo=TRUE, verbose=TRUE)
set.seed(seed = 1978) 
all_data$Age <- as.numeric(all_data$Age)
all_data <- all_data  %>% select(-Year)
data_split <- rsample::initial_split(data = all_data, 
                                     strata = "Match_Status", 
                                     prop = 0.8)
data_split

train_tbl <- data_split %>% training() %>% glimpse()  # Extract the training dataframe
test_tbl  <- data_split %>% testing() %>% glimpse() # Extract the testing dataframe


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

# Explanation of the boost_trees/xgboost model
model_boost_trees$fit %>%
  xgb.importance(model = .) %>%
  xgb.plot.importance(main = "XGBoost Feature Importance")

#--------------------------------------------------- Model: Decision Tree  -----------------------------------------------#
args(decision_tree)
set.seed(1978)
decision_tree <- 
  parsnip::decision_tree(mode = "classification", cost_complexity = varying(), min_n = 20, tree_depth = 6) %>%
  #set_engine("C5.0") %>%
  parsnip::set_engine("rpart") %>%   #Explain what engine we want: rpart so we can visualize tree using rpart.plot
  parsnip::set_args(cost_complexity = 0.01) %>%  #Can tinker with this variable  
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
decision_tree

# Explanation of the decision_trees/CART model
decision_tree$fit%>%
  rpart.plot(
    yesno = 2, type = 5, extra = +100, fallen.leaves = TRUE, varlen = 0, faclen = 0, roundint = FALSE, clip.facs = TRUE, shadow.col = "gray", main = "Tree Model of Medical Students Matching into OBGYN Residency\n(Matched or Unmatched)", box.palette = c("red", "green"))  


#--------------------------------------------- Model: Logistic Regression  -----------------------------------------------#
#But Wait we cannot simply blindly fit the logistic regression. We need to check the assumptions.Let’s check logistic regression assumption :-Features should be independent from each other, Residual should not be autocorrelated
#https://vidyasagar.rbind.io/2019/06/learn-machine-learning-using-kaggle-competition-titanic-dataset/

train_baked %>% select_if(is.numeric)
cor(train[,unlist(lapply(train_baked,is.numeric))])
#In statistics if the correlation coefficient is either greater than 0.75 (some say 0.70 and some even say 0.8) or less than -0.75 is considered as strong correlation. None of the correlation coefficients was greater than 0.75.  
train_baked %>% select_if(is.numeric) %>% cor()  #Second check.  

#For categorical variables we will use chisquare test to test the independence of factors/categorical variables.
train_baked %>% select_if(~!is.numeric(.)) %>% glimpse()

# Show the p-value of Chi Square tests
wg = chisq.test(train_baked$white_non_white, train_baked$Gender)$p.value
wcm = chisq.test(train_baked$white_non_white, train_baked$Couples_Match)$p.value
wus = chisq.test(train_baked$white_non_white, train_baked$US_or_Canadian_Applicant)$p.value
wmei = chisq.test(train_baked$white_non_white, train_baked$Medical_Education_Interrupted)$p.value
waoa = chisq.test(train_baked$white_non_white, train_baked$Alpha_Omega_Alpha)$p.value
wms = chisq.test(train_baked$white_non_white,train_baked$Military_Service_Obligation)$p.value
wvsn = chisq.test(train_baked$white_non_white,train_baked$Visa_Sponsorship_Needed)$p.value
wmedical = chisq.test(train_baked$white_non_white,train_baked$Medical_Degree)$p.value

gcm = chisq.test(train_baked$Gender, train_baked$Couples_Match)$p.value
gus = chisq.test(train_baked$Gender, train_baked$US_or_Canadian_Applicant)$p.value
gmei = chisq.test(train_baked$Gender, train_baked$Medical_Education_Interrupted)$p.value
gaoa = chisq.test(train_baked$Gender, train_baked$Alpha_Omega_Alpha)$p.value
gms = chisq.test(train_baked$Gender,train_baked$Military_Service_Obligation)$p.value
gvsn = chisq.test(train_baked$Gender,train_baked$Visa_Sponsorship_Needed)$p.value
gmedical = chisq.test(train_baked$Gender,train_baked$Medical_Degree)$p.value

cmus = chisq.test(train_baked$Couples_Match, train_baked$US_or_Canadian_Applicant)$p.value
cmmei = chisq.test(train_baked$Couples_Match, train_baked$Medical_Education_Interrupted)$p.value
cmaoa = chisq.test(train_baked$Couples_Match, train_baked$Alpha_Omega_Alpha)$p.value
cmms = chisq.test(train_baked$Couples_Match,train_baked$Military_Service_Obligation)$p.value
cmvsn = chisq.test(train_baked$Couples_Match,train_baked$Visa_Sponsorship_Needed)$p.value
cmmedical = chisq.test(train_baked$Couples_Match,train_baked$Medical_Degree)$p.value

usmei = chisq.test(train_baked$US_or_Canadian_Applicant, train_baked$Medical_Education_Interrupted)$p.value
usaoa = chisq.test(train_baked$US_or_Canadian_Applicant, train_baked$Alpha_Omega_Alpha)$p.value
usms = chisq.test(train_baked$US_or_Canadian_Applicant,train_baked$Military_Service_Obligation)$p.value
usvsn = chisq.test(train_baked$US_or_Canadian_Applicant,train_baked$Visa_Sponsorship_Needed)$p.value
usmedical = chisq.test(train_baked$US_or_Canadian_Applicant,train_baked$Medical_Degree)$p.value

meiaoa = chisq.test(train_baked$Medical_Education_Interrupted, train_baked$Alpha_Omega_Alpha)$p.value
meims = chisq.test(train_baked$Medical_Education_Interrupted,train_baked$Military_Service_Obligation)$p.value
meivsn = chisq.test(train_baked$Medical_Education_Interrupted,train_baked$Visa_Sponsorship_Needed)$p.value
meimedical = chisq.test(train_baked$Medical_Education_Interrupted,train_baked$Medical_Degree)$p.value

aoams = chisq.test(train_baked$Alpha_Omega_Alpha,train_baked$Military_Service_Obligation)$p.value
aovsn = chisq.test(train_baked$Alpha_Omega_Alpha,train_baked$Visa_Sponsorship_Needed)$p.value
aoamedical = chisq.test(train_baked$Alpha_Omega_Alpha,train_baked$Medical_Degree)$p.value

msovsn = chisq.test(train_baked$Military_Service_Obligation,train_baked$Visa_Sponsorship_Needed)$p.value
msomedical = chisq.test(train_baked$Military_Service_Obligation,train_baked$Medical_Degree)$p.value

mdvsn = chisq.test(train_baked$Medical_Degree,train_baked$Visa_Sponsorship_Needed)$p.value

cormatrix = matrix(c(0,  wg,  wcm,  wus,  wmei,  waoa,  wms,  wvsn, wmedical,  #All the first row, white_non_white
                     wg,  0, gcm,  gus,  gmei,  gaoa,  gms,  gvsn,  gmedical,  #Gender
                     wcm, gcm, 0,  cmus, cmmei, cmaoa,  cmms,  cmvsn,  cmmedical, # Couples match
                     wus, gus, cmus,  0, usmei, usaoa, usms, usvsn, usmedical, #US or Canadian
                     wmei, gmei, cmmei,  usmei, 0,  meiaoa,   meims,  meivsn,  meimedical, #MEdical ed interrupted
                     waoa,  gaoa,  cmaoa, usaoa, meiaoa,    0,  aoams, aovsn,  aoamedical, #AOA
                     wms, gms, cmms, usms, meims, aoams, 0, msovsn, msomedical, #Military Service
                     wvsn, gvsn, cmvsn, usvsn, meivsn, aovsn,  msovsn,   0, mdvsn, #MEdical degree
                     wmedical, gmedical, cmmedical, usmedical,meimedical, aoamedical, msomedical,  mdvsn,   0),  #Visa_Sponsorship_Needed
                   9, 9, byrow = TRUE)

row.names(cormatrix) = colnames(cormatrix) = c("white_non_white", "Gender", "Couples_Match", "US_or_Canadian_Applicant", "Medical_Education_Interrupted", "Alpha_Omega_Alpha", "Military_Service_Obligation", "Medical_Degree", "Visa_Sponsorship_Needed")
cormatrix

#What do I do with this now?

args(logistic_reg)  #Check what parameters exist with the model you want to use.  
set.seed(1978)
logistic_glm <-
  parsnip::logistic_reg(mode = "classification", penalty = 0) %>%   #Regression vs. classification
  parsnip::set_engine("glm") %>%   #Explain what machine learning engine we want: R
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the parsnip::fit() function is used. 
logistic_glm

#Cross-validation - To further refine the model’s predictive power, I am implementing a 10-fold cross validation using vfold_cv from rsample, which splits again the initial training data.

set.seed(1978)
# First, let’s make the splits of the data:
rs_obj <- rsample::vfold_cv(train_tbl, 
                            v = 10, repeats = 10, 
                            strata = "Match_Status")

# Build a model using the train data for each fold of the cross validation
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



#--------------------------------------------------- Model: Random Forest  -----------------------------------------------#
args(rand_forest)
random_forest <-
  parsnip::rand_forest(mtry = floor(.preds() * 0.75), mode = "classification", trees = 2000, min_n = 3) %>%   
  parsnip::set_engine("randomForest", seed = 1978) %>%   #Explain what engine we want: R
  parsnip::fit(Match_Status ~ ., data = train_baked)  #Finally, to execute the model, the fit() function is used. 
random_forest
varImpPlot(random_forest)

random_forest$lvl
random_forest$spec
random_forest$fit
random_forest$preproc
random_forest$elapsed
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
  
#--------------------------------------------------- Model: Ranger Random Forest  ----------------------------------------#
args(rand_forest)
ranger_random_forest <-
  parsnip::rand_forest(mtry = floor(.preds() * 0.75), mode = "classification", trees = 2000, min_n = 3) %>%   
  parsnip::set_engine("ranger", seed = 1978) %>%   #Explain what engine we want to use
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
  parsnip::mars(mode = "classification", prune_method = "backward") %>%
  parsnip::set_engine("earth", glm = list(family = binomial, maxit = 100)) %>%
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
mlp <- juice(mlp)

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
  parsnip::set_engine("klaR") %>%  # I needed to install the wrapper library discrim to do naive Bayes with tidymodels
  parsnip::fit(Match_Status ~ ., data=train_baked) 
naive_Bayes

tibble_of_model_names <- as_tibble(c("model_boost_trees", "decision_tree", "logistic_reg", "rand_forest", "ranger_random_forest","svm", "mars", "multinom_reg", "mlp", "nearest_neighbor", "naive_Bayes"))
#--------------------------------------------------- Predict on new data -----------------------------------------------#
# parsnip models always return the results as a data frame.  
# Accuracy - The model’s Accuracy is the fraction of predictions the model got right and can be easily calculated by passing the predictions_rf to the metrics function. However, accuracy is not a very reliable metric as it will provide misleading results if the data set is unbalanced.
#https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/

#Per classifier metrics - It is easy to obtain the probability for each possible predicted value by setting the type argument to prob. That will return a tibble with as many variables as there are possible predicted values. Their name will default to the original value name, prefixed with .pred_.


#Measuring Model Performance
confusion_matrix_graph_model_boost_trees <- tm_confusion_matrix_graph(model_name = model_boost_trees, label = "model_boost_trees")
confusion_matrix_graph_decision_tree <- tm_confusion_matrix_graph(model_name = decision_tree, label = "decision_tree")
#confusion_matrix_graph_logistic_reg <- tm_confusion_matrix_graph(model_name = logistic_reg, label = logistic_reg)  #does not work
confusion_matrix_graph_random_forest <- tm_confusion_matrix_graph(model_name = random_forest, label = "random_forest")
confusion_matrix_graph_ranger_random_forest <- tm_confusion_matrix_graph(model_name = ranger_random_forest, label = "random_forest")
confusion_matrix_graph_svm <- tm_confusion_matrix_graph(model_name = svm, label = "svm")
confusion_matrix_graph_mars <- tm_confusion_matrix_graph(model_name = mars, label = "mars")
#confusion_matrix_graph_multinom_reg <- tm_confusion_matrix_graph(model_name = multinom_reg, label = multinom_reg)
confusion_matrix_graph_mlp <- tm_confusion_matrix_graph(model_name = mlp, label = "mlp")
confusion_matrix_graph_nearest_neighbor <- tm_confusion_matrix_graph(model_name = nearest_neighbor, label = "nearest_neighbor")
#confusion_matrix_graph_naive_Bayes <- tm_confusion_matrix_graph(model_name = naive_Bayes, label = naive_Bayes)

tibble_of_model_names <- as_tibble(c("model_boost_trees", "decision_tree", "logistic_reg", "rand_forest", "ranger_random_forest","svm", "mars", "multinom_reg", "mlp", "nearest_neighbor", "naive_Bayes"))

#--------------------------------------------------- Metrics: XgBoost metrics  -----------------------------------------------#
predictions_model_boost_trees <-tibble(
  actual  = test_baked$Match_Status,
  predicted_model_boost_trees = predict(object = model_boost_trees, new_data = test_baked, type = "class") %>% pull(.pred_class),
  boost_trees_prob  = predict(object = model_boost_trees, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

boost_trees_auc <- predictions_model_boost_trees %>% roc_auc(truth = test_baked$Match_Status, Class1 = boost_trees_prob) %>%  mutate(model_type = "Boosted trees model") %>% select(model_type, everything(),-.estimator)

boost_trees_metric <- yardstick::metrics(predictions_model_boost_trees, actual, predicted_model_boost_trees) %>%  mutate(model_type = "Boosted trees model") %>% select(model_type, everything(),-.estimator)


#--------------------------------------------------Metrics: Decision Tree metrics  -----------------------------------------------#
predictions_model_decision_tree <-tibble(
  actual  = test_baked$Match_Status,
  predicted_model_decision_tree = predict(object = decision_tree, new_data = test_baked, type = "class") %>% pull(.pred_class),
  decision_tree_prob  = predict(object = decision_tree, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

decision_tree_auc <- predictions_model_decision_tree %>% roc_auc(truth = test_baked$Match_Status, Class1 = decision_tree_prob) %>%  mutate(model_type = "Decision Tree Model") %>% select(model_type, everything(),-.estimator)

decision_tree_metric <- yardstick::metrics(predictions_model_decision_tree, actual, predicted_model_decision_tree) %>%  mutate(model_type = "Decision Tree Model") %>% select(model_type, everything(),-.estimator)


#------------------------------------------------ Metrics: Random forest metrics  -----------------------------------------------#
predictions_ranger_random_forest <-tibble(
  actual  = test_baked$Match_Status,
  predicted_ranger_random_forest = predict(object = ranger_random_forest, new_data = test_baked, type = "class") %>% pull(.pred_class),
  ranger_random_forest_prob  = predict(object = ranger_random_forest, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

ranger_random_forest_auc <- predictions_ranger_random_forest %>% roc_auc(truth = test_baked$Match_Status, Class1 = ranger_random_forest_prob) %>%  mutate(model_type = "Ranger randomForest Model") %>% select(model_type, everything(),-.estimator)

ranger_random_forest_metric <- yardstick::metrics(predictions_ranger_random_forest, actual, predicted_ranger_random_forest) %>%  mutate(model_type = "Ranger randomForest Model") %>% select(model_type, everything(),-.estimator)

#--------------------------------------------------- Metrics: SVM metrics  -----------------------------------------------#
predictions_svm <-tibble(
  actual  = test_baked$Match_Status,
  predicted_svm = predict(object = svm, new_data = test_baked, type = "class") %>% pull(.pred_class),
  svm_prob  = predict(object = svm, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

svm_auc <- predictions_svm %>% roc_auc(truth = test_baked$Match_Status, Class1 = svm_prob) %>%  mutate(model_type = "Support Vector Machines") %>% select(model_type, everything(),-.estimator)

svm_metric <- yardstick::metrics(predictions_svm, actual, predicted_svm) %>%  mutate(model_type = "Support Vector Machines") %>% select(model_type, everything(),-.estimator)

#--------------------------------------------------- Metrics: MARS metrics  -----------------------------------------------#
predictions_mars <-tibble(
  actual  = test_baked$Match_Status,
  predicted_mars = predict(object = mars, new_data = test_baked, type = "class") %>% pull(.pred_class),
  mars_prob  = predict(object = mars, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

mars_auc <- predictions_mars %>% roc_auc(truth = test_baked$Match_Status, Class1 = mars_prob) %>%  mutate(model_type = "MARS") %>% select(model_type, everything(),-.estimator)

mars_metric <- yardstick::metrics(predictions_mars, actual, predicted_mars) %>%  mutate(model_type = "MARS") %>% select(model_type, everything(),-.estimator)


#--------------------------------------------------- Metrics: MLP metrics  -----------------------------------------------#
predictions_mlp <-tibble(
  actual  = test_baked$Match_Status,
  predicted_mlp = predict(object = mlp, new_data = test_baked, type = "class") %>% pull(.pred_class),
  mlp_prob  = predict(object = mlp, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

mlp_auc <- predictions_mlp %>% roc_auc(truth = test_baked$Match_Status, Class1 = mlp_prob) %>%  mutate(model_type = "Single Layer Neural Network") %>% select(model_type, everything(),-.estimator)

mlp_metric <- yardstick::metrics(predictions_mlp, actual, predicted_mlp) %>%  mutate(model_type = "Single Layer Neural Network") %>% select(model_type, everything(),-.estimator)

#--------------------------------------------------- Metrics: KNN metrics  -----------------------------------------------#
predictions_nearest_neighbor <-tibble(
  actual  = test_baked$Match_Status,
  predicted_nearest_neighbor = predict(object = nearest_neighbor, new_data = test_baked, type = "class") %>% pull(.pred_class),
  knn_prob  = predict(object = nearest_neighbor, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

knn_auc <- predictions_nearest_neighbor %>% roc_auc(truth = test_baked$Match_Status, Class1 = knn_prob) %>%  mutate(model_type = "K-nearest neighbors") %>% select(model_type, everything(),-.estimator)

knn_metric <- yardstick::metrics(predictions_nearest_neighbor, actual, predicted_nearest_neighbor) %>%  mutate(model_type = "K-nearest neighbors") %>% select(model_type, everything(),-.estimator)

#--------------------------------------------------- Accuracy Metrics  -----------------------------------------------#
final_accuracy_roc <- rbind(boost_trees_metric, decision_tree_metric, ranger_random_forest_metric, svm_metric, mars_metric, mlp_metric, knn_metric, decision_tree_auc, ranger_random_forest_auc, knn_auc, mars_auc, mlp_auc, svm_auc, boost_trees_auc) %>% spread(.metric, .estimate) %>% dplyr::arrange(desc(accuracy))
final_accuracy_roc

#Among seven different types of classification models used decision tree gave the best results in terms of accuracy.

dt_probs<- decision_tree %>% 
  predict(new_data = test_baked, type = "prob") %>% 
  bind_cols(test_baked)
dt_probs %>% glimpse()

# dt_probs %>%
#   yardstick::roc_curve(data = dt_probs, truth = Match_Status, estimate = .pred_Matched) %>%   #not working
#   ggplot2::autoplot()

colnames(dt_probs)
#--------------------------------------------------------------------------------------
  
  #In parsnip, the predict function can be used.  You can get both the predicted class and the prediction probability on the new data created in a tibble.  Then you can take that tibble of actual vs. predictions and check metrics and create a confusion matrix. 


#--------------------------------------------------- Cross-validation------------------------------------ -------------#
#https://tidymodels.github.io/rsample/articles/Working_with_rsets.html
#https://www.alexpghayes.com/blog/implementing-the-super-learner-with-tidymodels/

#Cross-validation - To further refine the model’s predictive power, I am implementing a 10-fold cross validation using vfold_cv from rsample, which splits again the initial training data.

set.seed(1978)
# First, let’s make the splits of the data:
rs_obj <- rsample::vfold_cv(train_tbl, 
                            v = 10, repeats = 10, 
                            strata = "Match_Status")

#Now let’s write a function (tm_holdout_results) that will, for each resample:obtain the analysis data set (i.e. the 90% used for modeling)fit a logistic regression model predict the assessment data (the other 10% not used for the model) using the broom package determine if each sample was predicted correctly.
## splits will be the `rsplit` object with the 90/10 partition

#Handle all split data at once with map.  
rs_obj$results <- purrr::map(rs_obj$splits,  #Applies the function against all the splits
                             tm_holdout_results,
                             Match_Status ~ .)
rs_obj

rs_obj$accuracy <- map_dbl(rs_obj$results, function(x) mean(x$correct)) #Now we can compute the accuracy values for all of the assessment data sets
summary(rs_obj$accuracy)



data("iris")
#https://www.alexpghayes.com/blog/implementing-the-super-learner-with-tidymodels/
install.packages("tidymodels")
install.packages("furrr")
install.packages("tidyr")

#devtools::install_github("tidyverse/tidyr")
#devtools::install_github("tidymodels/parsnip")

install_version("dials", version = "0.0.3", repos = "http://cran.us.r-project.org")

library(tidymodels)
library(tidyr)
library(dials)
library(furrr)

# use `plan(sequential)` to effectively convert all
# subsequent `future_map*` calls to `map*`
# calls. this will result in sequential execution of 
# embarassingly parallel model fitting procedures
# but may prevent R from getting angry at parallelism

future::plan(multicore)  
set.seed(27)  # the one true seed

data <- as_tibble(iris)
data

model <- (parsnip::decision_tree(mode = "classification") %>%
  set_engine("C5.0"))
model
class(model)

# the dials API is the most unstable out of all
# packages in this post at the moment. the
# following uses dials 0.0.2

#original
# hp_grid <- grid_random(
#   min_n %>% range_set(c(2, 20)),
#   tree_depth,
#   size = 10
# )

set.seed(1978)
hp_grid <- grid_random(
  min_n(range = c(10, 20)), #The minimum number of data points in a node that are required for the node to be split further
  tree_depth(range = c(1L, 5L)), #The maximum depth of the tree (i.e. number of splits)
  size = 6, 
  cost_complexity(range = c(-10, -1), trans = log10_trans())
  )
  
class(hp_grid)
hp_grid

# Original
spec_df <- tibble(spec = (hp_grid)) %>% 
  mutate(model_id = row_number())
spec_df

spec_df <- tibble(spec = list(model, hp_grid)) %>%
  mutate(model_id = row_number())
spec_df[[1]]








predictions_nearest_neighbor <-tibble(
  actual  = test_baked$Match_Status,
  predicted_nearest_neighbor = predict(object = nearest_neighbor, new_data = test_baked, type = "class") %>% pull(.pred_class),
  knn_prob  = predict(object = nearest_neighbor, new_data = test_baked, type = "prob") %>% 
    pull(.pred_Matched))

recipe <- data %>% 
  recipe(Species ~ .) %>% 
  step_pca(all_predictors(), num_comp = 2)
recipe

prepped <- prep(recipe, training = data)

x <- juice(prepped, all_predictors())
y <- juice(prepped, all_outcomes())

full_fits <- spec_df %>% 
  mutate(fit = future_map(spec, fit_xy, x, y))
full_fits

folds <- vfold_cv(data, v = 10)

fit_on_fold <- function(spec, prepped) {
  x <- juice(prepped, all_predictors())
  y <- juice(prepped, all_outcomes())
  fit_xy(spec, x, y)
}

crossed <- crossing(folds, spec_df)
crossed

cv_fits <- crossed %>%
  mutate(
    prepped = future_map(splits, prepper, recipe),
    fit = future_map2(spec, prepped, fit_on_fold)
  )

predict_helper <- function(fit, new_data, recipe) {
  # new_data can either be an rsample::rsplit object
  # or a data frame of genuinely new data
  
  if (inherits(new_data, "rsplit")) {
    obs <- as.integer(new_data, data = "assessment")
    
    # never forget to bake when predicting with recipes!
    new_data <- bake(recipe, assessment(new_data))
  } else {
    obs <- 1:nrow(new_data)
    new_data <- bake(recipe, new_data)
  }
  
  # if you want to generalize this code to a regression
  # super learner, you'd need to set `type = "response"` here
  
  predict(fit, new_data, type = "prob") %>% 
    mutate(obs = obs)
}

holdout_preds <- cv_fits %>% 
  mutate(
    preds = future_pmap(list(fit, splits, prepped), predict_helper)
  )

holdout_preds %>% 
  unnest(preds)

spread_nested_predictions <- function(data) {
  data %>% 
    unnest(preds) %>% 
    pivot_wider(
      id_cols = obs,
      names_from = model_id,
      values_from = contains(".pred")
    )
}

holdout_preds <- spread_nested_predictions(holdout_preds)
holdout_preds

meta_train <- data %>% 
  mutate(obs = row_number()) %>% 
  right_join(holdout_preds, by = "obs") %>% 
  select(Species, contains(".pred"))
meta_train

metalearner <- multinom_reg(penalty = 0.01, mixture = 0) %>% 
  set_engine("glmnet") %>% 
  fit(Species ~ ., meta_train)
metalearner

new_data <- head(iris)

# run the new data through the library of base learners first
base_preds <- full_fits %>% 
  mutate(preds = future_map(fit, predict_helper, new_data, prepped)) %>% 
  spread_nested_predictions()
# then through the metalearner
predict(metalearner, base_preds, type = "prob")



#' Fit the super learner!
#'
#' @param library A data frame with a column `spec` containing
#'   complete `parsnip` model specifications for the base learners 
#'   and a column `model_id`.
#' @param recipe An untrained `recipe` specifying data design
#' @param meta_spec A singe `parsnip` model specification
#'   for the metalearner.
#' @param data The dataset to fit the super learner on.
#'
#' @return A list with class `"super_learner"` and three elements:
#'
#'   - `full_fits`: A tibble with list-column `fit` of fit
#'     base learners as parsnip `model_fit` objects
#'
#'   - `metalearner`: The metalearner as a single parsnip
#'     `model_fit` object
#'
#'   - `recipe`: A trained version of the original recipe
#'
data_split <- credit_data %>% 
  na.omit() %>% 
  initial_split(strata = "Status", p = 0.75)

credit_train <- training(data_split)
credit_test  <- testing(data_split)

credit_recipe <- recipe(Status ~ ., data = credit_train) %>%
  step_center(all_numeric()) %>%
  step_scale(all_numeric())

credit_model <- mars(mode = "classification", prune_method = "backward") %>% 
  set_engine("earth")
class(credit_model)

num_terms <- dials::num_terms(range = c(1L, 30L))
class(num_terms)

credit_hp_grid <- dials::grid_random(x = num_terms, size = 6)


credit_library <- enframe(merge(spec = (credit_model, credit_hp_grid))) %>% 
  mutate(model_id = row_number()) 
  
 # credit_library <- tibble(spec = merge(credit_model, credit_hp_grid)) %>% 
  #   mutate(model_id = row_number())

credit_meta <- multinom_reg(penalty = 0, mixture = 1) %>% 
  set_engine("glmnet")

super_learner <- function(library, recipe, meta_spec, data) {
  
  folds <- vfold_cv(data, v = 5)
  
  cv_fits <- crossing(folds, library) %>%
    mutate(
      prepped = future_map(splits, prepper, recipe),
      fit = future_pmap(list(spec, prepped), fit_on_fold)
    )
  
  prepped <- prep(recipe, training = data)
  
  x <- juice(prepped, all_predictors())
  y <- juice(prepped, all_outcomes())
  
  full_fits <- library %>% 
    mutate(fit = future_map(spec, fit_xy, x, y))
  
  holdout_preds <- cv_fits %>% 
    mutate(
      preds = future_pmap(list(fit, splits, prepped), predict_helper)
    ) %>% 
    spread_nested_predictions() %>% 
    select(-obs)
  
  metalearner <- fit_xy(meta_spec, holdout_preds, y)
  
  sl <- list(full_fits = full_fits, metalearner = metalearner, recipe = prepped)
  class(sl) <- "super_learner"
  sl
}

matching_super_learner <- super_learner(credit_library, credit_recipe, credit_meta, credit_train)

pred <- predict(credit_sl, credit_test, type = "prob")

pred %>% 
  bind_cols(credit_test) %>% 
  roc_curve(Status, .pred_bad) %>%
  autoplot()





#------------------------------------------------------------------------------------------------------------------------
# http://www.datannery.com/2018/12/24/tidy-titanic/
