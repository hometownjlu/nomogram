packrat::init(infer.dependencies = FALSE,
              options = list(
                vcs.ignore.lib = TRUE,
                vcs.ignore.src = TRUE
              ))

install.packages(c("pacman", 'caret', 'readxl', 'XML', 'reshape2', 'devtools', 'purrr', 'readr', 'ggplot2', 'dplyr', 'magick', 'janitor', 'lubridate', 'hms', 'tidyr', 'stringr', 'openxlsx', 'forcats', 'RcppRoll', 'tibble', 'bit64', 'munsell', 'scales', 'rgdal', 'tidyverse', "foreach", "PASWR", "rms", "pROC", "ROCR", "nnet", "packrat", "DynNom", "export", "caTools", "mlbench", "randomForest", "ipred", "xgboost", "Metrics", "RANN", "AppliedPredictiveModeling", "nomogramEx", "shiny", "earth", "fastAdaboost", "Boruta", "glmnet", "ggforce", "tidylog", "InformationValue", "pscl", "scoring", "DescTools", "gbm", "Hmisc", "arsenal", "pander", "moments", "leaps", "MatchIt", "car", "mice", "rpart", "beepr", "fansi", "utf8", "zoom", "lmtest", "ResourceSelection", "rmarkdown", "rattle", "rmda", "funModeling", "tinytex", "caretEnsemble", "broom", "Rmisc", "corrplot", "GGally", "alluvial", "progress", "perturb", "vctrs", "highr", "labeling", "DataExplorer", "rsconnect", "inspectdf", "ggpubr", "esquisse", "stargazer", "tableone", "knitr", "drake", "visNetwork", "woeBinning", "OneR", "rpart.plot", "RColorBrewer", "kableExtra", "kernlab", "naivebayes", "dplR"))

packrat::snapshot(ignore.stale = TRUE, 
                  snapshot.sources = FALSE,
                  infer.dependencies = FALSE)