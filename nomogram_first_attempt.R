#Install and Load packages
#rm(list=ls())
#remotes::install_github("topepo/caret")
if(!require(pacman))install.packages("pacman")
pacman::p_load('Hmisc', 'readxl', 'XML', 'reshape2', 'devtools', 'plyr', 'packrat', 'highcharter', 'purrr', 'readr', 'htmlwidgets', 'RColorBrewer', 'leaflet', 'rgdal', 'dygraphs', 'quantmod', 'DT', 'formattable', 'ggplot2',  'idbr', 'genderizeR', 'animation', 'dplyr', 'magick', 'tidycensus', 'ggthemes', 'stringr', 'geosphere', 'ggmap', 'grid', 'gmapsdistance', 'zipcode', 'janitor', 'lubridate', 'hms', 'tidyr', 'stringr', 'readr', 'openxlsx', 'forcats', 'RcppRoll', 'tibble', 'bit64', 'munsell', 'scales', 'leaflet', 'rgdal', 'htmltools', 'mapview', 'htmlwidgets', 'sf', 'sp', 'tidyverse', 'viridis', 'fansi', 'webshot', 'geosphere', 'zipcode', 'leaflet.extras', 'raster',  'spData','spDataLarge', 'stplanr', 'tmap', 'osmdata', 'arsenal', 'doMC', "wesanderson", "fasterize", "USAboundaries", "RANN", "tidycensus", "geofacet", "extrafont", "shiny", "ParallelLogger", "parallel", "RSelenium", "humaniformat", "visdat", "skimr", "assertr", "tidylog", "doParallel", "DiagrammeR", "DiagrammeRsvg", "rsvg", "iterators", "parallel", "foreach", "PASWR", "rms", "pROC", "ROCR", "nnet", "janitor", "packrat", "DynNom", "rsconnect", "party", "recipes", "caret", "caretEnsemble","export", "caTools", "mlbench", "randomForest", "survey", "e1071", "doSNOW", "ipred", "xgboost", "Metrics", "RANN", "AppliedPredictiveModeling", "nomogramEx", "shiny", "earth", "fastAdaboost", "Boruta", "glmnet", "ggforce", "tidylog", "InformationValue", "pscl", "scoring", "DescTools", "gbm", "cowplot")
#.libPaths("/Users/tylermuffly/.exploratory/R/3.5")  # Set libPaths.
#packrat::init(infer.dependencies = TRUE)
set.seed(123456)
registerDoMC(cores = detectCores()-1)
dev.off()

##################################################################
#### Set data file locations ####
setwd("~/Dropbox/Nomogram/nomogram")  #Set working directory

################################################################
#Load Data
download.file("https://www.dropbox.com/s/b2vqurq5575dbxf/CU_Obgyn_Residency_Applicants_rename_61.rds?raw=1",destfile=paste0("CU_Obgyn_Residency_Applicants_rename_61.rds"), method = "auto", cacheOK = TRUE)
data <- read_rds("data/CU_Obgyn_Residency_Applicants_rename_61.rds")

download.file("https://www.dropbox.com/s/845h7ixrjoz4h5m/CU_Obgyn_Residency_Applicants_fill_48.rds?raw=1",destfile=paste0("CU_Obgyn_Residency_Applicants_fill_48.rds"), method = "auto", cacheOK = TRUE)
full_data <- read_rds("data/CU_Obgyn_Residency_Applicants_fill_48.rds")  #Bring in the full data set

################################################################
####  Plot variable characteristics
 colnames(data)
 features <-colnames(data)
 features_rel<-features [2:24]   
 
for( i in features_rel ){
   temp_plot<-ggplot(data = data, aes_string(x=i,fill="Match_Status")) + geom_bar(alpha=0.8,colour='black', show.legend = TRUE, stat = "count") + theme(legend.position = "top") + 
 ggtitle(paste0("Match Statistics for 2019 OBGYN: \n",i)) + 
    guides(fill = guide_legend(nrow = 4, byrow = T) + 
    geom_text (aes(label = y), position = position_stack(vjust = 0.5), size = 10, angle = 45, check_overlap = TRUE) + 
    geom_label(fontface = "bold"))
   print(temp_plot) 
   ggsave(temp_plot, file=paste0("plot_", i,".png"), width = 14, height = 10, units = "cm", dpi = 500,  bg = "transparent")
 }
 print(temp_plot)
 dev.off()

 ################################################################
 #### Building Table 1 ####
colnames(full_data)
table1 <- tableby(Match_Status ~
                    Self_Identify + 
                    white_non_white + 
                    Age + 
                    Gender + 
                    Couples_Match + 
                    Expected_Visa_Status_Dichotomized + 
                    US_or_Canadian_Applicant + 
                    Medical_School_Type + 
                    Medical_Education_or_Training_Interrupted + 
                    Misdemeanor_Conviction + 
                    Alpha_Omega_Alpha + 
                    Gold_Humanism_Honor_Society + 
                    Military_Service_Obligation + 
                    USMLE_Step_1_Score + 
                    Military_Service_Obligation + 
                    Count_of_Poster_Presentation + 
                    Count_of_Oral_Presentation + 
                    Count_of_Peer_Reviewed_Journal_Articles_Abstracts + 
                    Count_of_Peer_Reviewed_Book_Chapter + 
                    Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published + 
                    Count_of_Peer_Reviewed_Online_Publication + 
                    Misdemeanor_Conviction  + 
                    Expected_Visa_Status_Dichotomized + 
                    Visa_Sponsorship_Needed +
                    OBGYN_Grade +
                    Medical_Degree +
                    Medical_School_Country, 
                  data=full_data, control = tableby.control(test = TRUE, total = F, digits = 1L, digits.p = 2L, digits.count = 0L, numeric.simplify = F, numeric.stats = c("meansd", "median", "q1q3"), cat.stats = c("Nmiss","countpct"), stats.labels = list(Nmiss = "N Missing", Nmiss2 ="N Missing", meansd = "Mean (SD)", medianrange = "Median (Range)", median ="Median", medianq1q3 = "Median (Q1, Q3)", q1q3 = "Q1, Q3", iqr = "IQR",range = "Range", countpct = "Count (Pct)", Nevents = "Events", medSurv ="Median Survival", medTime = "Median Follow-Up")))
 
 #labels
 labels(table1)
 
 #show the table
 summary(table1, text=T, title='Table 1:  Demographics of CU Applicants to Obstetrics and Gynecology in 2019', pfootnote=TRUE)
 
 #Adjust for Bonferroni for multiple p-values
 padjust(table1, method = "bonferroni")
 summary(table1, text=T, title='Table 1:  Demographics of CU Applicants to Obstetrics and Gynecology in 2019', pfootnote=TRUE)
 
 #Write to HTML
 arsenal::write2html(table1, ("~/Dropbox/Nomogram/nomogram/results/table1.html"), total=FALSE, title = "Table 1", quiet = FALSE, theme = "yeti")
 
 #Write to word
 arsenal::write2word(table1, paste0("~/Dropbox/Nomogram/nomogram/results/table1.doc"))
 
 #######################################################################################
 #  Explore Data
 colnames(data)
 t.test(data$Age~data$Match_Status) #SS # where y is numeric and x is a binary factor
 chisq.test(data$Match_Status, data$white_non_white) #SS
 chisq.test(data$Match_Status, data$Gender) #SS
 chisq.test(data$Match_Status, data$Couples_Match) #SS
 t.test(data$USMLE_Step_1_Score~data$Match_Status) #SS
 chisq.test(data$Match_Status, data$Expected_Visa_Status_Dichotomized) #SS
 #chisq.test(data$Match_Status, data$Med_school_condensed)
 chisq.test(data$Match_Status, data$Medical_Education_or_Training_Interrupted) #SS
 chisq.test(data$Match_Status, data$Misdemeanor_Conviction) #SS
 chisq.test(data$Match_Status, data$Alpha_Omega_Alpha) #SS
 chisq.test(data$Match_Status, data$US_or_Canadian_Applicant) #SS
 chisq.test(data$Match_Status, data$Gold_Humanism_Honor_Society) #SS
 chisq.test(data$Match_Status, data$Military_Service_Obligation)  #Not significant at all
 chisq.test(data$Match_Status, data$Visa_Sponsorship_Needed) #SS
 chisq.test(data$Match_Status, data$white_non_white) #SS
 chisq.test(data$Match_Status, data$Expected_Visa_Status) #SS
 chisq.test(data$Match_Status, data$Partner_Match) #NS
 t.test(data$Count_of_Poster_Presentation ~ data$Match_Status) #SS
 t.test(data$Count_of_Oral_Presentation ~ data$Match_Status)  #NS
 t.test(data$Count_of_Peer_Reviewed_Book_Chapter ~ data$Match_Status) #NS
 t.test(data$Count_of_Peer_Reviewed_Online_Publication ~ data$Match_Status) #NS
 chisq.test(data$Match_Status, data$OBGYN_Grade) #Fails because too many NA
 #######################################################################################

#=================================================================
# Data Wrangling
#=================================================================

#Look at the full data set for NAs
 nrow(data)
 ncol(data)
 #View(data)
 data$Match_Status <- as.factor(data$Match_Status)
 sum(is.na(data))
 data <- na.omit(data)
 sum(is.na(data))
str(data)

#=================================================================
# Split Full Data Set for Creating Model
#=================================================================

# Use caret to create a 70/30% split of the training data,
# keeping the proportions of the Survived class label the
# same across splits.
indexes <- caret::createDataPartition(y=data$Match_Status,   #Create the training set from the whole data
                               times = 1,
                               p = 0.7,
                               list = FALSE)
match.train <- data[indexes,]
match.train <- na.omit(match.train)
nrow(match.train)
sum(is.na(match.train))
match.test <- data[-indexes,]
match.test <- na.omit(match.test)
sum(is.na(match.test))
nrow(match.test)

# Examine the proportions of the Match_Status class lable across
# the datasets.
prop.table(table(data$Match_Status))       #Original data set proportion 
prop.table(table(match.train$Match_Status)) #Train data set proportion
prop.table(table(match.test$Match_Status))  #Test data set proportion

#=================================================================
# Data Visualization
#=================================================================
dim(match.train)
colnames(match.train)
skimmed <- skim_to_wide(match.train)
skimmed[, c(2:15)]

str(match.train)
AppliedPredictiveModeling::transparentTheme(trans = .4)
caret::featurePlot(x = match.train [,17:23], 
                   scales=list(x=list(relation="free"), y=list(relation="free")), 
                   y = match.train[,1], 
                   plot = "box",  #What  predictors do you notice have significant mean differences?
                   strip=strip.custom(par.strip.text=list(cex=.7)),
                   ## Add a key at the top
                   auto.key = list(columns = 3))

#=================================================================
# Check for NAs in data
#=================================================================
sum(is.na(match.train))
#View(match.train)

#=================================================================
# Impute Missing Data using preProcess
#=================================================================
# Caret supports a number of mechanism for imputing (i.e., 
# predicting) missing values. Leverage bagged decision trees
# to impute missing values for the Age feature.

# First, transform all feature to dummy variables.
dummy.vars <- caret::dummyVars(~ ., data = match.train[, -1])
trainData <- predict(dummy.vars, match.train[, -1])  #Had to remove spaces from all variables and values

# Now, impute!
pre.process <- caret::preProcess(match.train, method = "bagImpute")
imputed.data <- predict(pre.process, match.train)
sum(is.na(imputed.data))
#View(imputed.data)

#Check that all predictors are between zero and one
apply(match.train[, 2:24], 2, FUN=function(x){c('min'=min(x), 'max'=max(x))})


#=================================================================
#  Factor Selection
#=================================================================
#https://www.analyticsvidhya.com/blog/2016/12/introduction-to-feature-selection-methods-with-an-example-or-how-to-select-the-right-variables/
indexes <- caret::createDataPartition(y = match.train$Match_Status,  #Divide the data into train and test sets
                                      times = 1,
                                      p = 0.7,
                                      list = FALSE)
#Split the data so that we cna run a model and find best factors.  
train <- data[indexes,]
nrow(train)
test <- data[-indexes,]
nrow(test)

#Method One:  Principal Component Analysis
#Use principal components analysis to pick what predictors to use in the model.  
#http://www.rebeccabarter.com/blog/2017-11-17-caret_tutorial/
train_pca <- preProcess(select(data, - Match_Status), 
                        method = c("center", "scale", "nzv", "pca"))
train_pca
train_pca$method
train_pca$rotation

#Method 2:  Make various models and compare the AUC of the models
#Use randomForest to determine AUC of different models 
model_rf<-randomForest::randomForest(Match_Status ~ ., data = train, na.action = na.omit)
preds<-predict(model_rf,test[,-1])  #-1 is to avoid messing with the outcome variable
table(preds)

test$Match_Status <- as.factor(test$Match_Status)
#auc(preds,test$Match_Status)  ##checking accuracy
randomForest::importance(model_rf)  #look at the feature importance

model_rf<-randomForest::randomForest(Match_Status ~ USMLE_Step_1_Score+Age+US_or_Canadian_Applicant+Gold_Humanism_Honor_Society+Count_of_Oral_Presentation  
                                     #Applying Random forest for most important 10 features only
                                     
                                     +Count_of_Peer_Reviewed_Journal_Articles_Abstracts+Count_of_Poster_Presentation+white_non_white+Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published+Alpha_Omega_Alpha,data = train, na.action = na.omit)


preds<-predict(model_rf,test[,-1])
class(preds)
table(preds)
class(test$Match_Status)
auc(preds,test$Match_Status)  #See how the AUC improves with only 10 variables.  
plotROC(test$Match_Status, preds)

#Method 3: Recursive Feature Elimination
### Use recursive feature elimination (rfe), https://www.machinelearningplus.com/machine-learning/caret-package/ 
options(warn=-1)
subsets <- c(2:24)
ctrl <- rfeControl(functions = rfFuncs,
                   method = "repeatedcv",
                   repeats = 2,
                   verbose = FALSE)

lmProfile <- rfe(x=train[, 2:24], y=train$Match_Status,
                 sizes = subsets,
                 rfeControl = ctrl)
lmProfile  #Picked 5 variables that were able to predict 

#Method 4:  Boruta search
#You'll see how you can use it to perform a top-down search for relevant features by comparing original attributes' importance with importance achievable at random, estimated using their permuted copies, and progressively elliminating irrelevant features.

boruta_output <- Boruta::Boruta(Match_Status ~ ., data=na.omit(train), doTrace=0)  
names(boruta_output)
# Get significant variables including tentatives
boruta_signif <-Boruta::getSelectedAttributes(boruta_output, withTentative = TRUE)
print(boruta_signif)  

# Do a tentative rough fix
roughFixMod <- TentativeRoughFix(boruta_output)
boruta_signif <- getSelectedAttributes(roughFixMod)
print(boruta_signif)

# Variable Importance Scores
imps <- attStats(roughFixMod)
imps2 = imps[imps$decision != 'Rejected', c('meanImp', 'decision')]
head(imps2[order(-imps2$meanImp), ])  # descending sort

# Plot variable importance
plot(boruta_output, cex.axis=0.35, las=2, xlab="", main="Variable Importance")  

#Method 5:  Variable important from ML algorithm 
modelLookup('earth')

# Train the model using randomForest and predict on the training data itself.
model_mars = train(Match_Status ~ ., data=train, method='earth')
fitted <- predict(model_mars)
model_mars
plot(model_mars, main="Model Accuracies with MARS") #Iterations of hyperparameter search performed.

varimp_mars <- varImp(model_mars)
plot(varimp_mars, main="Variable Importance with MARS") #Visual of the most important factors

#=================================================================
#  Create a Logistic Regression Model: log(odds)=β0+β1∗x1+...+βn∗xn
#=================================================================
# Build Logistic Model - Now that we have selected the features and the best model.  
colnames(train)
ddist <- datadist(train)
ddist
options (datadist = 'ddist')

# Recalculated (mod_fit_three) using rms::lrm so that I can use that package for the nomogram
model.binomial.significant <- rms::lrm(Match_Status ~ 
                                         #Age + #Univariate SS  #Wald Test p=0.40, fair
                                         #Gender + #Univariate SS  #Wald Test p=0.30, good
                                         #white_non_white + #Univariate SS,  # p=0.30
                                         #Couples_Match + #Univariate SS, # Wald Test p=0.048, KEEP
                                         USMLE_Step_1_Score + #Univariate SS, #Wald Test p=0.025
                                         #Visa_Status_Expected + #Univariate SS, #Wald Testp=0.35
                                         Alpha_Omega_Alpha + #Univariate SS, #Wald Test p=0.5
                                         #Gold_Humanism_Honor_Society + #Univariate SS, #Wald Test p=0.01
                                         #Visa_Sponsorship_Needed + #Univariate SS, #Wald Test p=0.20
                                         Count_of_Poster_Presentation +
                                         #Medical_Education_or_Training_Interrupted + #Univariate SS
                                         #Misdemeanor_Conviction + #Univariate SS
                                         US_or_Canadian_Applicant, #Univariate SS
                                         #Count_of_Non_Peer_Reviewed_Online_Publication,
                                         #Visa_Sponsorship_Needed + #Univariate SS
                                         #Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published,
                                       data = train, x=TRUE, y=TRUE)

print(model.binomial.significant)  #Check the C-statistic which is the same as ROC area for binary logistic regression

#=================================================================
#Look for Co-linearity with Variance Inflation Factors
#We should check for multicollinearity in the model. As seen below, all X variables in the model have VIF well below 4.  #http://r-statistics.co/Logistic-Regression-With-R.html
#=================================================================
rms::vif(model.binomial.significant) #Should be <4

#=================================================================
#  Table 2 Odds Ratios and CIs
#=================================================================

oddsratios <- as.data.frame(exp(cbind("Odds ratio" = coef(model.binomial.significant), confint.default(model.binomial.significant, level = 0.95))))
print(oddsratios)

#Write to HTML
arsenal::write2html(oddsratios, ("~/Dropbox/Nomogram/nomogram/results/oddratios_table2.html"), total=FALSE, title = "Table 2", quiet = FALSE, theme = "yeti")

#Write to word
arsenal::write2word(oddsratios, paste0("~/Dropbox/Nomogram/nomogram/results/oddsratios_table2.doc"))

#=================================================================
#  Prepare the test dataset and predict on NEW DATA
#=================================================================
# Step 1: Impute missing values 
testData2 <- predict(pre.process, test)  

# Step 2: Create one-hot encodings (dummy variables)
testData3 <- predict(dummy.vars, testData2)

# Step 3: Transform the features to range between 0 and 1
testData4 <- predict(pre.process, testData3)

# View
head(testData4[, 1:10])


#=================================================================
# Predict on the NEW/TEST DATA
#=================================================================
predicted <- predict(model_mars, testData2)
head(predicted)

# Compute the confusion matrix
caret::confusionMatrix(reference = test$Match_Status, data = predicted, mode='everything')

#=================================================================
# Check the quality of the new model
#=================================================================
####Pseudo R^2
library(pscl)
pR2(model.binomial.significant)  # look for 'McFadden', values closer to zero indicating that the model has no predictive power

model.binomial.significant2 <- glm(Match_Status ~ USMLE_Step_1_Score + Alpha_Omega_Alpha + Count_of_Poster_Presentation + US_or_Canadian_Applicant, data = test, family = "binomial")

# Compute AUC for predicting Match_Status_Dichot with the model
prob <- predict(model.binomial.significant2, newdata=test, type="response")  #Must use GLM model
pred <- prediction(prob, test$Match_Status)
perf <- performance(pred, measure = "tpr", x.measure = "fpr")
#Export at this time
#tiff(filename = "~/Dropbox/Nomogram/nomogram/results/matching_nomogram_area_under_the_curve.tiff.", bg = "white", res = 800) #Not working
plot(perf)
#Export here 
dev.off()
auc <- performance(pred, measure = "auc")
auc <- auc@y.values[[1]]
auc  #78% AUC

#=================================================================
# Use the TEST data on MULTIPLE MODELS.  BALLER!
#=================================================================
# Stacking Algorithms - Run multiple algos in one call.
trainControl <- trainControl(method="repeatedcv", 
                             number=10, 
                             repeats=3,
                             savePredictions=TRUE, 
                             classProbs=TRUE)

algorithmList <- c('rf', 'adaboost', 'earth', 'xgbDART', 'svmRadial')

#set.seed(123456)
#models <- caretList(Match_Status ~ ., data=testData2, trControl=trainControl, methodList=algorithmList) 
#results <- resamples(models)
#summary(results)

# Box plots to compare models
scales <- list(x=list(relation="free"), y=list(relation="free"))
bwplot(results, scales=scales)


#=================================================================
# How to combine the predictions of multiple models to form a final prediction?
#=================================================================
# Create the trainControl
set.seed(123456)
stackControl <- trainControl(method="repeatedcv", 
                             number=10, 
                             repeats=3,
                             savePredictions=TRUE, 
                             classProbs=TRUE)

# Ensemble the predictions of `models` to form a new combined prediction based on glm
stack.glm <- caretStack(models, method="glm", metric="Accuracy", trControl=stackControl)
print(stack.glm)

# Predict on testData
stack_predicteds <- predict(stack.glm, newdata=test)
head(stack_predicteds)


#mod_fit has all variables included
colnames(data)
data$Match_Status <- as.factor(data$Match_Status)
mod_fit <- glm(Match_Status ~ ., 
               data=data, family="binomial")
print(mod_fit)


##Feature Selection##
#mod_fit_two has only the univariate statistically significant values 
mod_fit_two <- glm(Match_Status ~ 
                     Age +  #Univariate SS
                     Gender + #Univariate SS
                     white_non_white + #Univariate SS
                     Couples_Match + #Univariate SS
                     USMLE_Step_1_Score + #Univariate SS
                     Visa_Status_Expected + #Univariate SS
                     Medical_Education_or_Training_Interrupted + #Univariate SS
                     Misdemeanor_Conviction + #Univariate SS
                     Alpha_Omega_Alpha + #Univariate SS
                     US_or_Canadian_Applicant + #Univariate SS
                     Gold_Humanism_Honor_Society + #Univariate SS
                     Visa_Sponsorship_Needed + #Univariate SS
                     Count_of_Poster_Presentation +  #Univariate SS
                     Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published,
                   data=data, family="binomial")
print(mod_fit_two)



####Wald Test - Individual Variable Importance
#  The idea is to test the hypothesis that the coefficient of an independent variable in the model is significantly different from zero. If the test fails to reject the null hypothesis, this suggests that removing the variable from the model will not substantially harm the fit of that model.

#Keep p<0.3
regTermTest(mod_fit_two, "Age") #Wald Test p=0.30, good
regTermTest(mod_fit_two, "Gender") #Wald Test p=0.30, good
regTermTest(mod_fit_two, "white_non_white") # Wald Test p=0.30
regTermTest(mod_fit_two, "Couples_Match") # Wald Test p=0.048, KEEP
regTermTest(mod_fit_two, "Visa_Status_Expected") #Wald Testp=0.35
regTermTest(mod_fit_two, "Medical_Education_or_Training_Interrupted") #Wald Test p=0.75, DROP??
regTermTest(mod_fit_two, "Alpha_Omega_Alpha") # Wald Test p=0.5
regTermTest(mod_fit_two, "USMLE_Step_1_Score") #Wald Test p=0.025
regTermTest(mod_fit_two, "US_or_Canadian_Applicant") #Wald Test p0.98
regTermTest(mod_fit_two, "Gold_Humanism_Honor_Society") #Wald Test p=0.01
regTermTest(mod_fit_two, "Count_of_Oral_Presentation") # Wald Test p=0.47, KEEP
regTermTest(mod_fit_two, "Count_of_Peer_Reviewed_Journal_Articles_Abstracts") #Wald Test p=0.64, DROP
regTermTest(mod_fit_two, "Count_of_Peer_Reviewed_Book_Chapter") #Wald Test p=0.64, DROP
regTermTest(mod_fit_two, "Count_of_Poster_Presentation") #Wald Test  KEEP!
regTermTest(mod_fit_two, "Misdemeanor_Conviction")  #Wald Test Drop it because Wald test show p=0.641
regTermTest(mod_fit_two, "Count_of_Peer_Reviewed_Book_Chapter") #Wald Test Drop it p=0.7
regTermTest(mod_fit_two, "Military_Service_Obligation") #Wald Test Drop it, p=0.43
regTermTest(mod_fit_two, "Other_Service_Obligation") #Wald Test Drop
regTermTest(mod_fit_two, "Visa_Sponsorship_Needed") #Wald Test p=0.20

#To assess the relative importance of individual predictors in the model, we can also look at the absolute value of the t-statistic for each model parameter. 
varImp_mod_fit_two <- caret::varImp(mod_fit_two)
plot(varImp_mod_fit_two, main="Variable Importance")


#######################################################################################
###NOMOGRAM 
##Nomogram for a binary outcome (matching into residency), https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5451623/
#fun.at - Demarcations on the function axis: "Matching into obgyn"
#lp=FALSE so we don't have the logistic progression

nomo_from_model.binomial.significant <- rms::nomogram(model.binomial.significant, 
                                                      #lp.at = seq(-3,4,by=0.5),
                                  fun = plogis, 
                                  fun.at = c(0.001, 0.01, 0.05, seq(0.2, 0.8, by = 0.2), 0.95, 0.99, 0.999), 
                                  funlabel = "Chance of Matching in OBGYN, 2019", 
                                  lp =FALSE,
                                                      #conf.int = c(0.1,0.7), 
                                  abbrev = F,
                                  minlength = 9)
nomogramEx(nomo=nomo_from_model.binomial.significant,np=1,digit=2)  #Gives the polynomial formula
#Export as Figure 1 by hand.  

################################################################
#Data cleaning, Place nicer labels for the data
#label(data$Self_Identify)    <- 'Race/Ethnicity'
label(data$Age)    <- 'Age'
label(data$Alpha_Omega_Alpha) <- 'AOA Member'
label(data$USMLE_Step_1_Score) <- 'USMLE Step 1 Score'
label(data$Gender) <- 'Gender'
label(data$Couples_Match) <- 'Couples Matching'
label(data$Visa_Status_Expected) <- 'Expected Visa Status'
label(data$Medical_School_Type) <- 'Medical School Type'
label(data$Medical_Education_or_Training_Interrupted) <- 'Medical School Interrupted'
label(data$Misdemeanor_Conviction) <- 'Misdemeanor Conviction'
#label(data$USMLE_Step_2_CK_Score) <- 'USMLE Step 2 CK Score'
#label(data$USMLE_Step_2_CS_Score) <- 'USMLE Step 2 CS Score'
#label(data$USMLE_Step_3_Score) <- 'USMLE Step 3 Score'
label(data$US_or_Canadian_Applicant) <- 'US or Canadian Applicant'
label(data$Gold_Humanism_Honor_Society) <- 'Gold Humanism Honors Society'
label(data$Military_Service_Obligation) <- 'Military Service Obligation'
label(data$Count_of_Oral_Presentation) <- 'Count of Oral Presentations'
label(data$Count_of_Peer_Reviewed_Book_Chapter) <- 'Count of Peer-Reviewed Book Chapters'
label(data$Count_of_Poster_Presentation) <- 'Count of Poster Presentations'
label(data$Other_Service_Obligation) <- 'Other Service Obligation'
#label(data$Med_school_condensed) <- 'Medical School Condensed' 
label(data$white_non_white) <- 'Race' 
label(data$Count_of_Peer_Reviewed_Journal_Articles_Abstracts) <- 'Count of Peer-Reviewed Journal Articles'
label(data$Count_of_Peer_Reviewed_Journal_Articles_Abstracts_Other_than_Published) <-'Count of Peer-Reviewed Journal Articles Abstracts Other than Published'
label(data) #Check labels for the data set

dev.off()  #Run this until null device = 1
nomo_final <- plot(nomo_from_model.binomial.significant, lplabel="Linear Predictor",
                   cex.sub = 0.8, cex.axis=0.8, cex.main=1, cex.lab=1, ps=10, xfrac=.7,
                   #fun.side=c(3,3,1,1,3,1,3,1,1,1,1,1,3),
                   #col.conf=c('red','green'),
                   #conf.space=c(0.1,0.5),
                   label.every=1,
                   col.grid = gray(c(0.8, 0.95)),
                   which="Match_Status")
print(nomo_from_model.binomial.significant)
#legend.nomabbrev(nom.bi, which='Alpha_Omega_Alpha', x=.5, y=5)
DescTools::BrierScore(model.binomial.significant2)

#####https://rdrr.io/cran/caret/man/calibration.html  ####
caret::calibration(Match_Status ~ USMLE_Step_1_Score + Alpha_Omega_Alpha + Count_of_Poster_Presentation + US_or_Canadian_Applicant, data = test) 

calPlotData <- calibration(obs ~ lda + qda, data = testProbs)
calPlotData

xyplot(calPlotData, auto.key = list(columns = 2))

#######################################################################################
beepr::beep(sound = 4)
rsconnect::setAccountInfo(name='mufflyt', token='D8846CA8B32E6A5EAEA94BFD02EEEA39', secret='dIXWOv+ud/z6dTPN2xOF9M4BKJtWKROc2cOsZS4U')
DynNom::DynNom.lrm(model.binomial.significant, data, clevel = 0.95, m.summary = "formatted")

#Decision Curve

#https://lengyueyang.github.io/Research/Nomogram-rms.html
#https://www.r-bloggers.com/evaluating-logistic-regression-models/
#https://campus.datacamp.com/courses/multiple-and-logistic-regression/logistic-regression-4?ex=1
#https://www.kaggle.com/sindhuee/r-caret-example
#https://github.com/datasciencedojo/meetup/blob/master/intro_to_ml_with_r_and_caret/IntroToMachineLearning.R
#https://www.machinelearningplus.com/machine-learning/caret-package/
#https://www.machinelearningplus.com/machine-learning/feature-selection/
#http://r-statistics.co/Logistic-Regression-With-R.html
#http://r-statistics.co/Variable-Selection-and-Importance-With-R.html#7.%20Information%20value%20and%20Weight%20of%20evidence
#https://www.datacamp.com/community/tutorials/feature-selection-R-boruta
#https://www.meetup.com/data-science-dojo/events/239730653/
#dev.off()  #https://towardsdatascience.com/visual-overview-of-the-data-frame-4c6186a69697

#Pull clerkship grades by hand.  
#Create column of CU students vs. universe
#Create column of CU students who did not match vs. all students who did not match.  
#If we could look at the clerkship honors, hp, pass would allow us to decrease our step 1 cut off or put at mean because need to review by hand.  
#Hurts student if they do not get a grade at Stanford clerkship.  
#Academic score from CU could be a proxy for clerkship and sub-i grades.  These people were reviewed by Meredith to determine if they should get a CU interview.  All these people have a step 1 score of >233.  National average was 229 because it is due to time.  This is Perfect score is 10 for A or Honors.  
#At APGO/CREOG talk about removing step 1 score and then you can't do any sort of cut off.  

