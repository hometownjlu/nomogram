#Controller
#install.packages("here")
library("here")
here::set_here("~/Dropbox/Nomogram/nomogram")
here::here()
rm(list = setdiff(ls(), lsf.str()))


#Creates the custom functions
source(here::here("Code/Additional_functions_nomogram.R"), echo=TRUE)  #may need to run by hand

#Creates the data set
source(here::here("All_ERAS_data_merged.R"))
print("Sanity check:  The all_years file exists:")
file.exists(here::here("/data/All_ERAS_data_merged_output_2_1_2020.csv"))

#Exploratory Data Analysis
#rmarkdown::render()
rmarkdown::render(input = here::here("00-Exploratory_Data_Analysis.Rmd"), output_format = c("html_document"), clean = TRUE)
pander::openFileInOS(here::here("00-Exploratory_Data_Analysis.html"))
#pander::openFileInOS(here::here("00-Exploratory_Data_Analysis.pdf"))


#Split the Data
#rmarkdown::render()
rmarkdown::render(input = here::here("01-Split_Data.Rmd"), output_format = c("html_document"), clean = TRUE)
pander::openFileInOS(here::here("01-Split_Data.html"))
#pander::openFileInOS(here::here("01-Split_Data.pdf"))

#Kitchen Sink Model
#rmarkdown::render()
rmarkdown::render(input = here::here("02-Kitchen_Sink_Model.Rmd"), output_format = c("html_document"), clean = TRUE)
pander::openFileInOS(here::here("02-Kitchen_Sink_Model.html"))
#pander::openFileInOS(here::here("02-Kitchen_Sink_Model.pdf"))

#Feature Selection
rmarkdown::render(input = here::here("03-Feature_Selection.Rmd"), output_format = c("html_document"), clean = TRUE)
pander::openFileInOS(here::here("03-Feature_Selection.html"))
#pander::openFileInOS(here::here("03-Feature_Selection.pdf"))

#GLM_and_CART_models
rmarkdown::render(input = here::here("04-GLM_and_CART_models.Rmd"), output_format = c("html_document"), clean = TRUE)
pander::openFileInOS(here::here("04-GLM_and_CART_models.html"))
#pander::openFileInOS(here::here("04-GLM_and_CART_models.pdf"))