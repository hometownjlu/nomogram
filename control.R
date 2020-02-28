#Controller

#Creates the data set
source("~/Dropbox/Nomogram/nomogram/All_ERAS_data_merged.R")
print("Sanity check:  The all_years file exists:")
file.exists("~/Dropbox/Nomogram/nomogram/data/All_ERAS_data_merged_output_2_1_2020.csv")

#Creates the custom functions
source("~/Dropbox/Nomogram/nomogram/Code/Additional_functions_nomogram.R", echo=TRUE)  #may need to run by hand

#Exploratory Data Analysis
#rmarkdown::render()
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/00-Exploratory_Data_Analysis.Rmd")
pander::openFileInOS("00-Exploratory_Data_Analysis.html")
pander::openFileInOS("00-Exploratory_Data_Analysis.pdf")

#Split the Data
#rmarkdown::render()
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/01-Split_Data.Rmd")
pander::openFileInOS("01-Split_Data.html")


#Kitchen Sink Model
#rmarkdown::render()
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/02-Kitchen_Sink_Model.Rmd")
pander::openFileInOS("02-Kitchen_Sink_Model.html")

#Feature Selection
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/03-Feature_Selection.Rmd")
pander::openFileInOS("03-Feature_Selection.html")

#Kitchen Sink Model
rmarkdown::render(input = "~/Dropbox/Nomogram/nomogram/04-GLM_and_CART_models.Rmd")
pander::openFileInOS("04-GLM_and_CART_models.html")
